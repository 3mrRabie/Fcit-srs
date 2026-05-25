-- =============================================================================
-- FIX-H3: Backfill doctor_schedule_slots
-- Parses legacy JSONB schedule array from course_offerings and inserts into
-- doctor_schedule_slots table.
-- =============================================================================

INSERT INTO doctor_schedule_slots (offering_id, day_of_week, start_time, end_time, room, session_type)
SELECT 
    co.id AS offering_id,
    (slot->>'day')::VARCHAR(10) AS day_of_week,
    (slot->>'startTime')::TIME AS start_time,
    (slot->>'endTime')::TIME AS end_time,
    COALESCE(slot->>'room', co.room) AS room,
    COALESCE(slot->>'type', 'lecture')::VARCHAR(20) AS session_type
FROM course_offerings co
CROSS JOIN jsonb_array_elements(
    CASE 
        WHEN jsonb_typeof(co.schedule) = 'array' THEN co.schedule 
        ELSE '[]'::jsonb 
    END
) AS slot
WHERE co.schedule IS NOT NULL
ON CONFLICT (offering_id, day_of_week, start_time) DO UPDATE SET
    end_time = EXCLUDED.end_time,
    room = EXCLUDED.room,
    session_type = EXCLUDED.session_type;
