const { pool } = require('./backend/src/config/database');

async function rerun() {
  try {
    await pool.query("DELETE FROM migration_logs WHERE filename = '019_db_patch.sql'");
    console.log("Deleted 019_db_patch.sql from migration_logs");
  } catch(err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
rerun();
