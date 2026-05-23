-- Migration: fix_graduation_credits.sql
-- Fixes three-way inconsistency in graduation credit hours (was 132, should be 138)
-- Source of truth: academic-regulations.json metadata.total_credit_hours = 138

-- 1. Update bylaw_config seed value
UPDATE bylaw_config SET value = '138', default_value = '138' WHERE key = 'total_credits_required';

-- 2. Update academic_rules seed value
UPDATE academic_rules SET numeric_value = 138, description = 'Students must pass 138 credit hours' WHERE rule_id = 'TOTAL_CREDITS';

-- 3. Recreate the graduation eligibility view with dynamic bylaw lookup
CREATE OR REPLACE VIEW v_graduation_eligibility AS
SELECT
    s.id AS student_id,
    s.student_code,
    u.full_name_en,
    s.specialization,
    s.cgpa,
    s.total_credits_passed,
    s.semesters_enrolled,
    s.academic_status,
    -- Bylaw: 138 credits (from bylaw_config), CGPA >= 2.0
    (s.total_credits_passed >= COALESCE(get_bylaw_value('total_credits_required'), 138)) AS credits_met,
    (s.cgpa >= 2.0) AS gpa_met,
    (s.academic_status NOT IN ('dismissed', 'withdrawn')) AS status_ok,
    -- Honors: CGPA >= 3.0, <= 8 semesters, no F
    (s.cgpa >= 3.0 AND s.semesters_enrolled <= 8) AS honors_possible,
    (s.total_credits_passed >= COALESCE(get_bylaw_value('total_credits_required'), 138) AND s.cgpa >= 2.0 AND s.academic_status NOT IN ('dismissed','withdrawn')) AS is_eligible
FROM students s
JOIN users u ON u.id = s.user_id;

-- 4. Recreate check_graduation_eligibility() function with dynamic bylaw lookup
CREATE OR REPLACE FUNCTION check_graduation_eligibility(p_student_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_student students%ROWTYPE;
    v_training1_done BOOLEAN;
    v_training2_done BOOLEAN;
    v_project1_done BOOLEAN;
    v_project2_done BOOLEAN;
    v_has_f_grades BOOLEAN;
    v_result JSONB;
    v_credits_required NUMERIC;
BEGIN
    v_credits_required := COALESCE(get_bylaw_value('total_credits_required'), 138);
    SELECT * INTO v_student FROM students WHERE id = p_student_id;

    SELECT EXISTS(SELECT 1 FROM training_records WHERE student_id = p_student_id AND training_number = 1 AND status = 'completed') INTO v_training1_done;
    SELECT EXISTS(SELECT 1 FROM training_records WHERE student_id = p_student_id AND training_number = 2 AND status = 'completed') INTO v_training2_done;
    SELECT EXISTS(SELECT 1 FROM graduation_projects WHERE student_id = p_student_id AND part = 1 AND is_passed = TRUE) INTO v_project1_done;
    SELECT EXISTS(SELECT 1 FROM graduation_projects WHERE student_id = p_student_id AND part = 2 AND is_passed = TRUE) INTO v_project2_done;
    SELECT EXISTS(
        SELECT 1 FROM enrollments e
        JOIN course_offerings co ON co.id = e.offering_id
        JOIN courses c ON c.id = co.course_id
        WHERE e.student_id = p_student_id AND e.letter_grade = 'F' AND e.is_counted_in_gpa = TRUE AND c.is_credit_bearing = TRUE
    ) INTO v_has_f_grades;

    v_result := jsonb_build_object(
        'student_id', p_student_id,
        'credits_passed', v_student.total_credits_passed,
        'credits_required', v_credits_required,
        'credits_met', v_student.total_credits_passed >= v_credits_required,
        'cgpa', v_student.cgpa,
        'cgpa_met', v_student.cgpa >= 2.0,
        'training1_done', v_training1_done,
        'training2_done', v_training2_done,
        'project1_done', v_project1_done,
        'project2_done', v_project2_done,
        'no_pending_f_grades', NOT v_has_f_grades,
        'remedial_math_ok', (NOT v_student.remedial_math_required OR v_student.remedial_math_passed),
        'is_eligible', (
            v_student.total_credits_passed >= v_credits_required AND
            v_student.cgpa >= 2.0 AND
            v_training1_done AND v_training2_done AND
            v_project1_done AND v_project2_done AND
            NOT v_has_f_grades AND
            v_student.academic_status NOT IN ('dismissed', 'withdrawn')
        ),
        'honors_eligible', (
            v_student.cgpa >= 3.0 AND
            v_student.semesters_enrolled <= 8 AND
            NOT v_has_f_grades AND
            v_student.total_warnings = 0
        )
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
