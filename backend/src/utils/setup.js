// =============================================================================
// Unified DB Setup — migrate + seed in ONE process with ONE pool
//
// [C4-FIX] Root cause: migrate.js and seed.js each call pool.end() after running.
// Node.js caches modules. When entrypoint calls: node migrate.js && node seed.js
// as SEPARATE processes → separate pools → WORKS.
// But migrate.js itself does: require('../config/database') → runs schema → pool.end()
// then seed.js does require('../config/database') → gets the SAME cached pool
// which is already ended → "Cannot use a pool after calling end on the pool"
//
// FIX: Run both in one process. Create pool once. Use it for both. Close once.
// This also reduces startup time by ~2s (no second process spawn + connect).
// =============================================================================
require('dotenv').config();
const fs   = require('fs');
const path = require('path');
const { Pool } = require('pg');
const logger = require('./logger');

const DB_BASE = process.env.DB_MIGRATION_PATH || '/app/database';

// Create a FRESH pool — not the cached one from config/database.js
// This prevents any interference with the main application pool
const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     parseInt(process.env.DB_PORT) || 5432,
  user:     process.env.DB_USER     || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME     || 'student_registration_system',
  max: 2,
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 5000,
});

async function runFile(client, filePath, label) {
  if (!fs.existsSync(filePath)) {
    logger.warn(`${label}: file not found at ${filePath}, skipping`);
    return false;
  }
  const sql = fs.readFileSync(filePath, 'utf8');
  logger.info(`${label}: applying...`);
  await client.query(sql);
  logger.info(`${label}: done`);
  return true;
}

const POST_SEED_MIGRATIONS = [
  'migration_v3.sql',
  'migration_prerequisites.sql',
  'migration_v4.sql',
  'migration_v5.sql',   // [V5-FIX] adds section_label to course_offerings, drops old unique constraint
];

async function setup() {
  let client;
  let exitCode = 0;

  try {
    client = await pool.connect();
    logger.info('Setup: connected to database');

    // ── 1. Base schema (always idempotent via CREATE OR REPLACE / IF NOT EXISTS) ──
    logger.info('Running base migrations...');
    await runFile(client, path.join(DB_BASE, 'schema.sql'),       'Schema');
    await runFile(client, path.join(DB_BASE, 'enhancements.sql'), 'Enhancements');
    logger.info('Base migrations complete');

    // ── 2. Migration log table — created on first boot, skipped thereafter ─────
    await client.query(`
      CREATE TABLE IF NOT EXISTS migration_logs (
        filename   TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    // ── 3. Seeds — skip if admin already exists ────────────────────────────────
    const adminCheck = await client.query(
      "SELECT id FROM users WHERE role = 'admin' LIMIT 1"
    ).catch(() => ({ rows: [] }));

    if (adminCheck.rows.length > 0) {
      logger.info('Admin user already exists. Skipping seeds.');
    } else {
      logger.info('Running seeds...');
      const seedsDir = path.join(DB_BASE, 'seeds');
      if (fs.existsSync(seedsDir)) {
        const files = fs.readdirSync(seedsDir).filter(f => f.endsWith('.sql')).sort();
        for (const file of files) {
          await runFile(client, path.join(seedsDir, file), `Seed:${file}`);
        }
      } else {
        logger.warn('Seeds directory not found');
      }
      logger.info('All seeds complete');
    }

    // ── 4. Post-seed migrations — each file runs at most once ─────────────────
    logger.info('Running post-seed migrations...');
    for (const migFile of POST_SEED_MIGRATIONS) {
      const { rows } = await client.query(
        'SELECT 1 FROM migration_logs WHERE filename = $1',
        [migFile]
      );
      if (rows.length > 0) {
        logger.info(`Migration already applied, skipping: ${migFile}`);
        continue;
      }
      const applied = await runFile(
        client, path.join(DB_BASE, migFile), `Migration:${migFile}`
      );
      if (applied) {
        await client.query(
          'INSERT INTO migration_logs (filename) VALUES ($1) ON CONFLICT DO NOTHING',
          [migFile]
        );
      }
    }

    // ── 5. Named sub-migrations (fixes, backfills) — each runs at most once ───
    const namedMigrations = [
      'migrations/fix_graduation_credits.sql',
      'migrations/backfill_schedule_slots.sql',
      'migrations/update_admin_dashboard_view.sql',
      'migrations/update_min_credits.sql',
      'migrations/fix_summer_max_credits.sql',
      'migrations/fix_curriculum_plans.sql',
      'migrations/fix_semester_statuses.sql',
      'migrations/populate_curriculum_plans.sql',
      'seeds/004_real_professors.sql',
      'seeds/005_real_students.sql',
      'seeds/005b_fix_seeds.sql',
      'seeds/006_demo_student_enrollments.sql',
      'seeds/007_fix_demo_student.sql',
      'seeds/008_fix_total_grades_and_gpa.sql', // [V5-FIX] was missing from named list
      'migrations/sync_academic_status.sql',
      'migrations/fix_semester_status.sql',
      'migrations/fix_demo_fall_2025_enrollments.sql',
      'migrations/011_fix_timetable_grades_doctor.sql',
      'migrations/012_fix_misc_issues.sql',
      'migrations/013_fix_admin_data.sql',
      'migrations/013_fix_curriculum_seed.sql',   // re-populates curriculum_plans with correct ON CONFLICT
      'migrations/014_ensure_spring2026_offerings.sql', // guarantees Spring 2026 offerings exist and are active
      'migrations/014_fix_curriculum_constraint.sql',
      'migrations/015_fix_course_prerequisites.sql', // fix prereqs + add IT212 + correct course names
      'migrations/016_remove_duplicate_prerequisites.sql', // remove old wrong prereqs left as duplicates
      'migrations/017_unconditional_prereq_cleanup.sql',  // unconditional targeted cleanup (no guard)
      'migrations/018_fix_migration_prerequisites_wrong_data.sql', // root-cause fix: remove all wrong prereqs injected by migration_prerequisites.sql
      'migrations/019_db_patch.sql', // [PATCH-019] Full bylaw-accurate course catalog, 72 prerequisites, FIX-001 IT317→IT212 for Dr. Marian, corrected schedule seed
    ];
    for (const migFile of namedMigrations) {
      const key = path.basename(migFile);
      const { rows } = await client.query(
        'SELECT 1 FROM migration_logs WHERE filename = $1', [key]
      );
      if (rows.length > 0) {
        logger.info(`Named migration already applied, skipping: ${key}`);
        continue;
      }
      const applied = await runFile(
        client, path.join(DB_BASE, migFile), `NamedMigration:${key}`
      );
      if (applied) {
        await client.query(
          'INSERT INTO migration_logs (filename) VALUES ($1) ON CONFLICT DO NOTHING',
          [key]
        );
      }
    }

    logger.info('All migrations complete');

  } catch (err) {
    logger.error('Setup error', { error: err.message, stack: err.stack?.slice(0, 200) });
    exitCode = 1;
  } finally {
    if (client) client.release();
    await pool.end().catch(() => {});
    if (exitCode !== 0) process.exit(exitCode);
  }
}

setup();
