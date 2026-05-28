-- database/migrations/fix_demo_fall_2025_enrollments.sql

DO $$
DECLARE
  v_student_id uuid;
  v_offering_id integer;
  v_course_id integer;
  v_course_code varchar;
  v_courses varchar[] := ARRAY['IS211', 'CS211', 'IT211'];
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = 'fix_demo_fall_2025_enrollments.sql'
  ) THEN
    RAISE NOTICE 'Demo student الترم الأول 2025 enrollments already fixed.';
    RETURN;
  END IF;

  -- Get Demo Student ID
  SELECT s.id INTO v_student_id
  FROM students s
  JOIN users u ON u.id = s.user_id
  WHERE u.id = '00000000-0000-0000-0000-000000000003';

  IF v_student_id IS NULL THEN
    RAISE NOTICE 'Demo student not found.';
    RETURN;
  END IF;

  -- Enroll in الترم الأول 2025 (semester_id = 1) for Year 2 Term 1 courses
  FOREACH v_course_code IN ARRAY v_courses
  LOOP
    -- Get Course ID
    SELECT id INTO v_course_id FROM courses WHERE code = v_course_code LIMIT 1;
    
    IF v_course_id IS NOT NULL THEN
      -- Get Offering ID for الترم الأول 2025
      SELECT id INTO v_offering_id FROM course_offerings WHERE course_id = v_course_id AND semester_id = 1 LIMIT 1;
      
      IF v_offering_id IS NOT NULL THEN
        -- Insert enrollment if not exists
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = v_student_id AND offering_id = v_offering_id) THEN
          INSERT INTO enrollments (student_id, semester_id, offering_id, status)
          VALUES (v_student_id, 1, v_offering_id, 'registered');
          
          -- Update enrolled_count
          UPDATE course_offerings SET enrolled_count = enrolled_count + 1 WHERE id = v_offering_id;
        END IF;
      END IF;
    END IF;
  END LOOP;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('fix_demo_fall_2025_enrollments.sql', 3);

  RAISE NOTICE 'Demo student enrolled in الترم الأول 2025 courses.';
END $$;
