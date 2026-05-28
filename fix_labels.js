const fs = require('fs');
const path = require('path');

function processDir(dir) {
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql'));
  for (const f of files) {
    const file = path.join(dir, f);
    let content = fs.readFileSync(file, 'utf8');
    let modified = false;

    if (content.includes('First Semester ')) {
      content = content.replace(/First Semester /g, 'الترم الأول ');
      modified = true;
    }
    if (content.includes('Second Semester ')) {
      content = content.replace(/Second Semester /g, 'الترم الثاني ');
      modified = true;
    }
    if (content.includes('Summer Semester ')) {
      content = content.replace(/Summer Semester /g, 'الترم الصيفي ');
      modified = true;
    }
    if (content.includes('Summer 20')) {
      content = content.replace(/Summer 20/g, 'الترم الصيفي 20');
      modified = true;
    }

    if (modified) {
      fs.writeFileSync(file, content, 'utf8');
      console.log(`Updated ${file}`);
    }
  }
}

processDir('database/seeds');
processDir('database/migrations');
