-- =============================================================================
-- Migration 011: Fix timetable duplicates, grades, doctor name, schedule conflicts
-- Run once against the live database.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Fix doctor English name: "Eida Nasr" → "Aida Nasr"
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE users
SET    full_name_en = REGEXP_REPLACE(full_name_en, '(?i)eida', 'Aida')
WHERE  LOWER(full_name_en) LIKE '%eida%nasr%';

-- In case it was stored without "Dr." prefix
UPDATE users
SET    full_name_en = 'Dr. Aida Nasr'
WHERE  LOWER(full_name_en) IN ('eida nasr', 'dr eida nasr', 'dr. eida nasr');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Remove duplicate BS115 offering (Section 2 with Dr. Nancy)
--    Keep the Main section (Dr. Aida Nasr) and deactivate Section 2.
--    Enrolled students are re-linked to the Main section offering.
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_spring2026_id   INT;
  v_main_offering   INT;
  v_dup_offering    INT;
BEGIN
  -- Find current spring 2026 semester
  SELECT id INTO v_spring2026_id
  FROM   semesters
  WHERE  semester_type = 'second'
    AND  EXTRACT(YEAR FROM start_date) IN (2025, 2026)
  ORDER  BY start_date DESC
  LIMIT  1;

  IF v_spring2026_id IS NULL THEN
    RAISE WARNING 'الترم الثاني 2026 semester not found; skipping BS115 dedup.';
    RETURN;
  END IF;

  -- Find Main offering (Dr. Aida) and the duplicate Section 2
  SELECT id INTO v_main_offering
  FROM   course_offerings
  WHERE  semester_id = v_spring2026_id
    AND  course_id   = (SELECT id FROM courses WHERE code = 'BS115')
    AND  (section_label = 'Main' OR section_label IS NULL)
    AND  is_active = TRUE
  LIMIT 1;

  SELECT id INTO v_dup_offering
  FROM   course_offerings
  WHERE  semester_id = v_spring2026_id
    AND  course_id   = (SELECT id FROM courses WHERE code = 'BS115')
    AND  section_label = 'Section 2'
    AND  is_active = TRUE
  LIMIT 1;

  IF v_main_offering IS NULL OR v_dup_offering IS NULL THEN
    RAISE NOTICE 'BS115 offerings not found or already fixed; skipping.';
    RETURN;
  END IF;

  RAISE NOTICE 'Merging BS115: dup offering % → main offering %', v_dup_offering, v_main_offering;

  -- Re-link any enrollments from the dup to the Main offering
  UPDATE enrollments
  SET    offering_id = v_main_offering
  WHERE  offering_id = v_dup_offering
    AND  NOT EXISTS (
      SELECT 1 FROM enrollments e2
      WHERE  e2.student_id  = enrollments.student_id
        AND  e2.offering_id = v_main_offering
    );

  -- Remove orphaned enrollments that now would clash
  DELETE FROM enrollments
  WHERE  offering_id = v_dup_offering;

  -- Remove schedule slots for the dup offering
  DELETE FROM doctor_schedule_slots WHERE offering_id = v_dup_offering;

  -- Deactivate the duplicate offering
  UPDATE course_offerings
  SET    is_active = FALSE
  WHERE  id = v_dup_offering;

  RAISE NOTICE 'BS115 Section 2 offering deactivated.';
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Fix doctor schedule conflicts (same doctor, same day+time, same semester)
--    Move the conflicting slot to the next available 2-hour window that day,
--    or to the following day if no window is available.
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  r          RECORD;
  new_start  TIME;
  new_end    TIME;
  still_conflict BOOLEAN;
  try_day    TEXT;
  DAYS_ORDER TEXT[] := ARRAY['Sat','Sun','Mon','Tue','Wed','Thu'];
  d_idx      INT;
