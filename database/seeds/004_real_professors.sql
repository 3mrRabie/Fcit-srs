-- =============================================================================
-- Seed 004: Real Professors & Official Timetable Schedule
-- Source: FCIT Official Timetable PDF (All Years, All Specializations)
-- Professors: 18 total (1 existing demo updated + 17 new)
-- Password for all doctors: Doctor@2026!
-- BCrypt hash (10 rounds): $2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW
-- =============================================================================

ALTER TABLE course_offerings ADD COLUMN IF NOT EXISTS section_label VARCHAR(50) DEFAULT 'Main';
ALTER TABLE course_offerings DROP CONSTRAINT IF EXISTS course_offerings_semester_id_course_id_key;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'course_offerings_semester_id_course_id_section_key'
  ) THEN
    ALTER TABLE course_offerings ADD CONSTRAINT course_offerings_semester_id_course_id_section_key UNIQUE (semester_id, course_id, section_label);
  END IF;
END $$;

DO $$
DECLARE
  v_fall2025_id    INT;
  v_spring2026_id  INT;
  v_cs_dept        INT;
  v_is_dept        INT;
  v_it_dept        INT;
  v_se_dept        INT;
  
  v_dr_ahmed       UUID;   -- Dr. Ahmed Selim        (…000000002, existing)
  v_dr_aida        UUID;   -- Dr. Aida Nasr          (…000000010)
  v_dr_osama       UUID;   -- Dr. Osama Ghoneim      (…000000011)
  v_dr_omnia       UUID;   -- Assoc.Prof. Omnia El Barbary (…000000012)
  v_dr_nancy       UUID;   -- Prof. Nancy Al-Hafnawi (…000000013)
  v_dr_shimaa      UUID;   -- Dr. Shimaa Hagras      (…000000014)
  v_dr_walid_s     UUID;   -- Dr. Walid Samir        (…000000015)
  v_dr_mostafa     UUID;   -- Dr. Mostafa Al-Ashri   (…000000016)
  v_dr_arwa        UUID;   -- Dr. Arwa Abu Al-Wafa   (…000000017)
  v_dr_hanaa_h     UUID;   -- Dr. Hanaa Abd Al-Hadi  (…000000018)
  v_dr_hanaa_e     UUID;   -- Dr. Hanaa Eissa        (…000000019)
  v_dr_marian      UUID;   -- Dr. Marian Wagdy       (…000000020)
  v_dr_walid_k     UUID;   -- Dr. Walid Abd Al-Khaliq(…000000021)
  v_dr_hany        UUID;   -- Dr. Hany Al-Ghayesh    (…000000022)
  v_dr_tahani      UUID;   -- Dr. Tahani Allam       (…000000023)
  v_dr_ibrahim     UUID;   -- Dr. Ibrahim Gad        (…000000024)
  v_dr_iman        UUID;   -- Assoc.Prof. Iman El Baqari (…000000025)
  v_dr_marwa       UUID;   -- Dr. Marwa Salama       (…000000026)
  
  v_offering_id    INT;
  v_active_offering_ids INT[] := ARRAY[]::INT[];
