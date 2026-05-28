-- Migration 016: Permanent Fix for Scheduling and Assignment Conflicts
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
  
  SELECT d.id INTO v_doc_aida FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Aida Nasr';
  SELECT d.id INTO v_doc_nancy FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Prof. Nancy Al-Hafnawi';
  SELECT d.id INTO v_doc_shimaa FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Shimaa Hagras';
  SELECT d.id INTO v_doc_hany FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Hany Al-Ghayesh';
  SELECT d.id INTO v_doc_ahmed FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Ahmed Selim';
  SELECT d.id INTO v_doc_ibrahim FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Ibrahim Gad';
  SELECT d.id INTO v_doc_marian FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.full_name_en = 'Dr. Marian Wagdy';
  
  SELECT id INTO v_bs115_id FROM courses WHERE code = 'BS115';
  SELECT id INTO v_is321_id FROM courses WHERE code = 'IS321';
  SELECT id INTO v_is315_id FROM courses WHERE code = 'IS315';
  SELECT id INTO v_cs313_id FROM courses WHERE code = 'CS313';
  SELECT id INTO v_se321_id FROM courses WHERE code = 'SE321';
  SELECT id INTO v_is413_id FROM courses WHERE code = 'IS413';
  SELECT id INTO v_it319_id FROM courses WHERE code = 'IT319';
  SELECT id INTO v_is312_id FROM courses WHERE code = 'IS312';

  -- ==========================================
  -- A. Duplicate Professor Fixes
  -- ==========================================
  
  -- BS115: Remove Dr. Aida, keep Prof. Nancy
  DECLARE
    v_aida_bs115_offering INT;
    v_nancy_bs115_offering INT;
  BEGIN
    SELECT id INTO v_aida_bs115_offering FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_aida LIMIT 1;
    SELECT id INTO v_nancy_bs115_offering FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_nancy LIMIT 1;

    IF v_aida_bs115_offering IS NOT NULL AND v_nancy_bs115_offering IS NOT NULL THEN
      UPDATE enrollments SET offering_id = v_nancy_bs115_offering WHERE offering_id = v_aida_bs115_offering;
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_nancy_bs115_offering) WHERE id = v_nancy_bs115_offering;
      
      -- Delete schedule slots associated with Aida's BS115 offering to prevent constraint errors
      DELETE FROM doctor_schedule_slots WHERE offering_id = v_aida_bs115_offering;
      DELETE FROM course_offerings WHERE id = v_aida_bs115_offering;
    END IF;
  END;

  -- IS321: Remove Dr. Shimaa, keep Dr. Hany. Assign Dr. Shimaa to IS315.
  DECLARE
    v_shimaa_is321_offering INT;
    v_hany_is321_offering INT;
  BEGIN
    SELECT id INTO v_shimaa_is321_offering FROM course_offerings WHERE course_id = v_is321_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_shimaa LIMIT 1;
    SELECT id INTO v_hany_is321_offering FROM course_offerings WHERE course_id = v_is321_id AND semester_id = v_spring2026_id AND doctor_id = v_doc_hany LIMIT 1;

    IF v_shimaa_is321_offering IS NOT NULL AND v_hany_is321_offering IS NOT NULL THEN
      UPDATE enrollments SET offering_id = v_hany_is321_offering WHERE offering_id = v_shimaa_is321_offering;
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_hany_is321_offering) WHERE id = v_hany_is321_offering;
      
      -- Dr. Shimaa is already assigned to IS315 (Data Warehousing) in الترم الثاني 2026.
      -- Delete her duplicate offering for IS321 and its schedule slots.
      DELETE FROM doctor_schedule_slots WHERE offering_id = v_shimaa_is321_offering;
      DELETE FROM course_offerings WHERE id = v_shimaa_is321_offering;
    END IF;
  END;

  -- ==========================================
  -- B. Overlapping Schedule Fixes
  -- ==========================================

  -- Dr. Ahmed Selim (الترم الأول 2025): Move CS313 to Sun 11:00-13:00, SE321 to Sun 13:00-15:00
  UPDATE doctor_schedule_slots s
  SET start_time = '11:00:00', end_time = '13:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_cs313_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_ahmed AND s.day_of_week = 'Sun' AND s.start_time = '07:00:00';

  UPDATE doctor_schedule_slots s
  SET start_time = '13:00:00', end_time = '15:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_se321_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_ahmed AND s.day_of_week = 'Sun' AND s.start_time = '09:00:00';

  -- Dr. Ibrahim Gad (الترم الثاني 2026): Move IS413 to Sun 09:00-11:00
  UPDATE doctor_schedule_slots s
  SET start_time = '09:00:00', end_time = '11:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_is413_id AND co.semester_id = v_spring2026_id AND co.doctor_id = v_doc_ibrahim AND s.day_of_week = 'Sun' AND s.start_time = '07:00:00';

  -- Dr. Marian Wagdy (الترم الثاني 2026): Move IT319 Section B to Sun 11:00-13:00
  UPDATE doctor_schedule_slots s
  SET start_time = '11:00:00', end_time = '13:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_it319_id AND co.semester_id = v_spring2026_id AND co.doctor_id = v_doc_marian AND co.section_label = 'Section B' AND s.day_of_week = 'Sun' AND s.start_time = '09:00:00';

  -- Dr. Shimaa Hagras (الترم الأول 2025): Move IS312 to Mon 13:00-15:00
  UPDATE doctor_schedule_slots s
  SET start_time = '13:00:00', end_time = '15:00:00'
  FROM course_offerings co
  WHERE s.offering_id = co.id AND co.course_id = v_is312_id AND co.semester_id = v_fall2025_id AND co.doctor_id = v_doc_shimaa AND s.day_of_week = 'Mon' AND s.start_time = '09:00:00';

  -- ==========================================
  -- C. 4 Extra Duplicates Cleanup (from script 014 vs 005b)
  -- ==========================================
  FOR r IN 
    SELECT c.id as course_id
    FROM courses c
    WHERE c.code IN ('BS113', 'CS415', 'IS212', 'UNV111')
  LOOP
    -- Find the 'Main' offering
    SELECT id INTO v_keep_id FROM course_offerings WHERE course_id = r.course_id AND semester_id = v_spring2026_id AND section_label = 'Main' LIMIT 1;
    -- Find the 'A' offering
    SELECT id INTO v_delete_id FROM course_offerings WHERE course_id = r.course_id AND semester_id = v_spring2026_id AND section_label = 'A' LIMIT 1;

    IF v_keep_id IS NOT NULL AND v_delete_id IS NOT NULL THEN
      -- Transfer enrollments
      UPDATE enrollments SET offering_id = v_keep_id WHERE offering_id = v_delete_id;
      UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_keep_id) WHERE id = v_keep_id;
      
      -- Delete schedule slots associated with 'A'
      DELETE FROM doctor_schedule_slots WHERE offering_id = v_delete_id;
      
      -- Delete the 'A' offering
      DELETE FROM course_offerings WHERE id = v_delete_id;
    END IF;
  END LOOP;

  INSERT INTO migration_logs (filename) VALUES ('016_fix_schedules_and_assignments.sql') ON CONFLICT DO NOTHING;
END $$;
