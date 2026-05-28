-- =============================================================================
-- Migration 015: Fix Course Prerequisites, Add Missing IT212, Correct Names
-- =============================================================================
-- Verified against bylaw images and generate_bylaw.js source of truth.
-- Changes:
--   1. Add missing IT212 (Computer network Technology) course
--   2. Fix IS212 Arabic name: أساليب التحسين → طرق الأمثلية
--   3. Fix 27 wrong prerequisites across IS, CS, and IT programs
-- =============================================================================

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '015_fix_course_prerequisites.sql'
  ) THEN
    RAISE NOTICE '015 already applied, skipping.';
    RETURN;
  END IF;

  -- ===========================================================================
  -- 1. Add missing IT212 — Computer network Technology
  --    (basic_computing, level 2, prerequisite: CS111)
  -- ===========================================================================
  INSERT INTO courses (code, name_ar, name_en, credits, category, department_id, level, is_mandatory)
  SELECT
    'IT212',
    'تكنولوجيا شبكات الحاسب',
    'Computer network Technology',
    3,
    'basic_computing',
    (SELECT id FROM departments WHERE code = 'IT'),
    2,
    TRUE
  WHERE NOT EXISTS (SELECT 1 FROM courses WHERE code = 'IT212');

  -- ===========================================================================
  -- 2. Fix IS212 Arabic name
  -- ===========================================================================
  UPDATE courses
  SET name_ar = 'طرق الأمثلية',
      name_en = 'Optimization Methods'
  WHERE code = 'IS212';

  -- ===========================================================================
  -- 3. Delete all incorrect prerequisites that need to be replaced
  -- ===========================================================================
  DELETE FROM course_prerequisites
  WHERE course_id IN (
    SELECT id FROM courses WHERE code IN (
      'IS211','IS212',
      'IS313','IS314','IS315','IS316','IS317','IS411','IS413',
      'CS311','CS312','CS314','CS411','CS412','CS413','CS415','CS416',
      'IT311','IT312','IT313','IT314','IT316','IT317','IT318',
      'IT413','IT415',
      'SE315'
    )
  );

  -- ===========================================================================
  -- 4. Insert all correct prerequisites
  -- ===========================================================================

  -- ── College-wide basic computing chain ──────────────────────────────────────
  -- IS211 (Introduction to Database Systems) ← IS111
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS211'),
    (SELECT id FROM courses WHERE code = 'IS111')
  ) ON CONFLICT DO NOTHING;

  -- IS212 (Optimization Methods / طرق الأمثلية) ← BS113 (Math 2)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS212'),
    (SELECT id FROM courses WHERE code = 'BS113')
  ) ON CONFLICT DO NOTHING;

  -- IT212 (Computer network Technology) ← CS111
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT212'),
    (SELECT id FROM courses WHERE code = 'CS111')
  ) ON CONFLICT DO NOTHING;

  -- ── CS program ──────────────────────────────────────────────────────────────
  -- CS311 (Computer Security) ← IT212
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS311'),
    (SELECT id FROM courses WHERE code = 'IT212')
  ) ON CONFLICT DO NOTHING;

  -- CS312 (Computer Organization and Architecture) ← IT211
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS312'),
    (SELECT id FROM courses WHERE code = 'IT211')
  ) ON CONFLICT DO NOTHING;

  -- CS314 (Machine Learning) ← CS211 (OOP)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS314'),
    (SELECT id FROM courses WHERE code = 'CS211')
  ) ON CONFLICT DO NOTHING;

  -- CS411 (Computation Theory) ← BS112 (Discrete Mathematics)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS411'),
    (SELECT id FROM courses WHERE code = 'BS112')
  ) ON CONFLICT DO NOTHING;

  -- CS412 (Internet of Things) ← IT212
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS412'),
    (SELECT id FROM courses WHERE code = 'IT212')
  ) ON CONFLICT DO NOTHING;

  -- CS413 (Problem Solving & Decision Making) ← CS213
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS413'),
    (SELECT id FROM courses WHERE code = 'CS213')
  ) ON CONFLICT DO NOTHING;

  -- CS415 (Cloud Computing) ← CS316
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS415'),
    (SELECT id FROM courses WHERE code = 'CS316')
  ) ON CONFLICT DO NOTHING;

  -- CS416 (Compilers) ← CS411
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'CS416'),
    (SELECT id FROM courses WHERE code = 'CS411')
  ) ON CONFLICT DO NOTHING;

  -- SE315 (Advanced Software Engineering) ← SE211
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'SE315'),
    (SELECT id FROM courses WHERE code = 'SE211')
  ) ON CONFLICT DO NOTHING;

  -- ── IS program ──────────────────────────────────────────────────────────────
  -- IS313 (File Management & Processing) ← CS212
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS313'),
    (SELECT id FROM courses WHERE code = 'CS212')
  ) ON CONFLICT DO NOTHING;

  -- IS314 (Information Retrieval) ← BS115 (Electronics)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS314'),
    (SELECT id FROM courses WHERE code = 'BS115')
  ) ON CONFLICT DO NOTHING;

  -- IS315 (Data Warehousing) ← IS311
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS315'),
    (SELECT id FROM courses WHERE code = 'IS311')
  ) ON CONFLICT DO NOTHING;

  -- IS316 (Data Analytics & Management) ← IS315
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS316'),
    (SELECT id FROM courses WHERE code = 'IS315')
  ) ON CONFLICT DO NOTHING;

  -- IS317 (Web-based IS Development) ← CS211 (OOP)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS317'),
    (SELECT id FROM courses WHERE code = 'CS211')
  ) ON CONFLICT DO NOTHING;

  -- IS411 (Data Mining) ← BS116 (Probability & Statistics 1)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS411'),
    (SELECT id FROM courses WHERE code = 'BS116')
  ) ON CONFLICT DO NOTHING;

  -- IS413 (Selected Topics in IS 1) ← IS317
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IS413'),
    (SELECT id FROM courses WHERE code = 'IS317')
  ) ON CONFLICT DO NOTHING;

  -- ── IT program ──────────────────────────────────────────────────────────────
  -- IT311 (Computer Graphics) ← CS112 (Structured Programming)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT311'),
    (SELECT id FROM courses WHERE code = 'CS112')
  ) ON CONFLICT DO NOTHING;

  -- IT312 (Pattern Recognition) ← BS117 (Operations Research)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT312'),
    (SELECT id FROM courses WHERE code = 'BS117')
  ) ON CONFLICT DO NOTHING;

  -- IT313 (Information & Computer Networks Security) ← IT111
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT313'),
    (SELECT id FROM courses WHERE code = 'IT111')
  ) ON CONFLICT DO NOTHING;

  -- IT314 (Signals & Systems) ← BS114 (Math 3)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT314'),
    (SELECT id FROM courses WHERE code = 'BS114')
  ) ON CONFLICT DO NOTHING;

  -- IT316 (Image Processing) ← IT314
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT316'),
    (SELECT id FROM courses WHERE code = 'IT314')
  ) ON CONFLICT DO NOTHING;

  -- IT317 (Advanced Computer Networks) ← IT212
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT317'),
    (SELECT id FROM courses WHERE code = 'IT212')
  ) ON CONFLICT DO NOTHING;

  -- IT318 (Computer Architecture) ← BS115 (Electronics)
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT318'),
    (SELECT id FROM courses WHERE code = 'BS115')
  ) ON CONFLICT DO NOTHING;

  -- IT413 (Communication Technology) ← IT317
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT413'),
    (SELECT id FROM courses WHERE code = 'IT317')
  ) ON CONFLICT DO NOTHING;

  -- IT415 (Cloud Computing Networks) ← IT111
  INSERT INTO course_prerequisites (course_id, prereq_course_id)
  VALUES (
    (SELECT id FROM courses WHERE code = 'IT415'),
    (SELECT id FROM courses WHERE code = 'IT111')
  ) ON CONFLICT DO NOTHING;

  -- ===========================================================================
  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('015_fix_course_prerequisites.sql', 1);

  RAISE NOTICE '015: prerequisites fixed, IT212 added, IS212 name corrected.';
END $$;
