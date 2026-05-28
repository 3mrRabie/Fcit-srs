DO $$
DECLARE
  v_spring2026_id INT;
  r RECORD;
  v_keep_id INT;
  v_delete_id INT;
BEGIN
  SELECT id INTO v_spring2026_id FROM semesters WHERE label = 'الترم الثاني 2026';

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
END $$;
