-- Migration 022: Full Arabic Normalization (Semesters & Levels)

-- 1. Mutate academic level ENUM values to Arabic
ALTER TYPE student_level RENAME VALUE 'freshman' TO 'الفرقة الأولى';
ALTER TYPE student_level RENAME VALUE 'sophomore' TO 'الفرقة الثانية';
ALTER TYPE student_level RENAME VALUE 'junior' TO 'الفرقة الثالثة';
ALTER TYPE student_level RENAME VALUE 'senior' TO 'الفرقة الرابعة';

-- 2. Mutate semester labels to Arabic
UPDATE semesters SET label = REPLACE(label, 'First Semester', 'الترم الأول') WHERE label LIKE '%First Semester%';
UPDATE semesters SET label = REPLACE(label, 'Second Semester', 'الترم الثاني') WHERE label LIKE '%Second Semester%';
UPDATE semesters SET label = REPLACE(label, 'Summer Semester', 'الترم الصيفي') WHERE label LIKE '%Summer Semester%';
UPDATE semesters SET label = REPLACE(label, 'Summer', 'الترم الصيفي') WHERE label LIKE '%Summer%' AND label NOT LIKE '%الترم الصيفي%';

-- 3. Update any students who might have been disconnected (they shouldn't be, since ENUM values are renamed in place)

-- Log migration
INSERT INTO migration_logs (filename) VALUES ('022_full_arabic_normalization.sql') ON CONFLICT DO NOTHING;
