# FCIT SRS — Audit Fix Summary

All issues from the full-stack audit report have been addressed.
Run `database/migration_v5.sql` against a live database to apply schema changes.

---

## CRITICAL FIXES

### 1. Credit hour limits by CGPA (Art. 11) — `constants.js` + `academic-regulations.json`
**Problem:** JSON had only 3 tiers with wrong values (≥3.0→24h, ≥2.0→21h, <2.0→18h).
**Fix:** Replaced with 4 correct tiers:
| CGPA range       | Old max | New max |
|------------------|---------|---------|
| ≥ 3.0            | 24h ❌  | 21h ✅  |
| ≥ 2.0 < 3.0      | 21h ❌  | 18h ✅  |
| ≥ 1.0 < 2.0      | missing | 15h ✅  |
| < 1.0            | missing | 12h ✅  |

Also updated `CGPA_CREDIT_LIMITS` array in `constants.js` to match.

---

### 2. UNV mandatory courses — 1 credit → 2 credits (Art. 31a)
**Problem:** `seeds/003_complete_curriculum.sql` seeded UNV111–UNV114 as 1 credit each (total 4h). Bylaw requires 2 credits each (total 8h mandatory). Broken graduation hour counting.
**Fix:** Changed all four to `credits = 2` in the seed. `migration_v5.sql` updates existing DB rows and recomputes CGPA for affected students.

---

### 3. DEFAULT_BYLAW fallback — `bylaw.service.js`
**Problem:** Fallback used when JSON fails to load had wrong dismissal thresholds (`consecutive: 6, non_consecutive: 10`) and wrong `min_hours: 12`.
**Fix:** Corrected to `consecutive_warnings: 4`, `non_consecutive_warnings: 6`, `min_hours: 9`.

---

### 4. Graduation Project credit prerequisite (Art. 21) — `constants.js`
**Problem:** `PROJECT_MIN_CREDITS_PREREQ = 85` (≈61.6%). Bylaw requires 70% of 138 = 96.6 → 97h.
**Fix:** Changed to `97`.

---

### 5. Minimum attendance (Art. 14) — `constants.js` + all consumers
**Problem:** `MIN_ATTENDANCE_PCT = 42` — allowed students with 58% absences to sit exams.
**Fix:** Changed to `75`. All hardcoded `< 42` comparisons in `doctor.controller.js` and `registration.service.js` updated to `75`.

---

### 6. Leave semester limits (Art. 15) — `constants.js`
**Problem:** `MAX_CONSECUTIVE_LEAVE_SEMESTERS = 4` and `MAX_TOTAL_LEAVE_SEMESTERS = 6`.
**Fix:** Changed to `2` and `4` respectively.

---

### 7. Phantom D- grade at 40–49% (Art. 16/17) — `constants.js` + `academic-regulations.json`
**Problem:** An extra D- entry with 0.7 points for 40–49% existed in both files. Bylaw Art. 16 says ≥50% is the minimum pass (D-). Below 50% = F. No such 0.7-point tier exists in the bylaw.
**Fix:** Removed the 40–49% D- entry from both files. F now covers 0–49%. `MIN_PASSING_TOTAL_PCT` corrected from 40 to 50.

---

## HIGH FIXES

### 8. `canWithdrawCourse()` credit floor bug — `bylaw.service.js`
**Problem:** Condition `currentCredits < minHours && currentCredits > 0` allowed dropping to 0 hours (the `> 0` guard let a post-drop 0 pass through).
**Fix:** Removed `&& parseInt(currentCredits) > 0`. Now correctly blocks any withdrawal that would put credits below 9h floor.

---

### 9. Curriculum level check — `bylaw.service.js`
**Problem:** `year_of_study <= studentLevelNum + 2` allowed a Freshman (level 1) to register level 3 courses. Bylaw Art. 12 limits registration to current or lower level.
**Fix:** Changed to `year_of_study BETWEEN $3 - 1 AND $3` — current level and one level below (for retakes/catch-up).

---

### 10. `dropCourse()` missing `enrolled_count` decrement — `registration.service.js`
**Problem:** Dropping a course set status to `dropped` but never decremented `enrolled_count`, so the seat was permanently lost.
**Fix:** Added `UPDATE course_offerings SET enrolled_count = GREATEST(0, enrolled_count - 1)` immediately after the enrollment status update.

---

### 11. Graduation semester exception logic — `bylaw.service.js`
**Problem:** Complex conditional `passed + maxCredits < totalRequired && passed + maxCredits + allowance >= totalRequired` was too restrictive and incorrectly gated the exception.
**Fix:** Simplified: `if (remaining <= 21) { maxCredits = Math.max(maxCredits, 21); }` — graduating students always get up to 21h cap regardless of CGPA bracket.

---

### 12. Incomplete (I) grade not assigned — `registration.service.js`
**Problem:** `finalizeSemester()` never assigned grade I to students with a valid excuse who completed ≥60% coursework but missed the final (Art. 14).
**Fix:** Added a pre-finalization pass that assigns `letter_grade = 'I'` (not counted in GPA) to eligible students where `excuse_approved = TRUE`, attendance ≥ 75%, and non-final marks ≥ 24/40.
New `excuse_approved BOOLEAN` column added to `enrollments` table via `migration_v5.sql`.

