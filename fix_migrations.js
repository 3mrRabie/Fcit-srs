const fs = require('fs');
const path = require('path');
const dir = 'database/migrations';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql'));

for (const f of files) {
  const file = path.join(dir, f);
  let content = fs.readFileSync(file, 'utf8');
  let modified = false;

  if (content.includes('Fall ')) {
    content = content.replace(/Fall /g, 'First Semester ');
    modified = true;
  }
  if (content.includes('Spring ')) {
    content = content.replace(/Spring /g, 'Second Semester ');
    modified = true;
  }
  if (content.includes("'fall'")) {
    content = content.replace(/'fall'/g, "'first'");
    modified = true;
  }
  if (content.includes("'spring'")) {
    content = content.replace(/'spring'/g, "'second'");
    modified = true;
  }

  if (modified) {
    fs.writeFileSync(file, content, 'utf8');
    console.log(`Updated ${file}`);
  }
}
