-- =============================================================================
-- Migration 016: Remove Duplicate (Old/Wrong) Prerequisites
-- =============================================================================
-- Migration 015 inserted the correct prereqs but the original wrong ones
-- remained, leaving each affected course with two prerequisites.
-- This migration deletes ONLY the wrong (old) prereq from each pair,
-- leaving the correct (new) prereq untouched.
-- =============================================================================

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = '016_remove_duplicate_prerequisites.sql'
  ) THEN
    RAISE NOTICE '016 already applied, skipping.';
    RETURN;
  END IF;

  -- Helper: delete a specific prereq pair by course code + wrong prereq code
  -- IS program
  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS211')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS112');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS212')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS313')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS315')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS316')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS317')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS411')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS316');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IS413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

  -- CS program
  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS311')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS312')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS411')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS412')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS415')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'CS416')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

  -- IT program
  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT311')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT312')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT313')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT316')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT311');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT317')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT311');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT318')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT315');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT314');

  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'IT415')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT317');

  -- SE program
  DELETE FROM course_prerequisites
  WHERE course_id    = (SELECT id FROM courses WHERE code = 'SE315')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'SE313');

  -- ==========================================================================
  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('016_remove_duplicate_prerequisites.sql', 1);

  RAISE NOTICE '016: all duplicate wrong prerequisites removed.';
END $$;
