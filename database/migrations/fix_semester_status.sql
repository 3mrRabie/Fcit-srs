-- database/migrations/fix_semester_status.sql

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM seed_logs WHERE seed_name = 'fix_semester_status.sql'
  ) THEN
    RAISE NOTICE 'Semester statuses already fixed.';
    RETURN;
  END IF;

  -- Update Fall 2025 to 'grading' (id = 1)
  UPDATE semesters SET status = 'grading' WHERE id = 1;

  -- Update Spring 2026 to 'registration' (id = 2)
  UPDATE semesters SET status = 'registration' WHERE id = 2;

  INSERT INTO seed_logs (seed_name, rows_affected)
  VALUES ('fix_semester_status.sql', 2);

  RAISE NOTICE 'Semester statuses updated: Fall 2025 -> grading, Spring 2026 -> registration.';
END $$;
