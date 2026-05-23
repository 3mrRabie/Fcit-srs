const { Client } = require('pg');
const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'admin123',
  database: 'student_registration_system'
});

async function run() {
  await client.connect();
  console.log("Connected to DB");
  
  // Find IS111 course
  const courseRes = await client.query(`SELECT * FROM courses WHERE code = 'IS111'`);
  console.log("IS111 Course:", courseRes.rows[0]);
  
  if (courseRes.rows.length === 0) return;
  const courseId = courseRes.rows[0].id;
  
  // Check curriculum_plans
  const curRes = await client.query(`SELECT * FROM curriculum_plans WHERE course_id = $1`, [courseId]);
  console.log("Curriculum plans:", curRes.rows);
  
  // Check offerings
  const offRes = await client.query(`SELECT * FROM course_offerings WHERE course_id = $1`, [courseId]);
  console.log("Offerings:", offRes.rows);
  
  if (offRes.rows.length === 0) return;
  const offeringIds = offRes.rows.map(o => o.id);
  
  // Check doctor_schedule_slots
  const dssRes = await client.query(`SELECT * FROM doctor_schedule_slots WHERE offering_id = ANY($1::int[])`, [offeringIds]);
  console.log("Doctor Schedule Slots:", dssRes.rows);
  
  // Check enrollments for a specific student who might be missing it, or all
  const enrRes = await client.query(`SELECT * FROM enrollments WHERE offering_id = ANY($1::int[])`, [offeringIds]);
  console.log("Enrollments:", enrRes.rows.length);

  await client.end();
}

run().catch(console.error);
