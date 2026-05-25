-- =============================================================================
-- FIX-M1: Minimum Credits Per Semester — Three-Way Inconsistency
-- =============================================================================

ALTER TABLE semesters ALTER COLUMN min_credits SET DEFAULT 9;
