-- database/migrations/013_fix_curriculum_seed.sql
-- Fix: The populate_curriculum_plans.sql used ON CONFLICT (specialization, year_of_study, semester_in_year, course_id)
-- but the actual unique constraint is UNIQUE (specialization, course_id) — causing silent insert failures.
-- This migration re-populates the curriculum_plans with the correct ON CONFLICT clause.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '013_fix_curriculum_seed.sql'
  ) THEN
    RAISE NOTICE '013_fix_curriculum_seed.sql already applied, skipping.';
    RETURN;
  END IF;

  -- Clear all existing curriculum_plans entries so we start fresh
  DELETE FROM curriculum_plans;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 1 TERM 1 — specialization = 'GENERAL'
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 1, 1, c.id, TRUE, ord
  FROM (VALUES
    ('BS112', 1), ('CS111', 2), ('IS111', 3),
    ('BS111', 4), ('BS116', 5), ('UNV113', 6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 1 TERM 2 — specialization = 'GENERAL'
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 1, 2, c.id, TRUE, ord
  FROM (VALUES
    ('BS115', 1), ('UNV112', 2), ('BS113', 3),
    ('UNV114', 4), ('UNV111', 5), ('CS112', 6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 2 TERM 1 — specialization = 'GENERAL'
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 2, 1, c.id, TRUE, ord
  FROM (VALUES
    ('BS114', 1), ('BS117', 2), ('CS211', 3),
    ('SE211', 4), ('CS212', 5), ('IT211', 6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 2 TERM 2 — specialization = 'GENERAL'
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'GENERAL', 2, 2, c.id, TRUE, ord
  FROM (VALUES
    ('IS211', 1), ('CS214', 2), ('IT317', 3),
    ('IS212', 4), ('CS213', 5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 3 TERM 1 — CS specialization
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 3, 1, c.id, TRUE, ord
  FROM (VALUES
    ('IT311',1),('CS313',2),('CS311',3),('IS311',4),('CS312',5),('CS331',6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 3 TERM 1 — IS specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 3, 1, c.id, TRUE, ord
  FROM (VALUES
    ('CS314',1),('IS313',2),('IS311',3),('IS312',4),('CS313',5),('IS351',6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 3 TERM 1 — IT specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 3, 1, c.id, TRUE, ord
  FROM (VALUES
    ('IT311',1),('IT321',2),('CS313',3),('IT315',4),('IT312',5),('IT314',6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 3 TERM 2 — CS specialization
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 3, 2, c.id, TRUE, ord
  FROM (VALUES
    ('CS314',1),('CS332',2),('CS411',3),('SE315',4),('CS315',5),('CS316',6)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 3 TERM 2 — IS specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 3, 2, c.id, TRUE, ord
  FROM (VALUES
    ('IS315',1),('IS317',2),('IS321',3),('IS318',4),('IS314',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 3 TERM 2 — IT specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 3, 2, c.id, TRUE, ord
  FROM (VALUES
    ('IT319',1),('IT322',2),('IT318',3),('IT317',4),('IT316',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 4 TERM 1 — CS specialization
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 4, 1, c.id, TRUE, ord
  FROM (VALUES
    ('CS315',1),('CS443',2),('SE321',3),('CS434',4),('CS413',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 4 TERM 1 — IS specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 4, 1, c.id, TRUE, ord
  FROM (VALUES
    ('IS341',1),('IS411',2),('IS412',3),('IS351',4),('CS314',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 4 TERM 1 — IT specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 4, 1, c.id, TRUE, ord
  FROM (VALUES
    ('IT415',1),('IT315',2),('CS315',3),('IT444',4),('IT313',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- ══════════════════════════════════════════════════════════════
  -- YEAR 4 TERM 2 — CS specialization
  -- ══════════════════════════════════════════════════════════════
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'CS', 4, 2, c.id, TRUE, ord
  FROM (VALUES
    ('CS331',1),('CS332',2),('CS416',3),('CS415',4),('CS433',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 4 TERM 2 — IS specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IS', 4, 2, c.id, TRUE, ord
  FROM (VALUES
    ('IS413',1),('IS342',2),('IS415',3),('IS414',4),('IS321',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  -- YEAR 4 TERM 2 — IT specialization
  INSERT INTO curriculum_plans
    (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
  SELECT 'IT', 4, 2, c.id, TRUE, ord
  FROM (VALUES
    ('IT319',1),('IT414',2),('IT413',3),('IT314',4),('IT411',5)
  ) AS t(code, ord)
  JOIN courses c ON c.code = t.code
  ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO UPDATE
    SET year_of_study = EXCLUDED.year_of_study,
        semester_in_year = EXCLUDED.semester_in_year,
        display_order = EXCLUDED.display_order;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('013_fix_curriculum_seed.sql', 1);

  RAISE NOTICE 'curriculum_plans re-populated with correct ON CONFLICT clause.';
END $$;
