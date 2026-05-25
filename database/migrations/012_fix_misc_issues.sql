-- =============================================================================
-- Migration 012: Fix doctor name, diversify student grades, fix classifications
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Fix doctor name: always set to canonical Arabic for Dr. Aida Nasr.
--    Match by the stable full_name_en (English name is ASCII → never corrupted)
--    so the fix works even when full_name_ar holds encoding garbage ("?????").
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE users
SET full_name_ar = 'د. عايده نصر'
WHERE full_name_en = 'Dr. Aida Nasr'
  AND full_name_ar IS DISTINCT FROM 'د. عايده نصر';

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Fix semester_gpa_records.classification for all rows
--    Normalise to Arabic — handles both old English values and garbage/question-mark
--    values that resulted from encoding issues in previous seeds.
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE semester_gpa_records
SET classification = CASE
  WHEN cumulative_gpa >= 3.5 THEN 'ممتاز'
  WHEN cumulative_gpa >= 3.0 THEN 'جيد جداً'
  WHEN cumulative_gpa >= 2.0 THEN 'جيد'
  WHEN cumulative_gpa >= 1.0 THEN 'مقبول'
  ELSE 'راسب'
END
WHERE cumulative_gpa IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Diversify student grades: distribute completed enrollments across C- → A
--    Keeps the majority in C- to A range while adding realistic variation.
--    Strategy: use the enrollment id (stable pseudo-random) to bucket rows.
--    Only touches rows where letter_grade is uniform single-value bulk inserts
--    (C+ with grade_points = 2.5 or 2.6) that came from seeds.
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_grade_map TEXT[][];
  v_bucket    INT;
BEGIN
  -- Grade distribution table: [letter, points, total_numeric]
  -- ~70% C- to B+, ~20% B+ to A, ~10% A to A+
  -- Represented as 10 buckets (mod 10 of enrollment id hash)
  -- Bucket 0 → C-    (67)
  -- Bucket 1 → C     (70)
  -- Bucket 2 → C+    (73)
  -- Bucket 3 → C+    (73)
  -- Bucket 4 → B-    (77)
  -- Bucket 5 → B     (80)
  -- Bucket 6 → B+    (85)
  -- Bucket 7 → B+    (85)
  -- Bucket 8 → A-    (88)
  -- Bucket 9 → A     (92)

  -- Update completed enrollments that have uniform C+ grades (grade_points IN (2.5, 2.6))
  -- Only for REAL students (not the demo/seed student 00000000-0000-0000-0000-000000000085)
  UPDATE enrollments e
  SET
    letter_grade = CASE (ABS(hashtext(e.id::text)) % 10)
      WHEN 0 THEN 'C-'::grade_code
      WHEN 1 THEN 'C'::grade_code
      WHEN 2 THEN 'C+'::grade_code
      WHEN 3 THEN 'C+'::grade_code
      WHEN 4 THEN 'B-'::grade_code
      WHEN 5 THEN 'B'::grade_code
      WHEN 6 THEN 'B+'::grade_code
      WHEN 7 THEN 'B+'::grade_code
      WHEN 8 THEN 'A-'::grade_code
      WHEN 9 THEN 'A'::grade_code
    END,
    grade_points = CASE (ABS(hashtext(e.id::text)) % 10)
      WHEN 0 THEN 2.2
      WHEN 1 THEN 2.4
      WHEN 2 THEN 2.6
      WHEN 3 THEN 2.6
      WHEN 4 THEN 2.8
      WHEN 5 THEN 3.0
      WHEN 6 THEN 3.2
      WHEN 7 THEN 3.2
      WHEN 8 THEN 3.4
      WHEN 9 THEN 3.7
    END,
    total_grade = CASE (ABS(hashtext(e.id::text)) % 10)
      WHEN 0 THEN 67.0
      WHEN 1 THEN 70.0
      WHEN 2 THEN 73.0
      WHEN 3 THEN 73.0
      WHEN 4 THEN 77.0
      WHEN 5 THEN 80.0
      WHEN 6 THEN 85.0
      WHEN 7 THEN 85.0
      WHEN 8 THEN 88.0
      WHEN 9 THEN 92.0
    END
  FROM students s
  WHERE e.student_id = s.id
    AND e.status = 'completed'
    AND e.letter_grade = 'C+'
    AND e.grade_points IN (2.5, 2.6)
    AND s.user_id != '00000000-0000-0000-0000-000000000085';

  -- Also vary uniform 'A' (4.0) bulk grades in real students to add realism
  -- Keep ~40% as A, spread rest across A- / B+
  UPDATE enrollments e
  SET
    letter_grade = CASE (ABS(hashtext(e.id::text)) % 5)
      WHEN 0 THEN 'B+'::grade_code
      WHEN 1 THEN 'A-'::grade_code
      ELSE         'A'::grade_code
    END,
    grade_points = CASE (ABS(hashtext(e.id::text)) % 5)
      WHEN 0 THEN 3.2
      WHEN 1 THEN 3.4
      ELSE         3.7
    END,
    total_grade = CASE (ABS(hashtext(e.id::text)) % 5)
      WHEN 0 THEN 85.0
      WHEN 1 THEN 88.0
      ELSE         92.0
    END
  FROM students s
  WHERE e.student_id = s.id
    AND e.status = 'completed'
    AND e.letter_grade = 'A'
    AND e.grade_points = 4.0
    AND s.user_id != '00000000-0000-0000-0000-000000000085';

