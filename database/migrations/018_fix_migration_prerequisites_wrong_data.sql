-- =============================================================================
-- Migration 018: Fix all wrong prerequisites introduced by migration_prerequisites.sql
-- =============================================================================
-- Root cause: migration_prerequisites.sql contained 15 incorrect prerequisite
-- pairs that contradicted the verified bylaw data. Because that file runs as
-- a POST_SEED_MIGRATION (step 4) before the numbered fix migrations (step 5),
-- and because the numbered fixes (015/016) are gated by seed_logs guards that
-- may fire before they can clean up, some databases ended up with BOTH the
-- correct prerequisite AND the wrong one for the same course — causing the UI
-- to display multiple blocked-prerequisite messages.
--
-- Wrong pairs this migration removes (course → wrong prereq):
--   IS211 → CS112   (correct: IS111)
--   IS212 → IS211   (correct: BS113)
--   IS313 → IS211   (correct: CS212)
--   IS314 → IS211   (correct: BS115)
--   IS315 → IS312   (correct: IS311)
--   IS316 → IS312   (correct: IS315)
--   IS317 → IS311   (correct: CS211)
--   IS411 → IS316   (correct: BS116)
--   IS413 → IS311   (correct: IS317)
--   CS311 → CS212   (correct: IT212)
--   CS312 → CS212   (correct: IT211)
--   CS314 → CS313   (correct: CS211)
--   CS411 → CS213   (correct: BS112)
--   CS412 → CS312   (correct: IT212)
--   CS413 → CS313   (correct: CS213)
--   CS415 → CS312   (correct: CS316)
--   CS416 → CS213   (correct: CS411)
--   IT311 → IT211   (correct: CS112)
--   IT312 → IT211   (correct: BS117)
--   IT313 → IT211   (correct: IT111)
--   IT314 → IT211   (correct: BS114)
--   IT317 → IT311   (correct: IT212)
--   IT318 → IT315   (correct: BS115)
--   IT413 → IT314   (correct: IT317)
--   IT415 → IT317   (correct: IT111)
--   SE315 → SE313   (correct: SE211)
--
-- This migration has NO seed_logs / migration_logs guard in its own SQL body —
-- it is safe to apply multiple times (every DELETE is a no-op if the row is
-- already gone). The migration_logs guard in setup.js ensures it runs exactly
-- once per database instance after the initial cleanup.
-- =============================================================================

-- IS program ──────────────────────────────────────────────────────────────────
DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS211')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS112');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS212')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS313')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS315')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS316')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS317')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS411')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS316');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IS413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

-- CS program ──────────────────────────────────────────────────────────────────
DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS311')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS312')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS411')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS412')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS415')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'CS416')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

-- IT program ──────────────────────────────────────────────────────────────────
DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT311')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT312')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT313')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT317')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT311');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT318')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT315');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT314');

DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'IT415')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT317');

-- SE program ──────────────────────────────────────────────────────────────────
DELETE FROM course_prerequisites
WHERE course_id        = (SELECT id FROM courses WHERE code = 'SE315')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'SE313');

-- Ensure all correct prerequisites exist (INSERT where missing) ────────────────
-- IS program
INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS211'), (SELECT id FROM courses WHERE code='IS111')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS211') AND prereq_course_id=(SELECT id FROM courses WHERE code='IS111'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS212'), (SELECT id FROM courses WHERE code='BS113')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS212') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS113'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS313'), (SELECT id FROM courses WHERE code='CS212')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS313') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS212'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS314'), (SELECT id FROM courses WHERE code='BS115')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS314') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS115'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS315'), (SELECT id FROM courses WHERE code='IS311')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS315') AND prereq_course_id=(SELECT id FROM courses WHERE code='IS311'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS316'), (SELECT id FROM courses WHERE code='IS315')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS316') AND prereq_course_id=(SELECT id FROM courses WHERE code='IS315'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS317'), (SELECT id FROM courses WHERE code='CS211')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS317') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS211'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS411'), (SELECT id FROM courses WHERE code='BS116')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS411') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS116'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IS413'), (SELECT id FROM courses WHERE code='IS317')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IS413') AND prereq_course_id=(SELECT id FROM courses WHERE code='IS317'));

-- CS program
INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS311'), (SELECT id FROM courses WHERE code='IT212')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS311') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT212'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS312'), (SELECT id FROM courses WHERE code='IT211')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS312') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT211'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS314'), (SELECT id FROM courses WHERE code='CS211')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS314') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS211'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS411'), (SELECT id FROM courses WHERE code='BS112')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS411') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS112'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS412'), (SELECT id FROM courses WHERE code='IT212')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS412') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT212'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS413'), (SELECT id FROM courses WHERE code='CS213')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS413') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS213'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS415'), (SELECT id FROM courses WHERE code='CS316')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS415') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS316'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='CS416'), (SELECT id FROM courses WHERE code='CS411')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='CS416') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS411'));

-- IT program
INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT311'), (SELECT id FROM courses WHERE code='CS112')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT311') AND prereq_course_id=(SELECT id FROM courses WHERE code='CS112'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT312'), (SELECT id FROM courses WHERE code='BS117')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT312') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS117'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT313'), (SELECT id FROM courses WHERE code='IT111')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT313') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT111'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT314'), (SELECT id FROM courses WHERE code='BS114')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT314') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS114'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT317'), (SELECT id FROM courses WHERE code='IT212')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT317') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT212'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT318'), (SELECT id FROM courses WHERE code='BS115')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT318') AND prereq_course_id=(SELECT id FROM courses WHERE code='BS115'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT413'), (SELECT id FROM courses WHERE code='IT317')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT413') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT317'));

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='IT415'), (SELECT id FROM courses WHERE code='IT111')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='IT415') AND prereq_course_id=(SELECT id FROM courses WHERE code='IT111'));

-- SE program
INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code='SE315'), (SELECT id FROM courses WHERE code='SE211')
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisites WHERE course_id=(SELECT id FROM courses WHERE code='SE315') AND prereq_course_id=(SELECT id FROM courses WHERE code='SE211'));

DO $$ BEGIN
  RAISE NOTICE '018: wrong prerequisites from migration_prerequisites.sql removed and correct ones ensured.';
END $$;
