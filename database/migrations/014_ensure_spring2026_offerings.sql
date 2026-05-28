-- =============================================================================
-- Migration 014: Ensure الترم الثاني 2026 course offerings exist
-- Root-cause fix: seed 003 inserts الترم الثاني 2026 offerings without ON CONFLICT,
-- so a single duplicate key (e.g. from a partially-applied earlier run) rolls
-- back the ENTIRE الترم الثاني 2026 block silently, leaving the semester with zero
-- active offerings.  Also fixes any NULL section_label values left behind by
-- old schema versions that didn't have the column default.
-- Safe to re-run: every INSERT uses ON CONFLICT DO UPDATE so the migration is
-- fully idempotent.
-- =============================================================================

DO $$
DECLARE
  v_semester_id  INT;
  v_doc_default  UUID;        -- fallback doctor (demo doctor from seed 001)
  v_doc_osama    UUID;        -- Dr. Osama Ghoneim  (CS courses)
  v_doc_omnia    UUID;        -- Assoc. Prof. Omnia (IS courses)
  v_doc_walid_s  UUID;        -- Dr. Walid Samir    (IT courses)
  v_doc_arwa     UUID;        -- Dr. Arwa Abu Al-Wafa (SE courses)
  v_doc_mostafa  UUID;        -- Dr. Mostafa Al-Ashri (advanced CS)
  v_doc_aida     UUID;        -- Dr. Aida Nasr      (BS/UNV courses)
  v_doc_nancy    UUID;        -- Prof. Nancy Al-Hafnawi (BS courses)
BEGIN
  IF EXISTS (
    SELECT 1 FROM migration_logs WHERE filename = '014_ensure_spring2026_offerings.sql'
  ) THEN
    RAISE NOTICE '014_ensure_spring2026_offerings.sql already applied, skipping.';
    RETURN;
  END IF;

  -- ── 1. Resolve the الترم الثاني 2026 semester ──────────────────────────────────
  SELECT id INTO v_semester_id FROM semesters WHERE label = 'الترم الثاني 2026';
  IF v_semester_id IS NULL THEN
    RAISE WARNING '014: الترم الثاني 2026 semester not found — skipping.';
    RETURN;
  END IF;

  -- ── 2. Ensure الترم الثاني 2026 is open for registration ───────────────────────
  UPDATE semesters
  SET status = 'registration'
  WHERE id = v_semester_id
    AND status NOT IN ('registration', 'active');

  -- ── 3. Resolve doctors (fall back to NULL if a doctor is not yet seeded) ──
  SELECT d.id INTO v_doc_default
  FROM doctors d WHERE d.user_id = '00000000-0000-0000-0000-000000000002';

  SELECT d.id INTO v_doc_osama
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.osama.g@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_aida
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.aida@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_omnia
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.omnia@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_nancy
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.nancy@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_walid_s
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.walid.s@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_mostafa
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.mostafa@fci.tanta.edu.eg' LIMIT 1;

  SELECT d.id INTO v_doc_arwa
  FROM doctors d JOIN users u ON u.id = d.user_id
  WHERE u.email = 'dr.arwa@fci.tanta.edu.eg' LIMIT 1;

  -- الترم الأول back to demo doctor for any unresolved doctor
  v_doc_osama   := COALESCE(v_doc_osama,   v_doc_default);
  v_doc_aida    := COALESCE(v_doc_aida,    v_doc_default);
  v_doc_omnia   := COALESCE(v_doc_omnia,   v_doc_default);
  v_doc_nancy   := COALESCE(v_doc_nancy,   v_doc_default);
  v_doc_walid_s := COALESCE(v_doc_walid_s, v_doc_default);
  v_doc_mostafa := COALESCE(v_doc_mostafa, v_doc_default);
  v_doc_arwa    := COALESCE(v_doc_arwa,    v_doc_default);

  -- ── 4. Fix NULL section_label on any existing الترم الثاني 2026 offerings ───────
  UPDATE course_offerings
  SET section_label = 'A'
  WHERE semester_id = v_semester_id
    AND (section_label IS NULL OR section_label = '');

  -- ── 5. Upsert all الترم الثاني 2026 course offerings ───────────────────────────
  -- ON CONFLICT (semester_id, course_id, section_label) DO UPDATE ensures the
  -- offering is re-activated and assigned a doctor if it was previously dead.

  -- ── Year 1 courses (both terms offered every semester for repeaters) ──────
  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, doc.doctor_id, d.cap, 'A', TRUE
  FROM (VALUES
    ('CS111', 60), ('CS112', 60),
    ('IS111', 60), ('IT111', 60),
    ('BS111', 60), ('BS113', 60), ('BS116', 60),
    ('UNV111', 120), ('UNV113', 120)
  ) AS d(code, cap)
  JOIN courses c ON c.code = d.code AND c.is_active = TRUE
  CROSS JOIN (SELECT v_doc_osama AS doctor_id) AS doc
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active  = TRUE,
                doctor_id  = EXCLUDED.doctor_id,
                capacity   = GREATEST(course_offerings.capacity, EXCLUDED.capacity);

  -- ── Year 2 Term 1 courses ─────────────────────────────────────────────────
  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_osama, 55, 'A', TRUE
  FROM courses c WHERE c.code IN ('CS211','CS212','CS213') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_aida, 60, 'A', TRUE
  FROM courses c WHERE c.code IN ('BS114','BS117') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_omnia, 55, 'A', TRUE
  FROM courses c WHERE c.code IN ('IS211','IS212') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_walid_s, 55, 'A', TRUE
  FROM courses c WHERE c.code = 'IT211' AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_arwa, 55, 'A', TRUE
  FROM courses c WHERE c.code = 'SE211' AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  -- ── Year 3 courses ────────────────────────────────────────────────────────
  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_mostafa, 50, 'A', TRUE
  FROM courses c WHERE c.code IN ('CS311','CS313') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_omnia, 50, 'A', TRUE
  FROM courses c WHERE c.code IN ('IS311','IS312') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_arwa, 50, 'A', TRUE
  FROM courses c WHERE c.code IN ('SE311','SE313') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_walid_s, 50, 'A', TRUE
  FROM courses c WHERE c.code = 'IT311' AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  -- ── Year 4 courses ────────────────────────────────────────────────────────
  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_mostafa, 45, 'A', TRUE
  FROM courses c WHERE c.code IN ('CS411','CS412','CS414','CS415') AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  INSERT INTO course_offerings (semester_id, course_id, doctor_id, capacity, section_label, is_active)
  SELECT v_semester_id, c.id, v_doc_osama, 30, 'A', TRUE
  FROM courses c WHERE c.code = 'PR411' AND c.is_active = TRUE
  ON CONFLICT (semester_id, course_id, section_label)
  DO UPDATE SET is_active = TRUE,
                doctor_id = EXCLUDED.doctor_id;

  -- ── 6. Log and report ─────────────────────────────────────────────────────
  INSERT INTO migration_logs (filename)
  VALUES ('014_ensure_spring2026_offerings.sql')
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '014: الترم الثاني 2026 offerings ensured for semester id=%.', v_semester_id;
END $$;