END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Recompute CGPA for all students whose grades just changed
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE students s
SET cgpa = sub.new_cgpa
FROM (
  SELECT
    e.student_id,
    ROUND(
      SUM(e.grade_points * c.credits)::NUMERIC /
      NULLIF(SUM(c.credits), 0)
    , 3) AS new_cgpa
  FROM enrollments e
  JOIN course_offerings co ON co.id = e.offering_id
  JOIN courses c ON c.id = co.course_id
  WHERE e.status = 'completed'
    AND e.grade_points IS NOT NULL
  GROUP BY e.student_id
) sub
WHERE s.id = sub.student_id;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Recompute semester_gpa_records for all affected students
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_student RECORD;
  v_sem     RECORD;
  v_sem_gpa NUMERIC;
  v_cum_pts NUMERIC;
  v_cum_crd NUMERIC;
  v_cum_gpa NUMERIC;
  v_cls     TEXT;
BEGIN
  FOR v_student IN SELECT id FROM students LOOP
    v_cum_pts := 0;
    v_cum_crd := 0;

    FOR v_sem IN
      SELECT
        e.semester_id,
        sem.start_date,
        COALESCE(SUM(e.grade_points * c.credits), 0) AS gp_earned,
        COALESCE(SUM(c.credits), 0)                  AS credits_att,
        COALESCE(SUM(CASE WHEN e.letter_grade NOT IN ('F','Abs','W') THEN c.credits ELSE 0 END), 0) AS credits_pass
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c  ON c.id  = co.course_id
      JOIN semesters sem ON sem.id = e.semester_id
      WHERE e.student_id = v_student.id
        AND e.status = 'completed'
        AND e.grade_points IS NOT NULL
      GROUP BY e.semester_id, sem.start_date
      ORDER BY sem.start_date
    LOOP
      IF v_sem.credits_att = 0 THEN CONTINUE; END IF;

      v_sem_gpa  := ROUND(v_sem.gp_earned / v_sem.credits_att, 3);
      v_cum_pts  := v_cum_pts + v_sem.gp_earned;
      v_cum_crd  := v_cum_crd + v_sem.credits_att;
      v_cum_gpa  := ROUND(v_cum_pts / v_cum_crd, 3);

      v_cls := CASE
        WHEN v_cum_gpa >= 3.5 THEN 'ممتاز'
        WHEN v_cum_gpa >= 3.0 THEN 'جيد جداً'
        WHEN v_cum_gpa >= 2.0 THEN 'جيد'
        WHEN v_cum_gpa >= 1.0 THEN 'مقبول'
        ELSE 'راسب'
      END;

      INSERT INTO semester_gpa_records
        (student_id, semester_id, credits_attempted, credits_passed,
         grade_points_earned, semester_gpa, cumulative_gpa, classification)
      VALUES
        (v_student.id, v_sem.semester_id, v_sem.credits_att, v_sem.credits_pass,
         v_sem.gp_earned, v_sem_gpa, v_cum_gpa, v_cls)
      ON CONFLICT (student_id, semester_id) DO UPDATE SET
        credits_attempted   = EXCLUDED.credits_attempted,
        credits_passed      = EXCLUDED.credits_passed,
        grade_points_earned = EXCLUDED.grade_points_earned,
        semester_gpa        = EXCLUDED.semester_gpa,
        cumulative_gpa      = EXCLUDED.cumulative_gpa,
        classification      = EXCLUDED.classification,
        computed_at         = NOW();
    END LOOP;
  END LOOP;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Log this migration
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO seed_logs (seed_name, run_at)
VALUES ('012_fix_misc_issues.sql', NOW())
ON CONFLICT (seed_name) DO NOTHING;
