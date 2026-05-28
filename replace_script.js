const fs = require('fs');
const path = require('path');

const filesToUpdate = [
  "backend/src/config/constants.js",
  "backend/src/controllers/admin.controller.js",
  "backend/src/services/bylaw.service.js",
  "database/enhancements.sql",
  "database/seeds/001_demo_users.sql",
  "database/seeds/005_real_students.sql",
  "database/seeds/006_demo_student_enrollments.sql",
  "database/seeds/007_fix_demo_student.sql",
  "frontend/src/pages/admin/AdminSemestersPage.jsx",
  "scripts/seed_generation/gen_seed.js",
  "scripts/seed_generation/gen_students_seed.js",
  "frontend/src/pages/doctor/DoctorSchedulePage.jsx",
  "frontend/src/pages/doctor/DoctorDashboard.jsx",
  "frontend/src/pages/doctor/DoctorCoursesPage.jsx",
  "frontend/src/pages/admin/AdminDashboardPage.jsx",
  "frontend/src/pages/student/StudentDashboard.jsx",
  "frontend/src/pages/student/StudentTimetable.jsx"
];

for (const relPath of filesToUpdate) {
  const fullPath = path.resolve(__dirname, relPath);
  if (!fs.existsSync(fullPath)) continue;

  let content = fs.readFileSync(fullPath, 'utf8');

  // Academic Levels
  content = content.replace(/'freshman'/g, "'الفرقة الأولى'");
  content = content.replace(/freshman:/g, "'الفرقة الأولى':");
  content = content.replace(/'sophomore'/g, "'الفرقة الثانية'");
  content = content.replace(/sophomore:/g, "'الفرقة الثانية':");
  content = content.replace(/'junior'/g, "'الفرقة الثالثة'");
  content = content.replace(/junior:/g, "'الفرقة الثالثة':");
  content = content.replace(/'senior'/g, "'الفرقة الرابعة'");
  content = content.replace(/senior:/g, "'الفرقة الرابعة':");

  // Semesters (Restoring the fall->first, spring->second replacements we wanted)
  content = content.replace(/'fall'/g, "'first'");
  content = content.replace(/'spring'/g, "'second'");
  content = content.replace(/Fall /g, "First Semester ");
  content = content.replace(/Spring /g, "Second Semester ");
  content = content.replace(/fall \| spring/g, "first | second");
  content = content.replace(/fall, spring, or summer/g, "first, second, or summer");
  
  // Specific frontend component updates
  content = content.replace(/fall:\s*'الترم الأول'/g, "first: 'الترم الأول'");
  content = content.replace(/spring:\s*'الترم الثاني'/g, "second: 'الترم الثاني'");
  content = content.replace(/الترم الأول \(الخريف\)/g, "الترم الأول");
  content = content.replace(/الترم الثاني \(الربيع\)/g, "الترم الثاني");

  fs.writeFileSync(fullPath, content, 'utf8');
}

console.log('UTF-8 Replacement Complete!');
