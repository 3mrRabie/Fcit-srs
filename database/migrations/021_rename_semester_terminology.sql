-- Migration 021: Normalize Semester Terminology (Spring/الترم الأول -> First/Second)

-- 1. Rename the ENUM values for semester_type
ALTER TYPE semester_type RENAME VALUE 'first' TO 'first';
ALTER TYPE semester_type RENAME VALUE 'second' TO 'second';

-- 2. Update existing labels in the semesters table
UPDATE semesters 
SET label = REPLACE(label, 'Fall', 'First Semester')
WHERE label LIKE '%Fall%';

UPDATE semesters 
SET label = REPLACE(label, 'Spring', 'Second Semester')
WHERE label LIKE '%Spring%';

-- 3. Log the migration
INSERT INTO migration_logs (filename) VALUES ('021_rename_semester_terminology.sql') ON CONFLICT DO NOTHING;
