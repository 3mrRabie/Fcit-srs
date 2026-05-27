const { query } = require('./backend/src/config/database.js');

async function test() {
  try {
    const res = await query('SELECT * FROM seed_logs ORDER BY created_at DESC LIMIT 5');
    console.log('Seed logs:', res.rows);
    
    const countRes = await query('SELECT COUNT(*) FROM curriculum_plans');
    console.log('Total curriculum_plans:', countRes.rows[0].count);
    
    const genRes = await query(`
      SELECT cp.year_of_study, cp.semester_in_year, c.code
      FROM curriculum_plans cp
      JOIN courses c ON cp.course_id = c.id
      WHERE cp.specialization = 'GENERAL'
      ORDER BY cp.year_of_study, cp.semester_in_year
    `);
    console.log('GENERAL curriculum:', genRes.rows);
    
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}

test();
