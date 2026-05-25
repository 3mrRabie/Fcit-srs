-- =============================================================================
-- FIX-M6: Update v_admin_dashboard_stats
-- =============================================================================

CREATE OR REPLACE VIEW v_admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM students WHERE academic_status = 'active') AS active_students,
    (SELECT COUNT(*) FROM students WHERE academic_status = 'warning') AS warning_students,
    (SELECT COUNT(*) FROM students WHERE academic_status = 'probation') AS probation_students,
    (SELECT COUNT(*) FROM students WHERE academic_status = 'dismissed') AS dismissed_students,
    (SELECT COUNT(*) FROM students WHERE academic_status = 'graduated') AS graduated_students,
    (SELECT COUNT(*) FROM doctors) AS total_doctors,
    (SELECT COUNT(*) FROM courses WHERE is_active = TRUE) AS active_courses,
    (SELECT COUNT(*) FROM enrollments WHERE status = 'registered') AS current_enrollments,
    (SELECT AVG(cgpa)::NUMERIC(4,3) FROM students WHERE academic_status IN ('active','warning','probation')) AS avg_cgpa;


-- FIX-L5: Only show active/in-progress semesters; closed semesters are accessible via transcript queries
CREATE OR REPLACE VIEW v_doctor_courses AS
SELECT
    d.id AS doctor_id,
    u.full_name_en AS doctor_name,
    sem.label AS semester,
    sem.status AS semester_status,
    c.code AS course_code,
    c.name_en AS course_name,
    c.credits,
    co.id AS offering_id,
    co.enrolled_count,
    co.capacity
FROM doctors d
JOIN users u ON u.id = d.user_id
JOIN course_offerings co ON co.doctor_id = d.id
JOIN courses c ON c.id = co.course_id
JOIN semesters sem ON sem.id = co.semester_id
WHERE sem.status IN ('registration', 'active', 'grading');
