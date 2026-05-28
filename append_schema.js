const fs = require('fs');
const file = 'database/schema.sql';
let content = fs.readFileSync(file, 'utf8');
content += `

CREATE TABLE IF NOT EXISTS doctor_schedule_slots (
    id              SERIAL PRIMARY KEY,
    offering_id     INT NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    day_of_week     VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    room            VARCHAR(50),
    session_type    VARCHAR(20) DEFAULT 'lecture' CHECK (session_type IN ('lecture','lab','tutorial','project')),
    UNIQUE (offering_id, day_of_week, start_time)
);
`;
fs.writeFileSync(file, content, 'utf8');
