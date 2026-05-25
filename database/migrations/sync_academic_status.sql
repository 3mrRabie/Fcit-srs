-- database/migrations/sync_academic_status.sql

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = 'sync_academic_status.sql'
  ) THEN
    RAISE NOTICE 'Academic status sync already applied.';
    RETURN;
  END IF;

  -- Set academic_status based on CGPA thresholds from academic-regulations.json
  -- Thresholds: probation < 1.5, warning 1.5–1.99, active ≥ 2.0
  UPDATE students SET academic_status =
    CASE
      WHEN cgpa < 1.5  THEN 'probation'::academic_status
      WHEN cgpa < 2.0  THEN 'warning'::academic_status
      ELSE                  'active'::academic_status
    END
  WHERE academic_status IN ('active', 'warning', 'probation');

  -- Also update total_warnings count for warning/probation students
  UPDATE students SET total_warnings = 1
  WHERE academic_status IN ('warning', 'probation') AND total_warnings = 0;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('sync_academic_status.sql', 1);

  RAISE NOTICE 'Academic status synced from CGPA.';
END $$;
