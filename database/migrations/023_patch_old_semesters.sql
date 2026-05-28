-- =============================================================================
-- Migration: 023_patch_old_semesters.sql
-- Description: Automatically marks all historical semesters prior to 2026 as 'closed'
-- to clean up stale states (e.g. stuck in 'registration' or 'grading').
-- =============================================================================

BEGIN;

UPDATE semesters
SET status = 'closed'
WHERE end_date < '2026-01-01' AND status != 'closed';

COMMIT;