BEGIN
  FOR r IN (
    SELECT
      dss1.id          AS slot1_id,
      dss1.offering_id AS offering1,
      dss2.id          AS slot2_id,
      dss2.offering_id AS offering2,
      co1.doctor_id,
      dss1.day_of_week AS day,
      dss1.start_time  AS s1_start,
      dss1.end_time    AS s1_end,
      dss2.start_time  AS s2_start,
      dss2.end_time    AS s2_end
    FROM doctor_schedule_slots dss1
    JOIN course_offerings co1 ON co1.id = dss1.offering_id
    JOIN doctor_schedule_slots dss2 ON  dss2.offering_id != dss1.offering_id
                                     AND dss2.day_of_week  = dss1.day_of_week
    JOIN course_offerings co2 ON co2.id = dss2.offering_id
                              AND co2.doctor_id = co1.doctor_id
                              AND co2.semester_id = co1.semester_id
                              AND co2.is_active = TRUE
    WHERE co1.is_active = TRUE
      AND dss1.start_time < dss2.end_time
      AND dss1.end_time   > dss2.start_time
      AND dss1.id < dss2.id  -- avoid processing the same pair twice
  )
  LOOP
    RAISE NOTICE 'Conflict: slot % and slot % on %', r.slot1_id, r.slot2_id, r.day;

    -- Try to move slot2 to a non-conflicting window
    -- Start after the end of slot1, in 2-hour windows: 07:00, 09:00, 11:00, 13:00, 15:00
    new_start := NULL;
    FOREACH new_start IN ARRAY ARRAY['07:00'::TIME, '09:00'::TIME, '11:00'::TIME, '13:00'::TIME, '15:00'::TIME]
    LOOP
      new_end := new_start + (r.s2_end - r.s2_start);
      -- Skip windows that still overlap with the fixed slot
      IF new_start < r.s1_end AND new_end > r.s1_start THEN
        CONTINUE;
      END IF;
      -- Check no other conflict exists for this doctor on the same day at the new time
      SELECT EXISTS (
        SELECT 1
        FROM doctor_schedule_slots dss3
        JOIN course_offerings co3 ON co3.id = dss3.offering_id
        WHERE co3.doctor_id  = r.doctor_id
          AND co3.semester_id = (SELECT semester_id FROM course_offerings WHERE id = r.offering2)
          AND co3.is_active  = TRUE
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
        new_start := NULL;  -- signal success
        EXIT;
      END IF;
    END LOOP;

    -- If no window found on the same day, move to the next day
    IF new_start IS NOT NULL THEN
      d_idx := array_position(DAYS_ORDER, r.day) + 1;
      IF d_idx > array_length(DAYS_ORDER, 1) THEN d_idx := 1; END IF;
      try_day := DAYS_ORDER[d_idx];
      RAISE NOTICE 'Moving slot % to next day: %', r.slot2_id, try_day;
      UPDATE doctor_schedule_slots
      SET    day_of_week = try_day,
             start_time  = '09:00'::TIME,
             end_time     = '09:00'::TIME + (r.s2_end - r.s2_start)
      WHERE  id = r.slot2_id;
    END IF;
  END LOOP;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Populate total_grade from letter_grade for ALL completed enrollments
--    where total_grade is still NULL.
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE enrollments
SET total_grade = CASE letter_grade
  WHEN 'A+'  THEN 97.0
  WHEN 'A'   THEN 92.0
  WHEN 'A-'  THEN 88.0
  WHEN 'B+'  THEN 85.0
  WHEN 'B'   THEN 80.0
  WHEN 'B-'  THEN 77.0
  WHEN 'C+'  THEN 73.0
  WHEN 'C'   THEN 70.0
  WHEN 'C-'  THEN 67.0
  WHEN 'D+'  THEN 63.0
  WHEN 'D'   THEN 60.0
  WHEN 'D-'  THEN 57.0
  WHEN 'F'   THEN 45.0
  WHEN 'Abs' THEN 0.0
  ELSE NULL
END
WHERE status       = 'completed'
  AND total_grade  IS NULL
  AND letter_grade IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Rebuild semester_gpa_records for every student who has completed semesters
--    but is missing records (or has records with 0 GPA due to the r.gpa bug).
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_student   RECORD;
  v_sem       RECORD;
  v_cum_pts   NUMERIC := 0;
  v_cum_cred  INT     := 0;
  v_sem_gpa   NUMERIC(4,3);
  v_cum_gpa   NUMERIC(4,3);
  v_cls       VARCHAR(50);
BEGIN
  FOR v_student IN (SELECT id FROM students WHERE academic_status != 'withdrawn') LOOP
    v_cum_pts  := 0;
    v_cum_cred := 0;

    FOR v_sem IN (
      SELECT
        sem.id                          AS semester_id,
        COALESCE(SUM(c.credits), 0)     AS credits_att,
        COALESCE(SUM(CASE WHEN e.letter_grade NOT IN ('F','Abs','W','I')
                          THEN c.credits ELSE 0 END), 0) AS credits_pass,
        COALESCE(SUM(e.grade_points * c.credits), 0)     AS gp_earned
      FROM enrollments e
      JOIN course_offerings co ON co.id = e.offering_id
      JOIN courses           c  ON c.id  = co.course_id
      JOIN semesters         sem ON sem.id = e.semester_id
      WHERE e.student_id   = v_student.id
        AND e.status       = 'completed'
        AND e.grade_points IS NOT NULL
      GROUP BY sem.id, sem.start_date
      ORDER BY sem.start_date
    ) LOOP
      IF v_sem.credits_att = 0 THEN CONTINUE; END IF;

      v_sem_gpa  := ROUND(v_sem.gp_earned / v_sem.credits_att, 3);
      v_cum_pts  := v_cum_pts  + v_sem.gp_earned;
      v_cum_cred := v_cum_cred + v_sem.credits_att;
      v_cum_gpa  := ROUND(v_cum_pts / v_cum_cred, 3);

      v_cls := CASE
        WHEN v_sem_gpa >= 3.6 THEN 'ممتاز'
        WHEN v_sem_gpa >= 3.0 THEN 'جيد جداً'
        WHEN v_sem_gpa >= 2.0 THEN 'جيد'
        WHEN v_sem_gpa >= 1.0 THEN 'مقبول'
        ELSE 'راسب'
      END;

      INSERT INTO semester_gpa_records
        (student_id, semester_id, credits_attempted, credits_passed,
         grade_points_earned, semester_gpa, cumulative_gpa, classification)
      VALUES
        (v_student.id, v_sem.semester_id, v_sem.credits_att, v_sem.credits_pass,
         v_sem.gp_earned, v_sem_gpa, v_cum_gpa, v_cls)
      ON CONFLICT (student_id, semester_id) DO UPDATE SET
        credits_attempted   = EXCLUDED.credits_attempted,
        credits_passed      = EXCLUDED.credits_passed,
        grade_points_earned = EXCLUDED.grade_points_earned,
        semester_gpa        = EXCLUDED.semester_gpa,
        cumulative_gpa      = EXCLUDED.cumulative_gpa,
        classification      = EXCLUDED.classification,
        computed_at         = NOW();
    END LOOP;

    -- Sync student.cgpa to the latest cumulative GPA
    IF v_cum_cred > 0 THEN
      UPDATE students SET cgpa = v_cum_gpa WHERE id = v_student.id;
    END IF;
  END LOOP;

  RAISE NOTICE 'semester_gpa_records rebuilt for all students.';
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- Done
-- ─────────────────────────────────────────────────────────────────────────────
