const { query } = require('../config/database');
const registrationService = require('../services/registration.service');
const bylawService = require('../services/bylaw.service');
const gpaService = require('../services/gpa.service');

// ── Get student profile ──────────────────────────────────────────────────────
const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await query(
      `SELECT s.*, u.email, u.full_name_ar, u.full_name_en, u.phone, u.national_id,
              dep.name_en as department_name,
              adv.full_name_en as advisor_name
       FROM students s
       JOIN users u ON u.id = s.user_id
       LEFT JOIN departments dep ON dep.code::text = s.specialization::text
       LEFT JOIN users adv ON adv.id = s.advisor_id
       WHERE s.user_id = $1`,
      [userId]
    );
    const studentData = result.rows[0];
    if (!studentData) return res.status(404).json({ success: false, message: 'Student not found' });
    
    // Inject dynamic level
    const levelInfo = bylawService.creditsToLevel(studentData.total_credits_passed);
    studentData.current_level = levelInfo.name_ar;
    // Inject program: عام for level 1-2, specialization name for level 3-4
    studentData.program = (levelInfo.id || 1) <= 2 ? 'عام' : (studentData.specialization || 'عام');
    
    return res.json({ success: true, data: studentData });
  } catch (err) { next(err); }
};

// ── Dashboard summary ────────────────────────────────────────────────────────
const getDashboard = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const student = (await query('SELECT * FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const currentSem = (await query(
      `SELECT s.*, y.year_label 
       FROM semesters s 
       JOIN academic_years y ON y.id = s.academic_year_id 
       WHERE s.status IN ('registration','active','grading')
       ORDER BY 
         CASE s.status WHEN 'registration' THEN 1 WHEN 'active' THEN 2 ELSE 3 END,
         s.start_date DESC 
       LIMIT 1`
    )).rows[0];

    const schedule = currentSem
      ? await registrationService.getStudentSchedule(student.id, currentSem.id)
      : [];

    const recentGPA = (await query(
      `SELECT sg.semester_gpa, sg.cumulative_gpa, sg.classification, sem.label, sem.semester_type, y.year_label
       FROM semester_gpa_records sg 
       JOIN semesters sem ON sem.id = sg.semester_id
       LEFT JOIN academic_years y ON y.id = sem.academic_year_id
       WHERE sg.student_id = $1 ORDER BY sem.start_date DESC LIMIT 4`,
      [student.id]
    )).rows;

    const notifications = (await query(
      'SELECT * FROM notifications WHERE user_id = $1 AND is_read = FALSE ORDER BY created_at DESC LIMIT 5',
      [userId]
    )).rows;

    const warnings = (await query(
      `SELECT aw.*, sem.label as semester_label, sem.semester_type, y.year_label 
       FROM academic_warnings aw
       JOIN semesters sem ON sem.id = aw.semester_id
       LEFT JOIN academic_years y ON y.id = sem.academic_year_id
       WHERE aw.student_id = $1 ORDER BY aw.issued_at DESC LIMIT 3`,
      [student.id]
    )).rows;

    const eligibility = await bylawService.checkGraduationEligibility(student.id);

    const levelInfo = bylawService.creditsToLevel(student.total_credits_passed);
    if (student) {
      student.current_level = levelInfo.name_ar;
      // Inject program: عام for level 1-2, specialization for level 3-4
      student.program = (levelInfo.id || 1) <= 2 ? 'عام' : (student.specialization || 'عام');
    }
    if (currentSem) currentSem.label = bylawService.getSemesterLabel(currentSem.semester_type, currentSem.year_label);
    
    // Also update recentGPA to have dynamic semester names if it joins semesters table, but it joined sem.label already. We will dynamically format recentGPA and warnings.
    recentGPA.forEach(g => { g.label = bylawService.getSemesterLabel(g.semester_type, g.year_label) || g.label; });
    warnings.forEach(w => { w.semester_label = bylawService.getSemesterLabel(w.semester_type, w.year_label) || w.semester_label; });

    return res.json({
      success: true,
      data: {
        student,
        currentSemester: currentSem,
        schedule,
        recentGPA,
        notifications,
        warnings,
        graduationEligibility: eligibility,
      }
    });
  } catch (err) { next(err); }
};

// [C5-FIX] Now filters courses by student level AND semester registration state
// Students ONLY see courses at or below their academic level.
// Level is now dynamically computed from bylaw via creditsToLevel()

