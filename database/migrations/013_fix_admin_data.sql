-- =============================================================================
-- Migration 013: Fix admin data — deduplicate offerings, resolve schedule
-- conflicts, and fix Aida Nasr name.
-- Idempotent — safe to run multiple times.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Fix Aida Nasr's Arabic name (canonical form: د. عايده نصر)
--    Match by stable English name to handle any encoding variant.
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE users
SET full_name_ar = 'د. عايده نصر'
WHERE full_name_en = 'Dr. Aida Nasr'
  AND full_name_ar IS DISTINCT FROM 'د. عايده نصر';

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Deduplicate course offerings: keep only ONE active offering per course
--    per semester. For any course with multiple active offerings in the same
--    semester, keep the 'Main' section (or lowest ID) and deactivate the rest.
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_dup   RECORD;
  v_keep  INT;
BEGIN
  -- Find courses with more than one active offering in the same semester
  FOR v_dup IN (
    SELECT semester_id, course_id
    FROM course_offerings
    WHERE is_active = TRUE
    GROUP BY semester_id, course_id
    HAVING COUNT(*) > 1
  )
  LOOP
    -- Decide which offering to keep: prefer section_label='Main', then lowest ID
    SELECT id INTO v_keep
    FROM course_offerings
    WHERE semester_id = v_dup.semester_id
      AND course_id = v_dup.course_id
      AND is_active = TRUE
    ORDER BY
      CASE WHEN section_label = 'Main' THEN 0 ELSE 1 END,
      id
    LIMIT 1;

    RAISE NOTICE 'Dedup course_id=% semester_id=%: keeping offering %',
                 v_dup.course_id, v_dup.semester_id, v_keep;

    -- Re-link enrollments from duplicate offerings to the kept one
    UPDATE enrollments
    SET    offering_id = v_keep
    WHERE  offering_id IN (
      SELECT id FROM course_offerings
      WHERE semester_id = v_dup.semester_id
        AND course_id = v_dup.course_id
        AND is_active = TRUE
        AND id != v_keep
    )
    AND NOT EXISTS (
      SELECT 1 FROM enrollments e2
      WHERE e2.student_id  = enrollments.student_id
        AND e2.offering_id = v_keep
    );

    -- Delete orphaned enrollments that would now clash
    DELETE FROM enrollments
    WHERE offering_id IN (
      SELECT id FROM course_offerings
      WHERE semester_id = v_dup.semester_id
        AND course_id = v_dup.course_id
        AND is_active = TRUE
        AND id != v_keep
    );

    -- Remove schedule slots for the duplicate offerings
    DELETE FROM doctor_schedule_slots
    WHERE offering_id IN (
      SELECT id FROM course_offerings
      WHERE semester_id = v_dup.semester_id
        AND course_id = v_dup.course_id
        AND is_active = TRUE
        AND id != v_keep
    );

    -- Deactivate the duplicate offerings
    UPDATE course_offerings
    SET    is_active = FALSE
    WHERE  semester_id = v_dup.semester_id
      AND  course_id = v_dup.course_id
      AND  is_active = TRUE
      AND  id != v_keep;
  END LOOP;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Fix instructor schedule conflicts: no doctor should teach two courses
--    at the same time in the same semester.
--    For each conflict pair, move the second slot (higher ID) to the next
--    available 2-hour window on the same day, or to the next day if no
--    window is available.
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  r            RECORD;
  new_start    TIME;
  new_end      TIME;
  still_conflict BOOLEAN;
  try_day      TEXT;
  DAYS_ORDER   TEXT[] := ARRAY['Sat','Sun','Mon','Tue','Wed','Thu'];
  d_idx        INT;
  moved        BOOLEAN;
BEGIN
  FOR r IN (
    SELECT
      dss1.id          AS slot1_id,
      dss1.offering_id AS offering1,
      dss2.id          AS slot2_id,
      dss2.offering_id AS offering2,
      co1.doctor_id,
      co1.semester_id,
      dss1.day_of_week AS day,
      dss1.start_time  AS s1_start,
      dss1.end_time    AS s1_end,
      dss2.start_time  AS s2_start,
      dss2.end_time    AS s2_end
    FROM doctor_schedule_slots dss1
    JOIN course_offerings co1 ON co1.id = dss1.offering_id AND co1.is_active = TRUE
    JOIN doctor_schedule_slots dss2
      ON  dss2.offering_id != dss1.offering_id
      AND dss2.day_of_week  = dss1.day_of_week
    JOIN course_offerings co2
      ON  co2.id = dss2.offering_id
      AND co2.doctor_id    = co1.doctor_id
      AND co2.semester_id  = co1.semester_id
      AND co2.is_active    = TRUE
    WHERE dss1.start_time < dss2.end_time
      AND dss1.end_time   > dss2.start_time
      AND dss1.id < dss2.id   -- avoid processing same pair twice
  )
  LOOP
    RAISE NOTICE 'Schedule conflict: slot % (offering %) vs slot % (offering %) on %',
                 r.slot1_id, r.offering1, r.slot2_id, r.offering2, r.day;

    moved := FALSE;

    -- Try moving slot2 to a non-conflicting window on the same day
    FOREACH new_start IN ARRAY ARRAY['07:00'::TIME, '09:00'::TIME, '11:00'::TIME, '13:00'::TIME, '15:00'::TIME]
    LOOP
      new_end := new_start + (r.s2_end - r.s2_start);

      -- Skip windows that still overlap with slot1
      IF new_start < r.s1_end AND new_end > r.s1_start THEN
        CONTINUE;
      END IF;

      -- Check no other conflict exists for this doctor on the same day at this time
      SELECT EXISTS (
        SELECT 1
        FROM doctor_schedule_slots dss3
        JOIN course_offerings co3 ON co3.id = dss3.offering_id
        WHERE co3.doctor_id   = r.doctor_id
          AND co3.semester_id = r.semester_id
          AND co3.is_active   = TRUE
          AND dss3.day_of_week = r.day
          AND dss3.offering_id != r.offering2
          AND dss3.start_time < new_end
          AND dss3.end_time   > new_start
      ) INTO still_conflict;

      IF NOT still_conflict THEN
        UPDATE doctor_schedule_slots
        SET    start_time = new_start, end_time = new_end
        WHERE  id = r.slot2_id;
        RAISE NOTICE 'Moved slot % to %–% on %', r.slot2_id, new_start, new_end, r.day;
        moved := TRUE;
        EXIT;
      END IF;
    END LOOP;

    -- If no window found on the same day, move to the next day
    IF NOT moved THEN
      d_idx := array_position(DAYS_ORDER, r.day);
      IF d_idx IS NULL THEN d_idx := 1; END IF;
      d_idx := d_idx + 1;
      IF d_idx > array_length(DAYS_ORDER, 1) THEN d_idx := 1; END IF;
      try_day := DAYS_ORDER[d_idx];

      new_start := '09:00'::TIME;
      new_end   := new_start + (r.s2_end - r.s2_start);

      UPDATE doctor_schedule_slots
      SET    day_of_week = try_day,
             start_time  = new_start,
             end_time    = new_end
      WHERE  id = r.slot2_id;

      RAISE NOTICE 'Moved slot % to next day: % %–%', r.slot2_id, try_day, new_start, new_end;
    END IF;
  END LOOP;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Log this migration
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO seed_logs (seed_name, run_at)
VALUES ('013_fix_admin_data.sql', NOW())
ON CONFLICT (seed_name) DO NOTHING;
