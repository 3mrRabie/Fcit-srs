-- =============================================================================
-- Migration 014: Fix curriculum_plans unique constraint and re-populate
--
-- Root Cause: The table has UNIQUE(specialization, course_id) which means
-- each course can appear only ONCE per specialization. But courses like CS315,
-- CS331, CS332, IT315, IT314, IT319 legitimately appear in multiple year/semester
-- slots for the SAME specialization. The DO UPDATE in 013_fix_curriculum_seed.sql
-- silently overwrites earlier entries, making those courses vanish from earlier semesters.
--
-- Fix: Drop the old narrow constraint, add UNIQUE(specialization, year_of_study,
-- semester_in_year, course_id), then re-populate the full plan cleanly.
-- =============================================================================

DO $$
BEGIN


  -- ── 1. Drop ALL existing unique constraints on curriculum_plans ──────────
  ALTER TABLE curriculum_plans
    DROP CONSTRAINT IF EXISTS curriculum_plans_specialization_course_id_key;
  ALTER TABLE curriculum_plans
    DROP CONSTRAINT IF EXISTS curriculum_plans_spec_year_sem_course_key;
  ALTER TABLE curriculum_plans
    DROP CONSTRAINT IF EXISTS curriculum_plans_pkey; -- only if it's composite; skip if it's an id PK

  -- ── 2. Add the correct 4-column unique constraint ─────────────────────────
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'curriculum_plans'::regclass
      AND conname = 'curriculum_plans_spec_year_sem_course_key'
  ) THEN
    ALTER TABLE curriculum_plans
      ADD CONSTRAINT curriculum_plans_spec_year_sem_course_key
      UNIQUE (specialization, year_of_study, semester_in_year, course_id);
  END IF;

  -- ── 3. Clear and re-populate completely ───────────────────────────────────
  DELETE FROM curriculum_plans;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 1 — GENERAL (shared by all specializations)
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 1, 1, c.id, TRUE, ord FROM (VALUES
    ('BS112',1),('CS111',2),('IS111',3),('BS111',4),('BS116',5),('UNV113',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 1, 2, c.id, TRUE, ord FROM (VALUES
    ('BS115',1),('UNV112',2),('BS113',3),('UNV114',4),('UNV111',5),('CS112',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 2 — GENERAL
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 2, 1, c.id, TRUE, ord FROM (VALUES
    ('BS114',1),('BS117',2),('CS211',3),('SE211',4),('CS212',5),('IT211',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 2, 2, c.id, TRUE, ord FROM (VALUES
    ('IS211',1),('CS214',2),('IT317',3),('IS212',4),('CS213',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  -- ══════════════════════════════════════════════════════════════
  -- CS SPECIALIZATION — Years 3 & 4
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 3, 1, c.id, TRUE, ord FROM (VALUES
    ('IT311',1),('CS313',2),('CS311',3),('IS311',4),('CS312',5),('CS331',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 3, 2, c.id, TRUE, ord FROM (VALUES
    ('CS314',1),('CS332',2),('CS411',3),('SE315',4),('CS315',5),('CS316',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 4, 1, c.id, TRUE, ord FROM (VALUES
    ('CS315',1),('CS443',2),('SE321',3),('CS434',4),('CS413',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 4, 2, c.id, TRUE, ord FROM (VALUES
    ('CS331',1),('CS332',2),('CS416',3),('CS415',4),('CS433',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  -- ══════════════════════════════════════════════════════════════
  -- IS SPECIALIZATION — Years 3 & 4
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 3, 1, c.id, TRUE, ord FROM (VALUES
    ('CS314',1),('IS313',2),('IS311',3),('IS312',4),('CS313',5),('IS351',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 3, 2, c.id, TRUE, ord FROM (VALUES
    ('IS315',1),('IS317',2),('IS321',3),('IS318',4),('IS314',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 4, 1, c.id, TRUE, ord FROM (VALUES
    ('IS341',1),('IS411',2),('IS412',3),('IS351',4),('CS314',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 4, 2, c.id, TRUE, ord FROM (VALUES
    ('IS413',1),('IS342',2),('IS415',3),('IS414',4),('IS421',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  -- ══════════════════════════════════════════════════════════════
  -- IT SPECIALIZATION — Years 3 & 4
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 3, 1, c.id, TRUE, ord FROM (VALUES
    ('IT311',1),('IT321',2),('CS313',3),('IT315',4),('IT312',5),('IT314',6)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 3, 2, c.id, TRUE, ord FROM (VALUES
    ('IT319',1),('IT322',2),('IT318',3),('IT317',4),('IT316',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 4, 1, c.id, TRUE, ord FROM (VALUES
    ('IT415',1),('IT315',2),('CS315',3),('IT444',4),('IT313',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 4, 2, c.id, TRUE, ord FROM (VALUES
    ('IT319',1),('IT414',2),('IT413',3),('IT314',4),('IT411',5)
  ) AS t(code,ord) JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('014_fix_curriculum_constraint.sql', 1)
  ON CONFLICT (seed_name) DO NOTHING;

  RAISE NOTICE '014_fix_curriculum_constraint.sql: constraint fixed and curriculum re-populated.';
END $$;
