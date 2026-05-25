-- database/seeds/008_fix_total_grades_and_gpa.sql
-- Adds total_grade (numeric 0–100) to all demo-student completed enrollments
-- and inserts semester_gpa_records for each completed term.

DO $$
DECLARE
  v_student_id    UUID;
  v_demo_user_id  UUID := '00000000-0000-0000-0000-000000000003';
  v_sem           RECORD;
  v_sem_gpa       NUMERIC(4,3);
  v_cum_pts       NUMERIC := 0;
  v_cum_credits   INT     := 0;
  v_cum_gpa       NUMERIC(4,3);
  v_cls           VARCHAR(50);
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '008_fix_total_grades_and_gpa.sql'
  ) THEN
    RAISE NOTICE 'Seed 008 already applied, skipping.';
    RETURN;
  END IF;

  SELECT id INTO v_student_id FROM students WHERE user_id = v_demo_user_id;
  IF v_student_id IS NULL THEN
    RAISE WARNING 'Demo student not found — aborting seed 008.';
    RETURN;
  END IF;

  -- ── STEP 1: Map letter_grade → total_grade for ALL completed enrollments ──
  UPDATE enrollments
  SET total_grade = CASE letter_grade
    WHEN 'A+'  THEN 97.0
    WHEN 'A'   THEN 92.0
    WHEN 'A-'  THEN 88.0
    WHEN 'B+'  THEN 85.0
    WHEN 'B'   THEN 80.0
    WHEN 'B-'  THEN 77.0
    WHEN 'C+'  THEN 73.0
    WHEN 'C'   THEN 70.0
    WHEN 'C-'  THEN 67.0
    WHEN 'D+'  THEN 63.0
    WHEN 'D'   THEN 60.0
    WHEN 'F'   THEN 45.0
    WHEN 'Abs' THEN 0.0
    ELSE NULL
  END
  WHERE student_id  = v_student_id
    AND status      = 'completed'
    AND total_grade IS NULL
    AND letter_grade IS NOT NULL;

  RAISE NOTICE 'Updated total_grade for % enrollments.',
    (SELECT COUNT(*) FROM enrollments
     WHERE student_id = v_student_id AND status = 'completed' AND total_grade IS NOT NULL);

  -- ── STEP 2: Insert semester_gpa_records per completed semester ────────────
  -- Iterate semesters in chronological order so cumulative GPA builds correctly.
  FOR v_sem IN (
    SELECT
      sem.id                       AS semester_id,
      SUM(c.credits)               AS credits_att,
      SUM(CASE WHEN e.letter_grade NOT IN ('F','Abs','W','I')
               THEN c.credits ELSE 0 END) AS credits_pass,
      SUM(e.grade_points * c.credits) AS gp_earned
    FROM enrollments e
    JOIN course_offerings co ON co.id = e.offering_id
    JOIN courses           c  ON c.id  = co.course_id
    JOIN semesters         sem ON sem.id = e.semester_id
    WHERE e.student_id = v_student_id
      AND e.status     = 'completed'
      AND e.grade_points IS NOT NULL
    GROUP BY sem.id, sem.start_date
    ORDER BY sem.start_date
  ) LOOP
    v_sem_gpa     := ROUND(v_sem.gp_earned / NULLIF(v_sem.credits_att, 0), 3);
    v_cum_pts     := v_cum_pts + v_sem.gp_earned;
    v_cum_credits := v_cum_credits + v_sem.credits_att;
    v_cum_gpa     := ROUND(v_cum_pts / NULLIF(v_cum_credits, 0), 3);

    v_cls := CASE
      WHEN v_sem_gpa >= 3.6 THEN 'ممتاز'
      WHEN v_sem_gpa >= 3.0 THEN 'جيد جداً'
      WHEN v_sem_gpa >= 2.0 THEN 'جيد'
      WHEN v_sem_gpa >= 1.0 THEN 'مقبول'
      ELSE 'راسب'
    END;

    INSERT INTO semester_gpa_records
      (student_id, semester_id,
       credits_attempted, credits_passed, grade_points_earned,
       semester_gpa, cumulative_gpa, classification)
    VALUES
      (v_student_id, v_sem.semester_id,
       v_sem.credits_att, v_sem.credits_pass, v_sem.gp_earned,
       v_sem_gpa, v_cum_gpa, v_cls)
    ON CONFLICT (student_id, semester_id) DO UPDATE SET
      credits_attempted   = EXCLUDED.credits_attempted,
      credits_passed      = EXCLUDED.credits_passed,
      grade_points_earned = EXCLUDED.grade_points_earned,
      semester_gpa        = EXCLUDED.semester_gpa,
      cumulative_gpa      = EXCLUDED.cumulative_gpa,
      classification      = EXCLUDED.classification,
      computed_at         = NOW();
  END LOOP;

  -- ── STEP 3: Sync student.cgpa with the last cumulative_gpa record ─────────
  UPDATE students
  SET cgpa = (
    SELECT sg.cumulative_gpa
    FROM semester_gpa_records sg
    JOIN semesters sem ON sem.id = sg.semester_id
    WHERE sg.student_id = v_student_id
    ORDER BY sem.start_date DESC
    LIMIT 1
  )
  WHERE id = v_student_id;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('008_fix_total_grades_and_gpa.sql', 1);

  RAISE NOTICE 'Seed 008 complete. GPA records inserted; total_grade populated.';
END $$;
