-- database/seeds/007_fix_demo_student.sql

DO $$
DECLARE
  v_fall2024_id    INT;
  v_spring2025_id  INT;
  v_student_id     UUID;
  v_offering_id    INT;
  v_demo_user_id   UUID := '00000000-0000-0000-0000-000000000003';
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '007_fix_demo_student.sql'
  ) THEN
    RAISE NOTICE 'Seed 007 already applied, skipping.';
    RETURN;
  END IF;

  -- Verify demo student exists
  SELECT id INTO v_student_id FROM students WHERE user_id = v_demo_user_id;
  IF v_student_id IS NULL THEN
    RAISE EXCEPTION 'Demo student not found. Ensure seed 001 has run.';
  END IF;

  -- ── STEP 1: Insert Fall 2024 and Spring 2025 semesters if missing ─────
  -- These are needed as the offering's semester reference
  INSERT INTO semesters (academic_year_id, semester_type, label, status,
    start_date, end_date, registration_start, registration_end,
    add_drop_deadline, withdrawal_deadline)
  SELECT ay.id, 'fall', 'Fall 2024', 'closed',
    '2024-09-15', '2025-01-15', '2024-09-01', '2024-09-14',
    '2024-09-28', '2024-11-10'
  FROM academic_years ay WHERE ay.year_label = '2024-2025'
  ON CONFLICT (academic_year_id, semester_type) DO NOTHING;

  INSERT INTO semesters (academic_year_id, semester_type, label, status,
    start_date, end_date, registration_start, registration_end,
    add_drop_deadline, withdrawal_deadline)
  SELECT ay.id, 'spring', 'Spring 2025', 'closed',
    '2025-02-15', '2025-06-15', '2025-02-01', '2025-02-14',
    '2025-03-01', '2025-04-12'
  FROM academic_years ay WHERE ay.year_label = '2024-2025'
  ON CONFLICT (academic_year_id, semester_type) DO NOTHING;

  SELECT id INTO v_fall2024_id   FROM semesters WHERE label = 'Fall 2024';
  SELECT id INTO v_spring2025_id FROM semesters WHERE label = 'Spring 2025';

  IF v_fall2024_id IS NULL THEN
    RAISE EXCEPTION 'Fall 2024 semester not found after insert. Check academic_years table.';
  END IF;

  -- ── STEP 2: Create Y1T1 course_offerings for Fall 2024 ────────────────
  -- (Reuse same doctors as Fall 2025, is_active = FALSE for historical)

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.aida@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'BS112'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.osama.g@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'CS111'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.omnia@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'IS111'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.nancy@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'BS111'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.shimaa@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'BS116'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_fall2024_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.walid.s@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'UNV113'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  -- ── STEP 3: Create Y1T2 course_offerings for Spring 2025 ──────────────

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.aida@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'BS115'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.ahmed@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'UNV112'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.mostafa@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'BS113'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.arwa@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'UNV114'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.shimaa@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'UNV111'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  INSERT INTO course_offerings
    (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  SELECT v_spring2025_id, c.id,
    (SELECT d.id FROM doctors d JOIN users u ON u.id=d.user_id
     WHERE u.email = 'dr.osama.g@fci.tanta.edu.eg' LIMIT 1),
    80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM courses c WHERE c.code = 'CS112'
  ON CONFLICT (semester_id, course_id, section_label) DO NOTHING;

  -- ── STEP 4: Insert Y1T1 completed enrollments (Fall 2024) ─────────────
  -- Grades consistent with demo student cgpa 3.58

  FOR v_offering_id IN (
    SELECT co.id FROM course_offerings co
    JOIN courses c ON c.id = co.course_id
    WHERE co.semester_id = v_fall2024_id
      AND c.code IN ('BS112','CS111','IS111','BS111','BS116','UNV113')
      AND co.section_label = 'Main'
  ) LOOP
    INSERT INTO enrollments
      (student_id, offering_id, semester_id, letter_grade, grade_points, status)
    VALUES (v_student_id, v_offering_id, v_fall2024_id, 'B+', 3.5, 'completed')
    ON CONFLICT (student_id, offering_id) DO NOTHING;
  END LOOP;

  -- Give BS112 and CS111 an 'A' to keep GPA realistic
  UPDATE enrollments SET letter_grade = 'A', grade_points = 4.0
  WHERE student_id = v_student_id
    AND status = 'completed'
    AND offering_id IN (
      SELECT co.id FROM course_offerings co
      JOIN courses c ON c.id = co.course_id
      WHERE co.semester_id = v_fall2024_id
        AND c.code IN ('BS112','CS111')
        AND co.section_label = 'Main'
    );

  -- ── STEP 5: Insert Y1T2 completed enrollments (Spring 2025) ───────────

  FOR v_offering_id IN (
    SELECT co.id FROM course_offerings co
    JOIN courses c ON c.id = co.course_id
    WHERE co.semester_id = v_spring2025_id
      AND c.code IN ('BS115','UNV112','BS113','UNV114','UNV111','CS112')
      AND co.section_label = 'Main'
  ) LOOP
    INSERT INTO enrollments
      (student_id, offering_id, semester_id, letter_grade, grade_points, status)
    VALUES (v_student_id, v_offering_id, v_spring2025_id, 'B+', 3.5, 'completed')
    ON CONFLICT (student_id, offering_id) DO NOTHING;
  END LOOP;

  -- Give CS112 an 'A'
  UPDATE enrollments SET letter_grade = 'A', grade_points = 4.0
  WHERE student_id = v_student_id
    AND status = 'completed'
    AND offering_id IN (
      SELECT co.id FROM course_offerings co
      JOIN courses c ON c.id = co.course_id
      WHERE co.semester_id = v_spring2025_id
        AND c.code = 'CS112' AND co.section_label = 'Main'
    );

  -- ── STEP 6: Recalculate total_credits_passed ───────────────────────────
  -- After inserting all historical enrollments, recompute from actuals
  UPDATE students SET
    total_credits_passed = (
      SELECT COALESCE(SUM(c.credits), 0)
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c ON c.id = co.course_id
      WHERE e.student_id = v_student_id AND e.status = 'completed'
    ),
    total_credits_attempted = (
      SELECT COALESCE(SUM(c.credits), 0)
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c ON c.id = co.course_id
      WHERE e.student_id = v_student_id
        AND e.status IN ('completed', 'registered')
    ),
    -- Recompute weighted cgpa from all completed enrollments
    cgpa = (
      SELECT ROUND(
        SUM(e.grade_points * c.credits)::numeric / NULLIF(SUM(c.credits), 0),
        3
      )
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c ON c.id = co.course_id
      WHERE e.student_id = v_student_id AND e.status = 'completed'
    ),
    current_level = 'sophomore',
    semesters_enrolled = 3   -- Fall2024 + Spring2025 + Fall2025
  WHERE id = v_student_id;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('007_fix_demo_student.sql', 1);

  RAISE NOTICE 'Seed 007 complete. Demo student now has 50 credits → Level 2.';
END $$;
