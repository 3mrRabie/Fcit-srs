-- Migration 015: Fix instructor assignments for BS115 and IT111 in الترم الثاني 2026
DO $$ 
DECLARE
  v_semester_id INT;
  v_doc_aida UUID;
  v_bs115_id INT;
  v_it111_id INT;
BEGIN
  -- Get الترم الثاني 2026 semester
  SELECT id INTO v_semester_id FROM semesters WHERE label = 'الترم الثاني 2026';
  
  -- Get Dr. Aida's ID
  SELECT d.id INTO v_doc_aida FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.email = 'dr.aida@fci.tanta.edu.eg';
  
  -- Get Course IDs
  SELECT id INTO v_bs115_id FROM courses WHERE code = 'BS115';
  SELECT id INTO v_it111_id FROM courses WHERE code = 'IT111';

  IF v_semester_id IS NOT NULL AND v_doc_aida IS NOT NULL THEN
    -- Find the other offering for BS115 (Dr. Nancy's)
    DECLARE
      v_other_offering_id INT;
      v_aida_offering_id INT;
    BEGIN
      SELECT id INTO v_aida_offering_id FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_semester_id AND doctor_id = v_doc_aida LIMIT 1;
      SELECT id INTO v_other_offering_id FROM course_offerings WHERE course_id = v_bs115_id AND semester_id = v_semester_id AND doctor_id != v_doc_aida LIMIT 1;

      IF v_aida_offering_id IS NOT NULL AND v_other_offering_id IS NOT NULL THEN
        -- Move enrollments
        UPDATE enrollments SET offering_id = v_other_offering_id WHERE offering_id = v_aida_offering_id;
        -- Update enrolled counts
        UPDATE course_offerings SET enrolled_count = (SELECT COUNT(*) FROM enrollments WHERE offering_id = v_other_offering_id) WHERE id = v_other_offering_id;
        
        -- Delete Dr. Aida's offering for BS115
        DELETE FROM course_offerings WHERE id = v_aida_offering_id;
      END IF;
    END;

    -- Assign Dr. Aida to IT111 in الترم الثاني 2026
    UPDATE course_offerings 
    SET doctor_id = v_doc_aida 
    WHERE course_id = v_it111_id AND semester_id = v_semester_id AND (doctor_id IS NULL OR doctor_id != v_doc_aida);
    
    -- Ensure there's only one offering for BS115 (just in case there are other duplicate sections)
    -- Actually, we just deleted Aida's. Nancy's is still there. 
    -- The requirement is "remove one of them" which we did by deleting Aida's.
  END IF;

  INSERT INTO migration_logs (filename) VALUES ('015_fix_bs115_it111.sql') ON CONFLICT DO NOTHING;
END $$;
