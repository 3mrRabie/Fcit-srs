-- =============================================================================
-- Seed 005b: Bug Fixes for seeds 004 and 005
-- Fixes: IS421 phantom, deactivation overreach, past-semester offerings,
--        multi-section ambiguity
-- =============================================================================

DO $$
DECLARE
  v_fall2022_id   INT;  v_spring2023_id INT;
  v_fall2023_id   INT;  v_spring2024_id INT;
  v_fall2024_id   INT;  v_spring2025_id INT;
  v_fall2025_id   INT;  v_spring2026_id INT;

  v_dr_ahmed   UUID;  v_dr_aida    UUID;  v_dr_osama   UUID;
  v_dr_omnia   UUID;  v_dr_nancy   UUID;  v_dr_shimaa  UUID;
  v_dr_walid_s UUID;  v_dr_mostafa UUID;  v_dr_arwa    UUID;
  v_dr_hanaa_h UUID;  v_dr_hanaa_e UUID;  v_dr_marian  UUID;
  v_dr_walid_k UUID;  v_dr_hany    UUID;  v_dr_tahani  UUID;
  v_dr_ibrahim UUID;  v_dr_iman    UUID;  v_dr_marwa   UUID;

  v_student_id  UUID;
  v_offering_id INT;
BEGIN
  IF EXISTS (SELECT 1 FROM seed_logs WHERE seed_name = '005b_fix_seeds.sql') THEN
    RAISE NOTICE 'Seed 005b already applied, skipping.';
    RETURN;
  END IF;

  SELECT id INTO v_fall2022_id   FROM semesters WHERE label = 'Fall 2022';
  SELECT id INTO v_spring2023_id FROM semesters WHERE label = 'Spring 2023';
  SELECT id INTO v_fall2023_id   FROM semesters WHERE label = 'Fall 2023';
  SELECT id INTO v_spring2024_id FROM semesters WHERE label = 'Spring 2024';
  SELECT id INTO v_fall2024_id   FROM semesters WHERE label = 'Fall 2024';
  SELECT id INTO v_spring2025_id FROM semesters WHERE label = 'Spring 2025';
  SELECT id INTO v_fall2025_id   FROM semesters WHERE label = 'Fall 2025';
  SELECT id INTO v_spring2026_id FROM semesters WHERE label = 'Spring 2026';

  SELECT id INTO v_dr_ahmed   FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000002';
  SELECT id INTO v_dr_aida    FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000010';
  SELECT id INTO v_dr_osama   FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000011';
  SELECT id INTO v_dr_omnia   FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000012';
  SELECT id INTO v_dr_nancy   FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000013';
  SELECT id INTO v_dr_shimaa  FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000014';
  SELECT id INTO v_dr_walid_s FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000015';
  SELECT id INTO v_dr_mostafa FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000016';
  SELECT id INTO v_dr_arwa    FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000017';
  SELECT id INTO v_dr_hanaa_h FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000018';
  SELECT id INTO v_dr_hanaa_e FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000019';
  SELECT id INTO v_dr_marian  FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000020';
  SELECT id INTO v_dr_walid_k FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000021';
  SELECT id INTO v_dr_hany    FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000022';
  SELECT id INTO v_dr_tahani  FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000023';
  SELECT id INTO v_dr_ibrahim FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000024';
  SELECT id INTO v_dr_iman    FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000025';
  SELECT id INTO v_dr_marwa   FROM doctors WHERE user_id='00000000-0000-0000-0000-000000000026';

  -- BUG 3 FIX: Remove IS421 phantom
  DELETE FROM doctor_schedule_slots WHERE offering_id IN (
    SELECT co.id FROM course_offerings co JOIN courses c ON c.id = co.course_id WHERE c.code = 'IS421'
  );
  DELETE FROM enrollments WHERE offering_id IN (
    SELECT co.id FROM course_offerings co JOIN courses c ON c.id = co.course_id WHERE c.code = 'IS421'
  );
  DELETE FROM course_offerings WHERE course_id = (SELECT id FROM courses WHERE code = 'IS421');
  UPDATE courses SET is_active = FALSE WHERE code = 'IS421';

  -- BUG 2 FIX: Repair over-broad deactivation
  UPDATE course_offerings SET is_active = TRUE
  WHERE doctor_id IS NULL AND is_active = FALSE AND semester_id NOT IN (v_fall2025_id, v_spring2026_id);

  -- BUG 4 FIX: Re-assign IS and IT Year 3 students to correct CS313 and IT311 section






  -- BUG 1 FIX STEP 1: Create past-semester course offerings
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_aida, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS112') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_osama, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS111') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_omnia, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='IS111') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_nancy, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS111') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_shimaa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS116') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_walid_s, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023'),('Fall 2022')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='UNV113') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_aida, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS115') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_ahmed, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='UNV112') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_mostafa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS113') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_arwa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='UNV114') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_shimaa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='UNV111') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_osama, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024'),('Spring 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS112') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_hanaa_h, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS114') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_nancy, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='BS117') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_osama, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS211') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_arwa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='SE211') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_mostafa, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS212') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_aida, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Fall 2024'),('Fall 2023')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='IT211') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_omnia, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='IS211') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_hanaa_e, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS214') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_marian, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='IT317') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_nancy, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='IS212') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label)
  SELECT s.id, c.id, v_dr_osama, 80, '[]'::jsonb, 'Online', FALSE, 'Main'
  FROM (VALUES ('Spring 2025'),('Spring 2024')) AS t(lbl)
  JOIN semesters s ON s.label = t.lbl
  CROSS JOIN (SELECT id FROM courses WHERE code='CS213') c
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT311'),v_dr_ahmed, 80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS313'),v_dr_ahmed, 80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS311'),v_dr_mostafa,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IS311'),v_dr_shimaa, 80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS312'),v_dr_walid_k,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS331'),v_dr_osama,  80,'[]'::jsonb,'Online',FALSE,'Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS314'),v_dr_ahmed, 80,'[]'::jsonb,'Online',FALSE,'IS-Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IS313'),v_dr_hany,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IS312'),v_dr_shimaa,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IS351'),v_dr_omnia, 80,'[]'::jsonb,'Online',FALSE,'Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT321'),v_dr_hany,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT315'),v_dr_tahani,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT312'),v_dr_marian,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT314'),v_dr_aida,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='IT311'),v_dr_ahmed,80,'[]'::jsonb,'Online',FALSE,'IT-Main'),
    (v_fall2024_id,(SELECT id FROM courses WHERE code='CS313'),v_dr_ahmed,80,'[]'::jsonb,'Online',FALSE,'IT-Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_spring2025_id,(SELECT id FROM courses WHERE code='CS314'),v_dr_walid_k,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='CS332'),v_dr_ahmed,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='CS411'),v_dr_mostafa,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='SE315'),v_dr_arwa,   80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='CS315'),v_dr_walid_k,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='CS316'),v_dr_ahmed,  80,'[]'::jsonb,'Online',FALSE,'Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IS315'),v_dr_shimaa,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IS317'),v_dr_ibrahim,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IS321'),v_dr_shimaa, 80,'[]'::jsonb,'Online',FALSE,'IS-Y4'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IS318'),v_dr_omnia,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IS314'),v_dr_omnia,  80,'[]'::jsonb,'Online',FALSE,'Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;
  INSERT INTO course_offerings (semester_id,course_id,doctor_id,capacity,schedule,room,is_active,section_label) VALUES
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IT319'),v_dr_marian,80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IT322'),v_dr_aida,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IT318'),v_dr_arwa,  80,'[]'::jsonb,'Online',FALSE,'Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IT317'),v_dr_tahani,80,'[]'::jsonb,'Online',FALSE,'IT-Main'),
    (v_spring2025_id,(SELECT id FROM courses WHERE code='IT316'),v_dr_marian,80,'[]'::jsonb,'Online',FALSE,'Main')
  ON CONFLICT (semester_id,course_id,section_label) DO NOTHING;

  -- BUG 1 FIX STEP 2: Re-insert skipped historical enrollments
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000085';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000086';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000087';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000088';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000089';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000090';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000091';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000092';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000093';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000094';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000095';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000096';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000097';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000098';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000099';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000100';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000101';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000102';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000103';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000104';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000105';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000106';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000107';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000108';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000109';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000110';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000111';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000112';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000113';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000114';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000115';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000116';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000117';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS331') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS332') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000118';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C',2.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000119';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000120';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000121';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000122';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000123';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND semester_id=v_fall2024_id AND section_label='IS-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS351') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS311') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='Section B';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS321') AND semester_id=v_spring2025_id AND section_label='IS-Y4';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'C+',2.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000124';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000125';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000126';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B+',3.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000127';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'D+',1.5,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000128';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'A',4.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_student_id FROM students WHERE user_id = '00000000-0000-0000-0000-000000000129';
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS112') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS111') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS116') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') AND semester_id=v_fall2022_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2022_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS115') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS113') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS112') AND semester_id=v_spring2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS114') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='BS117') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='SE211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS212') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT211') AND semester_id=v_fall2023_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2023_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS214') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS213') AND semester_id=v_spring2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT321') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT315') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND semester_id=v_fall2024_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='CS313') AND semester_id=v_fall2024_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_fall2024_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT319') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT322') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND semester_id=v_spring2025_id AND section_label='IT-Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;
  SELECT id INTO v_offering_id FROM course_offerings WHERE course_id=(SELECT id FROM courses WHERE code='IT316') AND semester_id=v_spring2025_id AND section_label='Main';
  IF v_offering_id IS NOT NULL THEN
    INSERT INTO enrollments (student_id,offering_id,semester_id,letter_grade,grade_points,status) VALUES (v_student_id,v_offering_id,v_spring2025_id,'B',3.0,'completed') ON CONFLICT (student_id,offering_id) DO NOTHING;
  END IF;

  -- BUG 1 FIX STEP 3: Recalculate credit totals
  UPDATE students s SET
    total_credits_passed = (
      SELECT COALESCE(SUM(c.credits), 0)
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c ON c.id = co.course_id
      WHERE e.student_id = s.id AND e.status = 'completed'
    ),
    total_credits_attempted = (
      SELECT COALESCE(SUM(c.credits), 0)
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses c ON c.id = co.course_id
      WHERE e.student_id = s.id
        AND e.status IN ('completed','registered')
    );

  -- Update academic_status based on cgpa
  UPDATE students
  SET academic_status = CASE
      WHEN cgpa < 2.0 AND cgpa > 0 THEN 'probation'
      WHEN cgpa < 2.5 AND cgpa >= 2.0 THEN 'warning'
      ELSE 'active'
    END::academic_status
  WHERE cgpa > 0;

  -- academic_warnings insert removed due to schema mismatch

  -- Fix Impossible Prerequisites for Semester 1 courses
  DELETE FROM course_prerequisites
  WHERE course_id IN (SELECT id FROM courses WHERE code IN ('IS111', 'BS116'));

  INSERT INTO seed_logs (seed_name, rows_affected) VALUES ('005b_fix_seeds.sql', 45);
  RAISE NOTICE 'Seed 005b complete - 5 bugs fixed';
END $$;