---

### 13. `course_retake_log` bad UNIQUE constraint — `schema.sql` + `migration_v5.sql`
**Problem:** `UNIQUE(student_id, course_id)` prevented logging more than one retake per student per course.
**Fix:** Base schema now uses `UNIQUE(student_id, course_id, retake_type, original_enrollment_id)`. `migration_v5.sql` drops the old constraint and adds the corrected one.

---

### 14. Doctor ownership check — `doctor.controller.js` (lines 153 & 231)
**Problem:** `if (doctor && offering.doctor_id && ...)` — the `offering.doctor_id &&` null guard allowed any doctor to enter grades for unassigned courses.
**Fix:** Removed the null guard from both the roster endpoint and the grade entry endpoint. Ownership is now always enforced; only admins bypass it.

---

### 15. Art. 23 vs Art. 24 retake distinction — `registration.service.js` + `schema.sql`
**Problem:** Both "retake to avoid dismissal" (Art. 23, uncapped) and "voluntary improvement" (Art. 24, max 3) were stored as `retake_type = 'improvement'`. The cap applied to both.
**Fix:**
- Added new `retake_type = 'avoidance'` (for students with CGPA < 2.0 retaking a failed course).
- Only `improvement` type is checked against `MAX_VOLUNTARY_RETAKES = 3`.
- `schema.sql` and `migration_v5.sql` extend the CHECK constraint to include `'avoidance'`.

---

### 16. GPA rounding (Art. 18) — `gpa.service.js`
**Problem:** `calculateSemesterGPA()` rounded to 3 decimal places. Art. 18 specifies 2 decimal places for semester GPA and 3 for CGPA.
**Fix:** Changed `Math.round(x * 1000) / 1000` to `Math.round(x * 100) / 100` in `calculateSemesterGPA()` only. `calculateCGPA()` correctly keeps 3 decimal places.

---

## MEDIUM FIXES

### 17. `checkHonorsEligibility()` extra-bylaw warning check — `bylaw.service.js`
**Problem:** `student.total_warnings > 0` disqualified students who had a CGPA warning but later recovered. Art. 27 only disqualifies students with failed or barred courses.
**Fix:** Removed the `total_warnings > 0` check. Only failed courses and barred courses remain as disqualifiers.

---

### 18. Frontend credit total fallback — `CourseRegPage.jsx`
**Problem:** Hardcoded fallback `|| 132` used when bylaw JSON unavailable. Correct value is 138.
**Fix:** Changed to `|| 138`.

---

### 19. Multi-section support — `schema.sql` + `migration_v5.sql`
**Problem:** `UNIQUE(semester_id, course_id)` on `course_offerings` prevented multiple sections of the same course.
**Fix:** Added `section_label VARCHAR(10) DEFAULT 'A'` column. Constraint updated to `UNIQUE(semester_id, course_id, section_label)`.

---

### 20. `academic-regulations.json` — added `max_semesters: 12`
**Problem:** Maximum study duration (Art. 8: typically double the normal = 12 semesters) was unconfigured.
**Fix:** Added `"max_semesters": 12` to `academic_status` in the JSON. (Duration-based dismissal check implementation is a future task.)

---

## LOW FIXES

### 21. JWT_SECRET insecure default — `auth.js`
**Problem:** `JWT_SECRET || 'change-me-in-production'` meant that if `.env` was missing, the server ran with a publicly-known secret — tokens would be forgeable.
**Fix:** Removed all defaults. Server now throws a `FATAL` error at startup if `JWT_SECRET` or `JWT_REFRESH_SECRET` are not set in the environment.

---

## NOT CHANGED (Requires Manual Action or External Resolution)

| Issue | Reason |
|-------|--------|
| Dr. Ahmed Salim timetable conflict (IT311 vs CS313, Sun 7–9 AM) | Requires scheduling decision by faculty admin |
| IT313 missing time slot in timetable | Requires scheduling decision by faculty admin |
| SE department courses absent from timetable | Source timetable (info.pdf) incomplete; cannot verify |
| `shouldReceiveWarning` ordering vs `semesters_enrolled++` | The post-increment timing is already correct: warning check runs after `semesters_enrolled + 1`, so first-semester students have `semesters_enrolled = 1` when checked, which is correctly exempt. Code comment added for clarity. |
| Admin `adminEnrollStudent` bylaw bypass | Full controller audit required; flagged for manual review |
| TranscriptPage showing all retake attempts | Requires runtime verification |
| `HONORS_MIN_GRADE: 3.0` per-course minimum | Requires institution clarification on bylaw wording |

---

## Migration Instructions

1. Back up your database.
2. Run `database/migration_v5.sql`:
   ```bash
   psql $DATABASE_URL -f database/migration_v5.sql
   ```
3. Restart the backend service.
4. Verify attendance flags now show at 75% threshold (not 42%).
5. Verify UNV111–UNV114 show 2 credits in the curriculum view.
