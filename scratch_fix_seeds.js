const fs = require('fs');

const filesToFix = [
  'e:/Collage/Projects/Rabee3/Fcit-srs-fixed/scripts/seed_generation/classes.sql',
  'e:/Collage/Projects/Rabee3/Fcit-srs-fixed/database/seeds/004_real_professors.sql',
  'e:/Collage/Projects/Rabee3/Fcit-srs-fixed/database/seeds/005_real_students.sql'
];

for (const file of filesToFix) {
  if (!fs.existsSync(file)) continue;
  
  let content = fs.readFileSync(file, 'utf-8');
  let updated = false;

  if (file.includes('classes.sql') || file.includes('004_real_professors.sql')) {
    // Replace IT317 with IT212 in course_offerings inserts for v_dr_marian
    const oldInsert = /SELECT id FROM courses WHERE code='IT317'\), v_dr_marian/g;
    if (oldInsert.test(content)) {
      content = content.replace(oldInsert, "SELECT id FROM courses WHERE code='IT212'), v_dr_marian");
      updated = true;
    }

    // Now fix the subsequent lookups that are right after the insert
    // This is tricky because we need to replace the next WHERE course_id=... code='IT317'
    // But since Dr. Tahani also teaches IT317, we can't blind replace.
    // Let's do it by finding blocks:
    const blockRegex = /VALUES \(v_spring2026_id, \(SELECT id FROM courses WHERE code='IT212'\), v_dr_marian[\s\S]{1,300}WHERE course_id=\(SELECT id FROM courses WHERE code='IT317'\)/g;
    
    if (blockRegex.test(content)) {
      content = content.replace(blockRegex, (match) => {
        return match.replace("code='IT317'", "code='IT212'");
      });
      updated = true;
    }
  }

  if (file.includes('005_real_students.sql')) {
    // Replace IT317 with IT212 where doctor_id looks up v_dr_marian
    const studentRegex = /code = 'IT317'\) AND semester_id = v_spring2026_id AND doctor_id = \(SELECT id FROM doctors WHERE user_id = v_dr_marian\)/g;
    if (studentRegex.test(content)) {
      content = content.replace(studentRegex, "code = 'IT212') AND semester_id = v_spring2026_id AND doctor_id = (SELECT id FROM doctors WHERE user_id = v_dr_marian)");
      updated = true;
    }
    
    // Also replace the RAISE WARNING strings
    const warningRegex = /RAISE WARNING 'Offering not found: IT317 Spring 2026 — skipping';/g;
    if (warningRegex.test(content)) {
       // but only if it's preceded by the IT212 lookup.
       // It's safe to just replace all IT317 -> IT212 inside the v_dr_marian blocks.
       // Actually, we can just blind replace all of these warnings if we know they follow the IT212 lookup.
       // Let's just do a specific replace for the block:
       content = content.replace(/course_id = \(SELECT id FROM courses WHERE code = 'IT212'\)([\s\S]{1,100})'Offering not found: IT317/g, "course_id = (SELECT id FROM courses WHERE code = 'IT212')$1'Offering not found: IT212");
       updated = true;
    }
  }

  if (updated) {
    fs.writeFileSync(file, content, 'utf-8');
    console.log(`Updated ${file}`);
  }
}