const getAvailableCourses = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { semesterId } = req.params;

    const student = (await query('SELECT * FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    // [C5-FIX] Determine numeric level for this student dynamically from bylaw
    const studentLevelNum = bylawService.creditsToLevel(student.total_credits_passed).id || 1;
    // General program: level 1-2 students have no specialization restriction
    const isGeneralProgram = studentLevelNum <= 2;

    // [C8-FIX] Verify registration is actually open for this semester
    const semester = (await query('SELECT * FROM semesters WHERE id = $1', [semesterId])).rows[0];
    if (!semester) return res.status(404).json({ success: false, message: 'Semester not found' });

    const registrationOpen = semester.status === 'registration';
    const addDropOpen = semester.status === 'active' && new Date() <= new Date(semester.add_drop_deadline);
    const canRegisterNew = registrationOpen || addDropOpen; // Fix: Allow registration during both
    const canDropAdd = addDropOpen;          // Only within add/drop window

    const sqlParams = isGeneralProgram
      ? [student.id, semesterId, studentLevelNum, ['GENERAL']]
      : [student.id, semesterId, studentLevelNum, [student.specialization || 'CS', 'GENERAL']];

    // Get all offerings for the semester, filtering by student's level and specialization via curriculum_plans
    const offerings = await query(
      `SELECT DISTINCT co.id as offering_id, co.capacity, co.enrolled_count, co.schedule, co.room,
              c.id as course_id, c.code, c.name_ar, c.name_en, c.credits, c.category,
              c.level as course_level, cp.is_mandatory,
              u.full_name_en as doctor_name,
              dep.code as department_code,
              -- Check if already registered
              CASE WHEN e.id IS NOT NULL THEN TRUE ELSE FALSE END as already_registered,
              e.id as enrollment_id,
              e.status as enrollment_status
       FROM course_offerings co
       JOIN courses c ON c.id = co.course_id
       JOIN curriculum_plans cp ON cp.course_id = c.id
       JOIN semesters sem ON sem.id = co.semester_id
       LEFT JOIN doctors d ON d.id = co.doctor_id
       LEFT JOIN users u ON u.id = d.user_id
       LEFT JOIN departments dep ON dep.id = c.department_id
       LEFT JOIN enrollments e ON e.offering_id = co.id AND e.student_id = $1
         AND e.status IN ('registered','completed')
       WHERE co.semester_id = $2
         AND co.is_active = TRUE
         AND c.is_active = TRUE
         -- RELAXED CURRICULUM RULES: allow current year, retakes, and 1 year ahead
         AND cp.year_of_study <= ($3 + 1)
         AND cp.specialization = ANY($4::text[])
         -- STRICT SEMESTER MAPPING FOR FRESHMEN: Ensure Level 1 students don't see Spring courses in Fall
         AND (
           $3 > 1 OR 
           (sem.semester_type = 'fall' AND cp.semester_in_year = 1) OR 
           (sem.semester_type = 'spring' AND cp.semester_in_year = 2) OR 
           sem.semester_type = 'summer'
         )
       ORDER BY c.code`,
      sqlParams
    );

    let finalOfferings = offerings;
    // Removed redundant summer fallback logic because relaxed curriculum rules handle it natively

    // Bulk fetch prerequisites
    const courseIds = [...new Set(finalOfferings.rows.map(o => o.course_id))];
    const prereqMap = {};
    if (courseIds.length > 0) {
      const prereqs = await query(
        `SELECT cp.course_id, c2.code, c2.name_ar, cp.prereq_course_id
         FROM course_prerequisites cp
         JOIN courses c2 ON c2.id = cp.prereq_course_id
         WHERE cp.course_id = ANY($1::int[])`,
        [courseIds]
      );
      for (const p of prereqs.rows) {
        if (!prereqMap[p.course_id]) prereqMap[p.course_id] = [];
        prereqMap[p.course_id].push(p);
      }
    }

    // Bulk fetch passed courses for student
    const passedCourses = await query(
      `SELECT co.course_id 
       FROM enrollments e
       JOIN course_offerings co ON co.id = e.offering_id
       WHERE e.student_id = $1 AND e.status = 'completed' AND e.letter_grade NOT IN ('F','Abs','W','I')`,
      [student.id]
    );
    const passedSet = new Set(passedCourses.rows.map(r => r.course_id));

    // Bulk fetch retake logic
    const voluntaryCount = parseInt((await query(
      `SELECT COUNT(*) FROM course_retake_log WHERE student_id = $1 AND retake_type = 'improvement'`,
      [student.id]
    )).rows[0].count, 10);
    const { C } = require('../config/constants');
    const bylawSvc = require('../services/bylaw.service');
    const maxCredits = await bylawSvc.getMaxCreditsForSemester(student.id, semesterId, { student, semester }) || 20;

    const currentCredits = parseInt((await query(
      `SELECT COALESCE(SUM(c.credits), 0) as total
       FROM enrollments e JOIN course_offerings co ON co.id = e.offering_id JOIN courses c ON c.id = co.course_id
       WHERE e.student_id = $1 AND e.semester_id = $2 AND e.status = 'registered'`,
      [student.id, semesterId]
    )).rows[0].total, 10);

    // For each offering, map the bulk-fetched rules in memory
    const enriched = finalOfferings.rows.map((o) => {
      if (o.already_registered) {
        return { ...o, can_register: false, register_block_reason: 'Already registered' };
      }

      // [C8-FIX] Block registration outside of open windows
      if (!canRegisterNew && !canDropAdd) {
        return {
          ...o,
          can_register: false,
          register_block_reason: `Registration is closed. Current semester status: ${semester.status}`
        };
      }

      if (o.enrolled_count >= o.capacity) {
        return { ...o, can_register: false, register_block_reason: 'Course is full', registration_window_open: canRegisterNew || canDropAdd };
      }

      if (currentCredits + o.credits > maxCredits) {
        return {
          ...o,
          can_register: false,
          register_block_reason: `Adding ${o.credits} cr would exceed your ${maxCredits}-credit limit (currently at ${currentCredits})`,
          registration_window_open: canRegisterNew || canDropAdd
        };
      }

      if (o.category === 'project' && o.code === 'PR411') {
        if (student.total_credits_passed < C.PROJECT_MIN_CREDITS_PREREQ) {
          return {
            ...o,
            can_register: false,
            register_block_reason: `Must pass at least ${C.PROJECT_MIN_CREDITS_PREREQ} credits before Graduation Project (1). Current: ${student.total_credits_passed}`,
            registration_window_open: canRegisterNew || canDropAdd
          };
        }
      }

      const coursePrereqs = prereqMap[o.course_id] || [];
      const failedPrereqs = coursePrereqs.filter(p => !passedSet.has(p.prereq_course_id));
      if (failedPrereqs.length > 0) {
        return {
          ...o,
          can_register: false,
          register_block_reason: `يجب اجتياز المتطلب السابق أولاً: ${failedPrereqs.map(p => `${p.code} (${p.name_ar})`).join('، ')}`,
          registration_window_open: canRegisterNew || canDropAdd,
        };
      }

      if (passedSet.has(o.course_id)) {
        if (voluntaryCount >= C.MAX_VOLUNTARY_RETAKES) {
          return {
            ...o,
            can_register: false,
            register_block_reason: `Maximum ${C.MAX_VOLUNTARY_RETAKES} voluntary improvement retakes allowed`,
            registration_window_open: canRegisterNew || canDropAdd
          };
        }
      }

      return {
        ...o,
        can_register: true,
        register_block_reason: null,
        registration_window_open: canRegisterNew || canDropAdd,
      };
    });

    return res.json({
      success: true,
      data: enriched,
      meta: {
        semester_status:   semester.status,
        registration_open: canRegisterNew,
        add_drop_open:     canDropAdd,
        student_level:     student.current_level,
        student_level_num: studentLevelNum,
        // BUG-016: registered credits counter for UI
        registeredCredits: enriched.filter(c => c.already_registered).reduce((s,c) => s + (c.credits||0), 0),
        maxCredits:        await (async () => {
          try {
            const bylawSvc = require('../services/bylaw.service');
            return await bylawSvc.getMaxCreditsForSemester(student.id, semester.id) || 20;
          } catch { return 20; }
        })(),
      }
    });
  } catch (err) { next(err); }
};

