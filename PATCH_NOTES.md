# FCIT-SRS Patch Notes

---

## [PATCH-019] Database Integration — 2026-05-28

### Files Added
| File | Destination in project | Purpose |
|------|------------------------|---------|
| `fcit_db_patch.sql` | `database/migrations/019_db_patch.sql` | Authoritative data patch |
| `fcit_courses_bylaw.json` | `database/fcit_courses_bylaw.json` | Bylaw course catalog (JSON reference) |
| `fcit_schedule_corrected.json` | `database/fcit_schedule_corrected.json` | Corrected schedule data (JSON reference) |

### Files Modified
- `backend/src/utils/setup.js` — Added `migrations/019_db_patch.sql` to `namedMigrations` list so it runs automatically on next startup (once-only via `migration_logs` guard).

### What This Patch Fixes

**Section 1 — Course Catalog (`curriculum_plans`)**
Full upsert of the complete bylaw-accurate course catalog across all 4 programs (CS, IS, IT, SE) plus University and College requirements. Uses `ON CONFLICT (code) DO UPDATE` so it is safe to run on existing data.

**Section 2 — Prerequisites**
Replaces all 72 prerequisite relationships from the official bylaw. Covers corrections previously flagged by migrations 015–018. Deletes only the affected course codes before re-inserting to avoid collateral damage.

**Section 3 — FIX-001: IT317 → IT212 for Dr. Marian Wagdy (CRITICAL)**
IT317 (Advanced Computer Networks) was incorrectly assigned to Dr. Marian Wagdy. The patch renames or removes that offering and ensures Dr. Marian correctly holds IT212 (Computer Network Technology) in both `course_offerings` and `doctor_schedule_slots`.

**Section 4 — Schedule Seed (`doctor_schedule_slots`)**
Full re-seed of all schedule slots from the corrected `info.pdf` data. Resolves the IT317/IT212 assignment. Remaining open issues are preserved as `RAISE NOTICE` in the SQL and documented in `fcit_schedule_corrected.json`.

**Section 5 — Audit Log**
Inserts a `DATA_PATCH` audit record with all applied fixes and flagged issues for traceability.

### Known Remaining Issues (not blocking)
| ID | Severity | Description |
|----|----------|-------------|
| ISSUE-002 | HIGH | Scheduling conflict: IT311 & CS313 both assigned to Dr. Ahmed Salim, Sunday 07:00–09:00, Y3-CS-T1 |
| ISSUE-003 | MEDIUM | Unmatched course "المتحكمات الدقيقة" (Y4-IT-T1) — possible IT315 duplicate |
| ISSUE-004 | MEDIUM | Unmatched course "الواقع الافتراضي" (Virtual Reality, Y4-IT-T1) — not in IT bylaw |
| ISSUE-005 | MEDIUM | Unmatched course "معالجة الاشارات الرقمية" (Y4-IT-T2) — not in IT bylaw |
| ISSUE-006 | MEDIUM | Unmatched course "مفاهيم لغات الحاسب" (Y4-CS-T1) — possible CS416 rename |
| ISSUE-007 | MEDIUM | Unmatched course "ادارة ونمذجة البيانات الكبيرة" (Y4-IS-T2) |
| ISSUE-008 | MEDIUM | Unmatched course "هيكليات خدمة التوجه" (SOA, Y4-IS-T2) |

See `database/fcit_schedule_corrected.json` → `issues_flagged` for full details.

### How to Apply
The migration is applied **automatically** on next container restart via `setup.js`.

To apply manually (e.g. on a running database):
```bash
# Inside Docker
docker compose exec postgres psql -U postgres -d student_registration_system \
  -f /app/database/migrations/019_db_patch.sql

# Or directly
psql -U postgres -d student_registration_system \
  -f database/migrations/019_db_patch.sql
```

---

# FCIT-SRS Patch — 3 Root-Cause Fixes

## Files Changed

### 1. `backend/src/services/gpa.service.js`
**Bug fixed:** Grade save returns HTTP 400 with message `getBylaw is not a function`

**Root cause:** Circular module dependency.
- `bylaw.service.js` requires `gpa.service.js`
- `gpa.service.js` required `bylaw.service.js` at module top level

Node.js resolves circular dependencies by returning a *partially-evaluated* module.
Whichever loads second gets the other's `module.exports` before it is fully assigned,
so `{ getBylaw }` destructures as `undefined`. Any call to `getBylaw()` inside
`percentageToLetter` or `percentageToPoints` then throws
`TypeError: getBylaw is not a function`, which the controller converts to a 400 response.

**Fix:** Removed the top-level `require('./bylaw.service')`. Added a **lazy require**
*inside* each function that needs `getBylaw()`. Node's module cache means this is only
evaluated once — no performance penalty — and the circular dependency is fully broken.

---

### 2. `backend/src/controllers/admin.extensions.js`
**Bugs fixed:**
a) Student count shows `0` in "Courses and Academic Tasks" on the schedule page
b) Schedule page provides no warning when two courses are assigned overlapping times

**Root cause (a):** `getDoctorOwnSchedule` selected `co.enrolled_count`, a *denormalised*
counter column on `course_offerings`. This counter can drift out of sync with actual
enrollments (trigger misfire, manual DB edits, etc.). The live truth is in the
`enrollments` table.

**Fix (a):** Replaced `co.enrolled_count` in the SELECT with a live correlated subquery:
```sql
(SELECT COUNT(*) FROM enrollments e
 WHERE e.offering_id = co.id
   AND e.status IN ('registered','completed')) AS enrolled_count
```
Also updated `totalStudents` in the API response to use this live count.

**Root cause (b):** The per-slot conflict check in `assignScheduleToOffering` prevents
*new* overlaps, but legacy/seed data may already contain them. Once persisted, nothing
in the read path flagged them for the doctor.

**Fix (b):** Added an overlap-detection loop after building `weeklyGrid`. It sets
`hasConflict: true` on every conflicting slot object and populates a `scheduleConflicts`
array returned in the API response. No DB changes required.

---

### 3. `frontend/src/pages/doctor/DoctorSchedulePage.jsx`
**Bugs fixed:** (UI side of fixes 2a and 2b above)

**Changes:**
- `totalStudents` now reads `data.totalStudents` from the backend (live count) instead of
  summing the stale `o.enrolled_count` fields client-side.
- `scheduleConflicts` array is read from the response.
- **Conflict banner:** rendered above the stats row when `scheduleConflicts.length > 0`,
  listing every conflicting course pair with day/time details and a call to action.
- **SlotCard:** conflicting slots get a red border, red background, red "⚠ تعارض" label,
  and a glow box-shadow. Hover tooltip also mentions the conflict.