BEGIN
  IF EXISTS (SELECT 1 FROM seed_logs WHERE seed_name = '004_real_professors.sql') THEN
    RAISE NOTICE 'Seed 004 already applied, skipping execution.';
    RETURN;
  END IF;

  -- Resolve foreign keys
  SELECT id INTO v_fall2025_id   FROM semesters WHERE label = 'Fall 2025';
  SELECT id INTO v_spring2026_id FROM semesters WHERE label = 'Spring 2026';
  SELECT id INTO v_cs_dept FROM departments WHERE code = 'CS';
  SELECT id INTO v_is_dept FROM departments WHERE code = 'IS';
  SELECT id INTO v_it_dept FROM departments WHERE code = 'IT';
  SELECT id INTO v_se_dept FROM departments WHERE code = 'SE';

  -- ── 1. Clean up retired data and update demo doctor ──────────────────
  -- Remove duplicate Dr. Arwa Essam if she exists
  DELETE FROM course_offerings WHERE doctor_id = (SELECT id FROM doctors WHERE user_id = '00000000-0000-0000-0000-000000000027');
  DELETE FROM doctors WHERE user_id = '00000000-0000-0000-0000-000000000027';
  DELETE FROM users WHERE id = '00000000-0000-0000-0000-000000000027';

  UPDATE users SET
    full_name_ar = 'د. أحمد سليم',
    full_name_en = 'Dr. Ahmed Selim',
    national_id  = '19750310112233'
  WHERE id = '00000000-0000-0000-0000-000000000002';

  UPDATE doctors SET
    academic_title  = 'Dr.',
    department_id   = v_cs_dept,
    office_location = 'Building A, Room 201',
    specialization  = 'Artificial Intelligence & Data Science'
  WHERE user_id = '00000000-0000-0000-0000-000000000002';

  SELECT id INTO v_dr_ahmed FROM doctors WHERE user_id = '00000000-0000-0000-0000-000000000002';

  -- ── 2. INSERT 17 new doctor users ─────────────────────────────────────
  INSERT INTO users (id, email, password_hash, role, full_name_ar, full_name_en, national_id, phone, must_change_pw, is_active)
  VALUES
    ('00000000-0000-0000-0000-000000000010', 'dr.aida@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. أيدة نصر', 'Dr. Aida Nasr', '19780215223344', '01011112233', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000011', 'dr.osama.g@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. أسامة غنيم', 'Dr. Osama Ghoneim', '19790315223344', '01011112234', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000012', 'dr.omnia@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'أ.م.د. أمنية البربري', 'Assoc. Prof. Omnia El Barbary', '19800415223344', '01011112235', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000013', 'dr.nancy@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'أ.د. نانسي الحفناوي', 'Prof. Nancy Al-Hafnawi', '19750515223344', '01011112236', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000014', 'dr.shimaa@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. شيماء هجرس', 'Dr. Shimaa Hagras', '19810615223344', '01011112237', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000015', 'dr.walid.s@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. وليد سمير', 'Dr. Walid Samir', '19820715223344', '01011112238', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000016', 'dr.mostafa@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. مصطفى العشري', 'Dr. Mostafa Al-Ashri', '19830815223344', '01011112239', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000017', 'dr.arwa@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. أروى أبو الوفا', 'Dr. Arwa Abu Al-Wafa', '19840915223344', '01011112240', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000018', 'dr.hanaa.h@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. هناء عبد الهادي', 'Dr. Hanaa Abd Al-Hadi', '19851015223344', '01011112241', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000019', 'dr.hanaa.e@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. هناء عيسى', 'Dr. Hanaa Eissa', '19861115223344', '01011112242', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000020', 'dr.marian@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. مريان وجدي', 'Dr. Marian Wagdy', '19871215223344', '01011112243', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000021', 'dr.walid.k@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. وليد عبد الخالق', 'Dr. Walid Abd Al-Khaliq', '19880115223344', '01011112244', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000022', 'dr.hany@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. هاني الغايش', 'Dr. Hany Al-Ghayesh', '19890215223344', '01011112245', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000023', 'dr.tahani@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. تهاني علام', 'Dr. Tahani Allam', '19900315223344', '01011112246', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000024', 'dr.ibrahim@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. إبراهيم جاد', 'Dr. Ibrahim Gad', '19910415223344', '01011112247', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000025', 'dr.iman.b@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'أ.م.د. إيمان البقري', 'Assoc. Prof. Iman El Baqari', '19920515223344', '01011112248', FALSE, TRUE),
    ('00000000-0000-0000-0000-000000000026', 'dr.marwa@fci.tanta.edu.eg', '$2b$10$cOqt6YZKmMqMr6noJ5ymiu7D6T08JdSNlVT3dXyM9f/.y9WHgT7tW', 'doctor', 'د. مروة سلامة', 'Dr. Marwa Salama', '19930615223344', '01011112249', FALSE, TRUE)
  ON CONFLICT (id) DO UPDATE SET 
    email = EXCLUDED.email, 
    full_name_ar = EXCLUDED.full_name_ar, 
    full_name_en = EXCLUDED.full_name_en;

  -- ── 3. INSERT doctor profiles ──────────────────────────────────────────
  INSERT INTO doctors (user_id, academic_title, department_id, office_location, specialization)
  VALUES
    ('00000000-0000-0000-0000-000000000010', 'Dr.', v_cs_dept, 'Building B, Room 101', 'Electronics, Cybersecurity, Signals'),
    ('00000000-0000-0000-0000-000000000011', 'Dr.', v_cs_dept, 'Building B, Room 102', 'CS Fundamentals, OOP, HCI'),
    ('00000000-0000-0000-0000-000000000012', 'Assoc. Prof.', v_is_dept, 'Building B, Room 103', 'Information Systems, Databases'),
    ('00000000-0000-0000-0000-000000000013', 'Prof.', v_cs_dept, 'Building B, Room 104', 'Mathematics, Operations Research'),
    ('00000000-0000-0000-0000-000000000014', 'Dr.', v_is_dept, 'Building B, Room 105', 'IS Analysis, Data Science, Security'),
    ('00000000-0000-0000-0000-000000000015', 'Dr.', v_cs_dept, 'Building B, Room 106', 'English Language'),
    ('00000000-0000-0000-0000-000000000016', 'Dr.', v_cs_dept, 'Building B, Room 107', 'Algorithms, OS, Theory'),
    ('00000000-0000-0000-0000-000000000017', 'Dr.', v_se_dept, 'Building B, Room 108', 'Software Engineering'),
    ('00000000-0000-0000-0000-000000000018', 'Dr.', v_cs_dept, 'Building B, Room 109', 'Mathematics, HCI, Compilers'),
    ('00000000-0000-0000-0000-000000000019', 'Dr.', v_cs_dept, 'Building B, Room 110', 'Operating Systems'),
    ('00000000-0000-0000-0000-000000000020', 'Dr.', v_it_dept, 'Building B, Room 111', 'Networks, Multimedia, Image Processing'),
    ('00000000-0000-0000-0000-000000000021', 'Dr.', v_cs_dept, 'Building B, Room 112', 'AI, Big Data, Cloud, HPC'),
    ('00000000-0000-0000-0000-000000000022', 'Dr.', v_is_dept, 'Building B, Room 113', 'Network OS, IS Engineering'),
    ('00000000-0000-0000-0000-000000000023', 'Dr.', v_it_dept, 'Building B, Room 114', 'Microprocessors, Networks'),
    ('00000000-0000-0000-0000-000000000024', 'Dr.', v_is_dept, 'Building B, Room 115', 'Web IS, Data Management'),
    ('00000000-0000-0000-0000-000000000025', 'Assoc. Prof.', v_it_dept, 'Building B, Room 116', 'Robotics, SOA'),
    ('00000000-0000-0000-0000-000000000026', 'Dr.', v_it_dept, 'Building B, Room 117', 'Digital Signal Processing')
  ON CONFLICT (user_id) DO NOTHING;

  -- ── 4. Resolve doctor integer IDs ─────────────────────────────────────
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
  
  -- Create missing courses if any
  INSERT INTO courses (code, name_ar, name_en, credits, category, department_id, level, is_credit_bearing)
  VALUES ('UNV115', 'تسويق ومبيعات', 'Marketing & Sales', 2, 'university_req', v_cs_dept, 1, FALSE)
  ON CONFLICT (code) DO NOTHING;

  INSERT INTO courses (code, name_ar, name_en, credits, category, department_id, level, is_credit_bearing)
  VALUES ('IT444', 'الواقع الافتراضي', 'Virtual Reality', 3, 'elective', v_it_dept, 4, TRUE)
  ON CONFLICT (code) DO NOTHING;

  INSERT INTO courses (code, name_ar, name_en, credits, category, department_id, level, is_credit_bearing)
  VALUES ('IT417', 'معالجة الإشارات الرقمية', 'Digital Signal Processing', 3, 'applied_computing', v_it_dept, 4, TRUE)
  ON CONFLICT (code) DO NOTHING;

  INSERT INTO courses (code, name_ar, name_en, credits, category, department_id, level, is_credit_bearing)
  VALUES ('IS421', 'مواضيع متقدمة في نظم المعلومات', 'Advanced Topics in IS', 3, 'elective', v_is_dept, 4, TRUE)
  ON CONFLICT (code) DO NOTHING;

  -- ── 5. INSERT / UPDATE course_offerings ─────────────────────────────
  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='BS112'), v_dr_aida, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS112') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS111'), v_dr_osama, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS111') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS111'), v_dr_omnia, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS111') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='BS111'), v_dr_nancy, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS111') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='BS116'), v_dr_shimaa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS116') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='UNV113'), v_dr_walid_s, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='UNV113') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '13:00', '15:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='BS115'), v_dr_aida, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS115') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='UNV112'), v_dr_ahmed, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='UNV112') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='BS113'), v_dr_mostafa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS113') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='BS115'), v_dr_nancy, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Section 2')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS115') 
    AND semester_id=v_spring2026_id AND section_label='Section 2';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='UNV114'), v_dr_arwa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='UNV114') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='UNV111'), v_dr_shimaa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='UNV111') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS112'), v_dr_osama, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS112') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='BS114'), v_dr_hanaa_h, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS114') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='BS117'), v_dr_nancy, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='BS117') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '13:00', '15:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS211'), v_dr_osama, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS211') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='SE211'), v_dr_arwa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='SE211') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS212'), v_dr_mostafa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS212') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT211'), v_dr_aida, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT211') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '13:00', '15:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS211'), v_dr_omnia, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS211') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS214'), v_dr_hanaa_e, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS214') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT317'), v_dr_marian, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT317') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS212'), v_dr_nancy, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS212') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS213'), v_dr_osama, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS213') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT311'), v_dr_ahmed, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT311') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS313'), v_dr_ahmed, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS313') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS311'), v_dr_mostafa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS311') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS311'), v_dr_shimaa, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS311') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '11:00', '13:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS312'), v_dr_walid_k, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS312') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS331'), v_dr_osama, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS331') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS314'), v_dr_walid_k, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS314') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS332'), v_dr_ahmed, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS332') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS411'), v_dr_mostafa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS411') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='SE315'), v_dr_arwa, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='SE315') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS315'), v_dr_walid_k, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS315') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS316'), v_dr_ahmed, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS316') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '07:00', '09:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT321'), v_dr_hany, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT321') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  -- No schedule slot: time unspecified in timetable PDF

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT315'), v_dr_tahani, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT315') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT312'), v_dr_marian, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT312') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT314'), v_dr_aida, 50, '[]'::jsonb, 'Hall 2', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT314') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '09:00', '11:00', 'Hall 2', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT319'), v_dr_marian, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT319') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT322'), v_dr_aida, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT322') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '11:00', '13:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT318'), v_dr_arwa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT318') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT317'), v_dr_tahani, 80, '[]'::jsonb, 'Online', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT317') 
    AND semester_id=v_spring2026_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT316'), v_dr_marian, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT316') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '15:00', '17:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS314'), v_dr_ahmed, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS314') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '09:00', '11:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS313'), v_dr_hany, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS313') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '11:00', '13:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS311'), v_dr_shimaa, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS311') 
    AND semester_id=v_fall2025_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '11:00', '13:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS312'), v_dr_shimaa, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS312') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS351'), v_dr_omnia, 50, '[]'::jsonb, 'Hall 2', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS351') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '09:00', '11:00', 'Hall 2', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS315'), v_dr_shimaa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS315') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS317'), v_dr_ibrahim, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS317') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS321'), v_dr_shimaa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS321') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS318'), v_dr_omnia, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS318') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS314'), v_dr_omnia, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS314') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS321'), v_dr_hany, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS321') 
    AND semester_id=v_spring2026_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '11:00', '13:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS315'), v_dr_walid_k, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS315') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '09:00', '11:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS443'), v_dr_marian, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS443') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '11:00', '13:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='SE321'), v_dr_ahmed, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='SE321') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '09:00', '11:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS434'), v_dr_walid_k, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS434') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS413'), v_dr_hanaa_h, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS413') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS331'), v_dr_hanaa_h, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS331') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS416'), v_dr_hanaa_h, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS416') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '07:00', '09:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS415'), v_dr_walid_k, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS415') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='CS433'), v_dr_mostafa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS433') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '13:00', '15:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT415'), v_dr_arwa, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT415') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT315'), v_dr_tahani, 80, '[]'::jsonb, 'Online', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT315') 
    AND semester_id=v_fall2025_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '11:00', '13:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='CS315'), v_dr_walid_k, 60, '[]'::jsonb, 'Central Hall (Lower)', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='CS315') 
    AND semester_id=v_fall2025_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '09:00', '11:00', 'Central Hall (Lower)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT444'), v_dr_marian, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT444') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '09:00', '11:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IT313'), v_dr_aida, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT313') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT319'), v_dr_marian, 60, '[]'::jsonb, 'Central Hall (Upper)', TRUE, 'Section B')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT319') 
    AND semester_id=v_spring2026_id AND section_label='Section B';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '09:00', '11:00', 'Central Hall (Upper)', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT414'), v_dr_aida, 50, '[]'::jsonb, 'Hall 2', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT414') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Hall 2', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT413'), v_dr_arwa, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT413') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '11:00', '13:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT314'), v_dr_marwa, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT314') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '09:00', '11:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IT411'), v_dr_iman, 50, '[]'::jsonb, 'Hall 2', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IT411') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Wed', '09:00', '11:00', 'Hall 2', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS341'), v_dr_ibrahim, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS341') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS411'), v_dr_shimaa, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS411') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '07:00', '09:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_fall2025_id, (SELECT id FROM courses WHERE code='IS412'), v_dr_hany, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS412') 
    AND semester_id=v_fall2025_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sat', '11:00', '13:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS413'), v_dr_ibrahim, 80, '[]'::jsonb, 'Online', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS413') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Sun', '07:00', '09:00', 'Online', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS342'), v_dr_shimaa, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS342') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '09:00', '11:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS415'), v_dr_iman, 50, '[]'::jsonb, 'Hall 1', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS415') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Mon', '11:00', '13:00', 'Hall 1', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS414'), v_dr_shimaa, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS414') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Tue', '09:00', '11:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, schedule, room, is_active, section_label)
  VALUES (v_spring2026_id, (SELECT id FROM courses WHERE code='IS421'), v_dr_hany, 50, '[]'::jsonb, 'Hall 3', TRUE, 'Main')
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET doctor_id = EXCLUDED.doctor_id, capacity = EXCLUDED.capacity, room = EXCLUDED.room, is_active = TRUE;

  SELECT id INTO v_offering_id FROM course_offerings 
  WHERE course_id=(SELECT id FROM courses WHERE code='IS421') 
    AND semester_id=v_spring2026_id AND section_label='Main';

  v_active_offering_ids := array_append(v_active_offering_ids, v_offering_id);

  INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
  VALUES (v_offering_id, 'Thu', '11:00', '13:00', 'Hall 3', 'lecture')
  ON CONFLICT (offering_id, day_of_week, start_time)
  DO UPDATE SET end_time=EXCLUDED.end_time, room=EXCLUDED.room;

  -- ── 6. Deactivate orphaned offerings not in the timetable ────────────
  UPDATE course_offerings
  SET doctor_id = NULL, is_active = FALSE
  WHERE id != ALL(v_active_offering_ids);

  -- ── 7. Mark seed as complete ──────────────────────────────────────────
  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('004_real_professors.sql', 18);

  RAISE NOTICE 'Seed 004 complete — 18 real professors loaded';
END $$;