// ── Register for a course ────────────────────────────────────────────────────
const registerCourse = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { offeringId } = req.body;

    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const enrollment = await registrationService.registerCourse(student.id, offeringId);
    return res.status(201).json({ success: true, message: 'Registered successfully', data: enrollment });
  } catch (err) {
    if (err.message) return res.status(400).json({ success: false, message: err.message });
    next(err);
  }
};

// ── Drop a course (within add/drop period) ───────────────────────────────────
const dropCourse = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { enrollmentId } = req.params;

    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    await registrationService.dropCourse(enrollmentId, student.id);
    return res.json({ success: true, message: 'Course dropped successfully' });
  } catch (err) {
    if (err.message) return res.status(400).json({ success: false, message: err.message });
    next(err);
  }
};

// ── Withdraw from a course ───────────────────────────────────────────────────
const withdrawCourse = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { enrollmentId } = req.params;
    const { reason } = req.body;

    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const result = await registrationService.withdrawCourse(enrollmentId, student.id, reason);
    return res.json({ success: true, message: 'Withdrawn with W grade recorded', data: result });
  } catch (err) {
    if (err.message) return res.status(400).json({ success: false, message: err.message });
    next(err);
  }
};

// ── Get transcript ────────────────────────────────────────────────────────────
const getTranscript = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const studentFull = (await query(
      `SELECT s.*, u.full_name_ar, u.full_name_en FROM students s
       JOIN users u ON u.id = s.user_id WHERE s.user_id = $1`,
      [userId]
    )).rows[0];
    if (!studentFull) return res.status(404).json({ success: false, message: 'Student not found' });

    const transcript = await query(
      `SELECT t.*, sem.semester_type, y.year_label 
       FROM v_student_transcript t
       JOIN semesters sem ON sem.id = t.semester_id
       LEFT JOIN academic_years y ON y.id = sem.academic_year_id
       WHERE t.student_id = $1 ORDER BY sem.start_date, t.course_code`,
      [studentFull.id]
    );

    const gpaHistory = await query(
      `SELECT sg.*, sem.label, sem.semester_type, y.year_label 
       FROM semester_gpa_records sg
       JOIN semesters sem ON sem.id = sg.semester_id
       LEFT JOIN academic_years y ON y.id = sem.academic_year_id
       WHERE sg.student_id = $1 ORDER BY sem.start_date`,
      [studentFull.id]
    );

    // Format semesters
    transcript.rows.forEach(r => { r.semester_name = bylawService.getSemesterLabel(r.semester_type, r.year_label) || r.semester_name; });
    gpaHistory.rows.forEach(r => { r.label = bylawService.getSemesterLabel(r.semester_type, r.year_label) || r.label; });

    // Group transcript into semesters
    const semestersMap = {};
    transcript.rows.forEach(course => {
      const semName = course.semester_name;
      if (!semestersMap[semName]) {
        semestersMap[semName] = { semester_name: semName, courses: [] };
      }
      semestersMap[semName].courses.push(course);
    });
    const groupedSemesters = Object.values(semestersMap);

    return res.json({
      success: true,
      data: {
        student: {
          studentCode: studentFull.student_code,
          fullNameAr: studentFull.full_name_ar,
          fullNameEn: studentFull.full_name_en,
          specialization: studentFull.specialization,
          currentLevel: bylawService.creditsToLevel(studentFull.total_credits_passed).name_ar,
          cgpa: studentFull.cgpa,
          totalCreditsPassed: studentFull.total_credits_passed,
          academicStatus: studentFull.academic_status,
          gpaClassification: gpaService.getCGPAClassification(parseFloat(studentFull.cgpa)),
        },
        semesters: groupedSemesters,
        gpaHistory: gpaHistory.rows,
      }
    });
  } catch (err) { next(err); }
};

