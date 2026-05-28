-- =============================================================================
-- Migration: Fix Semester Statuses
-- Updates the statuses of semesters to match the current academic timeline
-- =============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM seed_logs WHERE seed_name = 'fix_semester_statuses.sql') THEN
        RAISE NOTICE 'fix_semester_statuses.sql already run, skipping';
        RETURN;
    END IF;

    UPDATE semesters SET status = 'closed' WHERE label = 'الترم الأول 2024';
    UPDATE semesters SET status = 'closed' WHERE label = 'الترم الثاني 2025';
    UPDATE semesters SET status = 'grading' WHERE label = 'الترم الأول 2025';
    UPDATE semesters SET status = 'registration' WHERE label = 'الترم الثاني 2026';
    UPDATE semesters SET status = 'upcoming' WHERE label = 'الترم الصيفي 2026';

    INSERT INTO seed_logs (seed_name, rows_affected) VALUES ('fix_semester_statuses.sql', 1);
    RAISE NOTICE 'fix_semester_statuses.sql completed';
END $$;
