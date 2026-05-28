-- database/seeds/006_demo_student_enrollments.sql

DO $$
DECLARE
  v_fall2025_id   INT;
  v_spring2026_id INT;
  v_student_id    UUID;
  v_offering_id   INT;
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '006_demo_student_enrollments.sql'
  ) THEN
    RAISE NOTICE 'Seed 006 already applied, skipping.';
    RETURN;
  END IF;

  SELECT id INTO v_fall2025_id   FROM semesters WHERE label = 'الترم الأول 2025';
  SELECT id INTO v_spring2026_id FROM semesters WHERE label = 'الترم الثاني 2026';
  SELECT id INTO v_student_id    FROM students
    WHERE user_id = '00000000-0000-0000-0000-000000000003';

  IF v_student_id IS NULL THEN
    RAISE WARNING 'Demo student not found — aborting seed 006.';
    RETURN;
  END IF;

  -- ── الترم الأول 2025 (Y2T1) — completed ─────────────────────────────────────
  -- BS114
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id = (SELECT id FROM courses WHERE code = 'BS114')
    AND semester_id = v_fall2025_id AND section_label = 'Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'B+',3.5,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- BS117
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id=(SELECT id FROM courses WHERE code='BS117')
    AND semester_id=v_fall2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'A',4.0,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- CS211
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id=(SELECT id FROM courses WHERE code='CS211')
    AND semester_id=v_fall2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'B+',3.5,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- SE211
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id=(SELECT id FROM courses WHERE code='SE211')
    AND semester_id=v_fall2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'B',3.0,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- CS212
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id=(SELECT id FROM courses WHERE code='CS212')
    AND semester_id=v_fall2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'A',4.0,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- IT211
  SELECT id INTO v_offering_id FROM course_offerings
  WHERE course_id=(SELECT id FROM courses WHERE code='IT211')
    AND semester_id=v_fall2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments
      (student_id,offering_id,semester_id,letter_grade,grade_points,status)
    VALUES (v_student_id,v_offering_id,v_fall2025_id,'B+',3.5,'completed')
    ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- ── الترم الثاني 2026 (Y2T2) ───────────────────────────────────────────────
  -- No pre-registered enrollments for the current semester.
  -- The student starts with an empty schedule and registers courses manually.

  -- ── Update student credit totals ──────────────────────────────────────
  UPDATE students SET
    total_credits_passed = (
      SELECT COALESCE(SUM(c.credits),0)
      FROM enrollments e
      JOIN course_offerings co ON co.id=e.offering_id
      JOIN courses c ON c.id=co.course_id
      WHERE e.student_id=v_student_id AND e.status='completed'
        AND e.letter_grade NOT IN ('F','Abs','W','I')
    ),
    total_credits_attempted = (
      SELECT COALESCE(SUM(c.credits),0)
      FROM enrollments e
      JOIN course_offerings co ON co.id=e.offering_id
      JOIN courses c ON c.id=co.course_id
      WHERE e.student_id=v_student_id
        AND e.status = 'completed'
    ),
    cgpa = 3.58,   -- Weighted average of the 6 الترم الأول 2025 grades above
    current_level = 'الفرقة الثانية'
  WHERE id = v_student_id;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('006_demo_student_enrollments.sql', 1);

  RAISE NOTICE 'Seed 006 complete — demo student enrolled.';
END $$;