// ── Get schedule ──────────────────────────────────────────────────────────────
const getSchedule = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { semesterId } = req.params;
    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const schedule = await registrationService.getStudentSchedule(student.id, semesterId);
    return res.json({ success: true, data: schedule });
  } catch (err) { next(err); }
};

// ── Get academic warnings ─────────────────────────────────────────────────────
const getWarnings = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const warnings = await query(
      `SELECT aw.*, sem.label as semester_label FROM academic_warnings aw
       JOIN semesters sem ON sem.id = aw.semester_id
       WHERE aw.student_id = $1 ORDER BY aw.issued_at DESC`,
      [student.id]
    );

    return res.json({ success: true, data: warnings.rows });
  } catch (err) { next(err); }
};

// ── Get notifications ─────────────────────────────────────────────────────────
const getNotifications = async (req, res, next) => {
  try {
    const notifs = await query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50',
      [req.user.id]
    );
    return res.json({ success: true, data: notifs.rows });
  } catch (err) { next(err); }
};

const markNotificationRead = async (req, res, next) => {
  try {
    await query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2',
      [req.params.notifId, req.user.id]
    );
    return res.json({ success: true });
  } catch (err) { next(err); }
};

// ── Graduation eligibility ────────────────────────────────────────────────────
const getGraduationStatus = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const student = (await query('SELECT id FROM students WHERE user_id = $1', [userId])).rows[0];
    if (!student) return res.status(404).json({ success: false, message: 'Student not found' });

    const eligibility = await bylawService.checkGraduationEligibility(student.id);
    const honors = await bylawService.checkHonorsEligibility(student.id);

    return res.json({ success: true, data: { eligibility, honors } });
  } catch (err) { next(err); }
};

module.exports = {
  getProfile, getDashboard, getAvailableCourses, registerCourse,
  dropCourse, withdrawCourse, getTranscript, getSchedule,
  getWarnings, getNotifications, markNotificationRead, getGraduationStatus
};
