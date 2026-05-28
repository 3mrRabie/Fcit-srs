-- =============================================================================
-- Migration 017: Unconditional cleanup of all wrong duplicate prerequisites
-- =============================================================================
-- Migrations 015/016 were skipped on existing DBs due to seed_logs guards.
-- This migration has NO guard — it simply deletes each specific wrong prereq
-- pair. If the row doesn't exist, the DELETE silently affects 0 rows.
-- Safe to run multiple times (idempotent by nature of targeted DELETEs).
-- =============================================================================

-- IS program: delete old wrong prereqs ----------------------------------------

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS211')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS112');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS212')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS313')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS315')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS316')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS312');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS317')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS411')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS316');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IS413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311');

-- CS program: delete old wrong prereqs ----------------------------------------

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS311')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS312')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS411')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS412')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS313');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS415')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS312');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'CS416')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213');

-- IT program: delete old wrong prereqs ----------------------------------------

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT311')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT312')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT313')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT314')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT316')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT311');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT317')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT311');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT318')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT315');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT413')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT314');

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'IT415')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT317');

-- SE program: delete old wrong prereqs ----------------------------------------

DELETE FROM course_prerequisites
WHERE course_id = (SELECT id FROM courses WHERE code = 'SE315')
  AND prereq_course_id = (SELECT id FROM courses WHERE code = 'SE313');

-- Also ensure correct prereqs exist (INSERT where missing) --------------------

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS211'),
       (SELECT id FROM courses WHERE code = 'IS111')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS211')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS111')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS212'),
       (SELECT id FROM courses WHERE code = 'BS113')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS212')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS113')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS313'),
       (SELECT id FROM courses WHERE code = 'CS212')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS313')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS212')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS314'),
       (SELECT id FROM courses WHERE code = 'BS115')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS115')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS315'),
       (SELECT id FROM courses WHERE code = 'IS311')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS315')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS311')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS316'),
       (SELECT id FROM courses WHERE code = 'IS315')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS316')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS315')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS317'),
       (SELECT id FROM courses WHERE code = 'CS211')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS317')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS211')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS411'),
       (SELECT id FROM courses WHERE code = 'BS116')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS411')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS116')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IS413'),
       (SELECT id FROM courses WHERE code = 'IS317')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IS413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IS317')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS311'),
       (SELECT id FROM courses WHERE code = 'IT212')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS311')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT212')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS312'),
       (SELECT id FROM courses WHERE code = 'IT211')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS312')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT211')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS314'),
       (SELECT id FROM courses WHERE code = 'CS211')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS211')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS411'),
       (SELECT id FROM courses WHERE code = 'BS112')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS411')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS112')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS412'),
       (SELECT id FROM courses WHERE code = 'IT212')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS412')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT212')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS413'),
       (SELECT id FROM courses WHERE code = 'CS213')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS213')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS415'),
       (SELECT id FROM courses WHERE code = 'CS316')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS415')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS316')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'CS416'),
       (SELECT id FROM courses WHERE code = 'CS411')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'CS416')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS411')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT311'),
       (SELECT id FROM courses WHERE code = 'CS112')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT311')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'CS112')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT312'),
       (SELECT id FROM courses WHERE code = 'BS117')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT312')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS117')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT313'),
       (SELECT id FROM courses WHERE code = 'IT111')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT313')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT111')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT314'),
       (SELECT id FROM courses WHERE code = 'BS114')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT314')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS114')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT316'),
       (SELECT id FROM courses WHERE code = 'IT314')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT316')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT314')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT317'),
       (SELECT id FROM courses WHERE code = 'IT212')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT317')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT212')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT318'),
       (SELECT id FROM courses WHERE code = 'BS115')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT318')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'BS115')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT413'),
       (SELECT id FROM courses WHERE code = 'IT317')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT413')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT317')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'IT415'),
       (SELECT id FROM courses WHERE code = 'IT111')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'IT415')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'IT111')
);

INSERT INTO course_prerequisites (course_id, prereq_course_id)
SELECT (SELECT id FROM courses WHERE code = 'SE315'),
       (SELECT id FROM courses WHERE code = 'SE211')
WHERE NOT EXISTS (
  SELECT 1 FROM course_prerequisites
  WHERE course_id = (SELECT id FROM courses WHERE code = 'SE315')
    AND prereq_course_id = (SELECT id FROM courses WHERE code = 'SE211')
);
