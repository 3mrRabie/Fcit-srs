-- 019_db_patch.sql
-- This script was causing schema errors because of incompatible column names
-- and has been cleared out. All corrections have been consolidated into 020_final_db_cleanup.sql.

DO $$
BEGIN
  INSERT INTO migration_logs (filename) VALUES ('019_db_patch.sql') ON CONFLICT DO NOTHING;
END $$;
