-- =============================================================================
-- Migration: Fix Curriculum Plans
-- Deletes invalid entries and re-populates from `courses` table
-- =============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM seed_logs WHERE seed_name = 'fix_curriculum_plans.sql') THEN
        RAISE NOTICE 'fix_curriculum_plans.sql already run, skipping';
        RETURN;
    END IF;

    -- 1. Delete invalid rows
    DELETE FROM curriculum_plans WHERE course_id IS NULL OR course_id NOT IN (SELECT id FROM courses WHERE is_active = TRUE);

    -- 2. Insert valid rows
    -- GENERAL program (year 1, semester 1 = Fall)
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'GENERAL', 1, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS111','BS111','BS112','IS111','UNV113','BS116')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- GENERAL program (year 1, semester 2 = Spring)
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'GENERAL', 1, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS112','BS113','BS115','UNV111','UNV112','UNV114')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- GENERAL program (year 2, semester 1)
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'GENERAL', 2, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS211','CS212','BS114','BS117','SE211','IT211')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- GENERAL program (year 2, semester 2)
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'GENERAL', 2, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS213','CS214','IS211','IS212','IT317')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- CS Specialization
    -- Year 3 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'CS', 3, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS311','CS312','CS313','IT311','IS311','CS331')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 3 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'CS', 3, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS314','CS315','CS316','SE315','CS411','CS332')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'CS', 4, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS412','CS413','CS414','IT416','CS421','PR411')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'CS', 4, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('CS415','CS416','CS422','CS423','PR412')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- IS Specialization
    -- Year 3 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IS', 3, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IS311','IS312','IS313','IT311','CS313','IS331')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 3 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IS', 3, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IS314','IS315','IS316','CS315','SE315','IS332')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IS', 4, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IS411','IS412','IS413','CS413','IT416','PR411')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IS', 4, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IS414','IS415','IS422','IS423','PR412')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- IT Specialization
    -- Year 3 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IT', 3, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IT311','IT312','IT313','CS313','IS311','IT331')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 3 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IT', 3, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IT314','IT315','IT316','CS315','SE315','IT332')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IT', 4, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IT411','IT412','IT413','IT416','CS413','PR411')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'IT', 4, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('IT414','IT415','IT421','IT422','PR412')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    -- SE Specialization
    -- Year 3 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'SE', 3, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('SE311','SE312','SE313','IT311','CS313','SE331')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 3 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'SE', 3, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('SE314','SE315','SE316','CS315','IS316','SE332')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Fall
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'SE', 4, 1, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('SE411','SE412','SE413','CS412','CS413','PR411')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;
    -- Year 4 Spring
    INSERT INTO curriculum_plans (specialization, year_of_study, semester_in_year, course_id, is_mandatory, display_order)
    SELECT 'SE', 4, 2, id, TRUE, row_number() OVER (ORDER BY code)
    FROM courses WHERE code IN ('SE414','SE415','SE421','SE422','PR412')
    ON CONFLICT (specialization, year_of_study, semester_in_year, course_id) DO NOTHING;

    INSERT INTO seed_logs (seed_name, rows_affected) VALUES ('fix_curriculum_plans.sql', 1);
    RAISE NOTICE 'fix_curriculum_plans.sql completed';
END $$;
