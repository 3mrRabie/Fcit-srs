-- Migration 020: Permanent Database Cleanup and Resolution
-- Applies strict user constraints on professor assignments and overlap resolutions
DO $$ 
DECLARE
  v_spring2026_id INT;
  v_fall2025_id INT;
  
  v_doc_aida UUID;
  v_doc_nancy UUID;
  v_doc_shimaa UUID;
  v_doc_hany UUID;
  v_doc_ahmed UUID;
  v_doc_ibrahim UUID;
  v_doc_marian UUID;

  v_bs115_id INT;
  v_it111_id INT;
  v_is321_id INT;
  v_is315_id INT;
  v_cs313_id INT;
  v_se321_id INT;
  v_is413_id INT;
  v_it319_id INT;
  v_is312_id INT;

  r RECORD;
  v_keep_id INT;
  v_delete_id INT;
BEGIN
  -- 1. Setup variables
  SELECT id INTO v_spring2026_id FROM semesters WHERE label = 'الترم الثاني 2026';
  SELECT id INTO v_fall2025_id FROM semesters WHERE label = 'الترم الأول 2025';
  
  SELECT d.id INTO v_doc_aida FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Aida Nasr' LIMIT 1;
  SELECT d.id INTO v_doc_nancy FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Prof. Nancy Al-Hafnawi' LIMIT 1;
  SELECT d.id INTO v_doc_shimaa FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Shimaa Hagras' LIMIT 1;
  SELECT d.id INTO v_doc_hany FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Hany Al-Ghayesh' LIMIT 1;
  SELECT d.id INTO v_doc_ahmed FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Ahmed Selim' LIMIT 1;
  SELECT d.id INTO v_doc_ibrahim FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Ibrahim Gad' LIMIT 1;
  SELECT d.id INTO v_doc_marian FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Marian Wagdy' LIMIT 1;
  
  SELECT id INTO v_bs115_id FROM courses WHERE code = 'BS115';
  SELECT id INTO v_it111_id FROM courses WHERE code = 'IT111';
  SELECT id INTO v_is321_id FROM courses WHERE code = 'IS321';
  SELECT id INTO v_is315_id FROM courses WHERE code = 'IS315';
  SELECT id INTO v_cs313_id FROM courses WHERE code = 'CS313';
  SELECT id INTO v_se321_id FROM courses WHERE code = 'SE321';
  SELECT id INTO v_is413_id FROM courses WHERE code = 'IS413';
  SELECT id INTO v_it319_id FROM courses WHERE code = 'IT319';
  SELECT id INTO v_is312_id FROM courses WHERE code = 'IS312';

  -- ==========================================
  -- A. Professor Assignment Corrections
  -- ==========================================
  
  -- BS115: Ensure Dr. Aida Nasr is on BS115. Ensure Prof. Nancy is on IT111 instead of BS115.
  DECLARE
    v_aida_bs115 INT;
    v_nancy_bs115 INT;
  BEGIN
    SELECT id INTO v_aida_bs115 FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_aida LIMIT 1;
    SELECT id INTO v_nancy_bs115 FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_nancy LIMIT 1;

    -- If Aida doesn't exist on BS115, we must recreate her offering (if Nancy's is active, transfer it)
    IF v_aida_bs115 IS NULL AND v_nancy_bs115 IS NOT NULL THEN
      -- Aida does not exist, but Nancy does. Convert Nancy's offering directly to Aida's!
      UPDATE course_offerings SET doctor_id = v_doc_aida WHERE id = v_nancy_bs115;
      v_aida_bs115 := v_nancy_bs115;
      v_nancy_bs115 := NULL; -- Handled
    ELSIF v_aida_bs115 IS NULL THEN
      -- Neither exists, insert Aida's BS115
      INSERT INTO course_offerings (course_id, semester_id, doctor_id, capacity, enrolled_count, is_active, section_label)
      VALUES (v_bs115_id, v_spring2026_id, v_doc_aida, 60, 0, TRUE, 'Main') RETURNING id INTO v_aida_bs115;
      
      -- Insert schedule slot for Aida
      INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time)
      VALUES (v_aida_bs115, 'Sat', '07:00:00', '09:00:00');
    END IF;

    -- If Nancy still has a BS115 offering, she shouldn't!
    IF v_nancy_bs115 IS NOT NULL THEN
      -- Move any enrollments to Aida
      UPDATE enrollments SET offering_id = v_aida_bs115 WHERE offering_id = v_nancy_bs115;
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_aida_bs115) WHERE id = v_aida_bs115;
      
      -- Instead of deleting Nancy's offering, point it to IT111 as requested!
      UPDATE course_offerings SET course_id = v_it111_id, enrolled_count = 0, is_active = TRUE WHERE id = v_nancy_bs115;
    ELSE
      -- Ensure Nancy is on IT111
      IF NOT EXISTS (SELECT 1 FROM course_offerings WHERE course_id = v_it111_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_nancy) THEN
        INSERT INTO course_offerings (course_id, semester_id, doctor_id, capacity, enrolled_count, is_active, section_label)
        VALUES (v_it111_id, v_spring2026_id, v_doc_nancy, 60, 0, TRUE, 'Main');
      END IF;
    END IF;
  END;

  -- Dr. Marian Wagdy: Fix IT317 duplicate, should be IT212
  DECLARE
    v_it212_id INT;
    v_bad_offering INT;
    v_good_offering INT;
  BEGIN
    SELECT id INTO v_it212_id FROM courses WHERE code = 'IT212';
    
    SELECT co.id INTO v_bad_offering
    FROM course_offerings co
    WHERE co.course_id = (SELECT id FROM courses WHERE code = 'IT317')
      AND co.doctor_id = v_doc_marian
    LIMIT 1;

    IF v_bad_offering IS NOT NULL THEN
      SELECT id INTO v_good_offering FROM course_offerings WHERE course_id = v_it212_id AND doctor_id = v_doc_marian LIMIT 1;
      
      IF v_good_offering IS NOT NULL THEN
        -- Move enrollments first, ignoring duplicates
        UPDATE enrollments SET offering_id = v_good_offering WHERE offering_id = v_bad_offering AND student_id NOT IN (SELECT student_id FROM enrollments WHERE offering_id = v_good_offering);
        DELETE FROM enrollments WHERE offering_id = v_bad_offering; -- delete any remaining duplicates
        DELETE FROM doctor_schedule_slots WHERE offering_id = v_bad_offering;
        DELETE FROM course_offerings WHERE id = v_bad_offering;
      ELSE
        UPDATE course_offerings SET course_id = v_it212_id WHERE id = v_bad_offering;
      END IF;
    END IF;
  END;

  -- IS321: Ensure Dr. Hany is on IS321. Ensure Dr. Shimaa is on IS315.
  DECLARE
    v_shimaa_is321 INT;
    v_hany_is321 INT;
    v_shimaa_is315 INT;
  BEGIN
    SELECT id INTO v_shimaa_is321 FROM course_offerings WHERE course_id = v_is321_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_shimaa LIMIT 1;
    SELECT id INTO v_hany_is321 FROM course_offerings WHERE course_id = v_is321_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_hany LIMIT 1;
    SELECT id INTO v_shimaa_is315 FROM course_offerings WHERE course_id = v_is315_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_shimaa LIMIT 1;

    -- Ensure Hany is on IS321
    IF v_hany_is321 IS NULL THEN
      INSERT INTO course_offerings (course_id, semester_id, doctor_id, capacity, enrolled_count, is_active, section_label)
      VALUES (v_is321_id, v_spring2026_id, v_doc_hany, 60, 0, TRUE, 'Main') RETURNING id INTO v_hany_is321;
    ELSE
      UPDATE course_offerings SET is_active = TRUE WHERE id = v_hany_is321;
    END IF;

    -- Ensure Shimaa is on IS315
    IF v_shimaa_is315 IS NULL THEN
      INSERT INTO course_offerings (course_id, semester_id, doctor_id, capacity, enrolled_count, is_active, section_label)
      VALUES (v_is315_id, v_spring2026_id, v_doc_shimaa, 60, 0, TRUE, 'Main') RETURNING id INTO v_shimaa_is315;
    END IF;

    -- Clean up Shimaa's IS321 duplicate
    IF v_shimaa_is321 IS NOT NULL THEN
      UPDATE enrollments SET offering_id = v_hany_is321 WHERE offering_id = v_shimaa_is321;
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_hany_is321) WHERE id = v_hany_is321;
      
      DELETE FROM doctor_schedule_slots WHERE offering_id = v_shimaa_is321;
      DELETE FROM course_offerings WHERE id = v_shimaa_is321;
    END IF;
  END;

  -- ==========================================
  -- B. Overlapping Schedule Fixes
  -- ==========================================

  -- Dr. Ahmed Selim (الترم الأول 2025): Move CS313 to Mon 13:00-15:00, SE321 to Mon 15:00-17:00
  UPDATE doctor_schedule_slots s
  SET start_time = '13:00:00', end_time = '15:00:00', day_of_week = 'Mon'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_cs313_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_ahmed;

  UPDATE doctor_schedule_slots s
  SET start_time = '15:00:00', end_time = '17:00:00', day_of_week = 'Mon'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_se321_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_ahmed;

  -- Dr. Ibrahim Gad (الترم الثاني 2026): Move IS413 to Sun 09:00-11:00
  UPDATE doctor_schedule_slots s
  SET start_time = '09:00:00', end_time = '11:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_is413_id AND co.semester_id = v_spring2026_id AND co.doctor_id = v_doc_ibrahim AND s.day_of_week = 'Sun' AND s.start_time = '07:00:00';

  -- Dr. Marian Wagdy (الترم الثاني 2026): Move one section of IT319 to Sun 11:00-13:00
  -- Identify the second IT319 offering for Marian on Sunday 09:00
  DECLARE
    v_marian_it319_to_move INT;
  BEGIN
    SELECT s.offering_id INTO v_marian_it319_to_move 
    FROM doctor_schedule_slots s
    JOIN course_offerings co ON s.offering_id = co.id
    WHERE co.course_id = v_it319_id AND co.semester_id = v_spring2026_id AND co.doctor_id = v_doc_marian AND s.day_of_week = 'Sun' AND s.start_time = '09:00:00'
    ORDER BY s.id DESC LIMIT 1;
    
    IF v_marian_it319_to_move IS NOT NULL THEN
      UPDATE doctor_schedule_slots SET start_time = '11:00:00', end_time = '13:00:00' WHERE offering_id = v_marian_it319_to_move;
    END IF;
  END;

  -- Dr. Shimaa Hagras (الترم الأول 2025): Move IS312 to Mon 13:00-15:00
  UPDATE doctor_schedule_slots s
  SET start_time = '13:00:00', end_time = '15:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_is312_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_shimaa AND s.day_of_week = 'Mon' AND s.start_time = '09:00:00';

  -- ==========================================
  -- C. General Normalization & Cleanup
  -- ==========================================
  
  -- Clean up duplicate offerings created by competing seeds (e.g., 014 vs 005b)
  -- If a course has multiple active sections taught by different doctors in the same semester,
  -- and they aren't explicitly co-taught (i.e. we only want 1 primary instructor for these basic courses).
  FOR r IN 
    SELECT c.id as course_id
    FROM courses c
    WHERE c.code IN ('BS113', 'CS415', 'IS212', 'UNV111')
  LOOP
    SELECT id INTO v_keep_id FROM course_offerings WHERE course_id = r.course_id AND semester_id = v_spring2026_id AND section_label = 'Main' LIMIT 1;
    SELECT id INTO v_delete_id FROM course_offerings WHERE course_id = r.course_id AND semester_id = v_spring2026_id AND section_label = 'A' LIMIT 1;

    IF v_keep_id IS NOT NULL AND v_delete_id IS NOT NULL THEN
      -- Move enrollments first, ignoring duplicates
      UPDATE enrollments SET offering_id = v_keep_id WHERE offering_id = v_delete_id AND student_id NOT IN (SELECT student_id FROM enrollments WHERE offering_id = v_keep_id);
      DELETE FROM enrollments WHERE offering_id = v_delete_id; -- delete remaining duplicate enrollments
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_keep_id) WHERE id = v_keep_id;
      DELETE FROM doctor_schedule_slots WHERE offering_id = v_delete_id;
      DELETE FROM course_offerings WHERE id = v_delete_id;
    END IF;
  END LOOP;
  -- Fix any course lacking a time slot dynamically to avoid overlaps
  DECLARE
    v_days TEXT[] := ARRAY['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
    v_start_times TIME[] := ARRAY['07:00:00'::TIME, '09:00:00'::TIME, '11:00:00'::TIME, '13:00:00'::TIME, '15:00:00'::TIME];
    r_offering RECORD;
    v_day TEXT;
    v_start TIME;
    v_assigned BOOLEAN;
  BEGIN
    FOR r_offering IN 
      SELECT co.id as offering_id, co.doctor_id
      FROM course_offerings co
      WHERE co.is_active = TRUE 
        AND NOT EXISTS (SELECT 1 FROM doctor_schedule_slots s WHERE s.offering_id = co.id)
    LOOP
      v_assigned := FALSE;
      FOR d IN 1..6 LOOP
        FOR t IN 1..5 LOOP
          v_day := v_days[d];
          v_start := v_start_times[t];
          -- Check if doctor is free
          IF NOT EXISTS (
            SELECT 1 FROM doctor_schedule_slots s 
            JOIN course_offerings co2 ON s.offering_id = co2.id
            WHERE co2.doctor_id = r_offering.doctor_id 
              AND s.day_of_week = v_day 
              AND s.start_time = v_start
          ) THEN
            INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
            VALUES (r_offering.offering_id, v_day, v_start, v_start + interval '2 hours', 'Central Hall (Online)', 'lecture');
            v_assigned := TRUE;
            EXIT;
          END IF;
        END LOOP;
        EXIT WHEN v_assigned;
      END LOOP;
    END LOOP;
  END;

  INSERT INTO migration_logs (filename) VALUES ('020_final_db_cleanup.sql') ON CONFLICT DO NOTHING;
END $$;
