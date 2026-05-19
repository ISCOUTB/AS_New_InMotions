const pool = require('../config/database');
const { hashPassword } = require('../utils/security');

const DEMO_USER = {
  id: 'demo-user-utb',
  full_name: 'Estudiante UTB',
  email: 'estudiante@utb.edu.co',
  phone: null,
  role: 'student',
  password_hash: null, // se genera abajo
};

async function ensureDataFiles() {
  try {
    // Insertar usuario demo si no existe
    const passwordHash = hashPassword('Test@12345');
    DEMO_USER.password_hash = passwordHash;

    await pool.execute(
      `INSERT IGNORE INTO usuarios (id, full_name, email, phone, role, password_hash)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [DEMO_USER.id, DEMO_USER.full_name, DEMO_USER.email, DEMO_USER.phone, DEMO_USER.role, DEMO_USER.password_hash]
    );
    console.log('✅ Base de datos MariaDB conectada correctamente');
  } catch (err) {
    console.error('❌ Error conectando a MariaDB:', err.message);
    throw err;
  }
}

// ─── USUARIOS ───────────────────────────────────────────
const readUsers = async () => {
  const [rows] = await pool.execute('SELECT * FROM usuarios');
  return rows.map(dbUserToApp);
};

const writeUsers = async (users) => {
  for (const user of users) {
    await pool.execute(
      `INSERT INTO usuarios (id, full_name, email, phone, role, password_hash, created_at, last_login_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         full_name=VALUES(full_name), phone=VALUES(phone), role=VALUES(role),
         password_hash=VALUES(password_hash), last_login_at=VALUES(last_login_at)`,
      [user.id, user.fullName, user.email, user.phone || null, user.role, user.passwordHash, user.createdAt, user.lastLoginAt || null]
    );
  }
};

// ─── MOODS ──────────────────────────────────────────────
const readMoods = async () => {
  const [rows] = await pool.execute('SELECT * FROM moods');
  return rows.map(r => ({ id: r.id, userId: r.user_id, mood: r.mood, note: r.note, createdAt: r.created_at }));
};

const writeMoods = async (moods) => {
  for (const m of moods) {
    await pool.execute(
      `INSERT INTO moods (id, user_id, mood, note, created_at)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE mood=VALUES(mood), note=VALUES(note)`,
      [m.id, m.userId, m.mood, m.note || null, m.createdAt]
    );
  }
};

// ─── TRIAGE RESULTS ─────────────────────────────────────
const readTriageResults = async () => {
  const [rows] = await pool.execute('SELECT * FROM triage_results');
  return rows.map(r => ({ id: r.id, userId: r.user_id, score: r.score, level: r.level, answers: JSON.parse(r.answers || '[]'), createdAt: r.created_at }));
};

const writeTriageResults = async (results) => {
  for (const r of results) {
    await pool.execute(
      `INSERT INTO triage_results (id, user_id, score, level, answers, created_at)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE score=VALUES(score), level=VALUES(level), answers=VALUES(answers)`,
      [r.id, r.userId, r.score, r.level, JSON.stringify(r.answers || []), r.createdAt]
    );
  }
};

// ─── REFERRALS ──────────────────────────────────────────
const readReferrals = async () => {
  const [rows] = await pool.execute('SELECT * FROM referrals');
  return rows.map(r => ({ id: r.id, userId: r.user_id, reason: r.reason, status: r.status, createdAt: r.created_at }));
};

const writeReferrals = async (referrals) => {
  for (const r of referrals) {
    await pool.execute(
      `INSERT INTO referrals (id, user_id, reason, status, created_at)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE reason=VALUES(reason), status=VALUES(status)`,
      [r.id, r.userId, r.reason || null, r.status || 'pending', r.createdAt]
    );
  }
};

// ─── RESOURCE FAVORITES ─────────────────────────────────
const readResourceFavorites = async () => {
  const [rows] = await pool.execute('SELECT * FROM resource_favorites');
  return rows.map(r => ({ id: r.id, userId: r.user_id, articleId: r.article_id, createdAt: r.created_at }));
};

const writeResourceFavorites = async (favorites) => {
  for (const f of favorites) {
    await pool.execute(
      `INSERT IGNORE INTO resource_favorites (id, user_id, article_id, created_at)
       VALUES (?, ?, ?, ?)`,
      [f.id, f.userId, f.articleId, f.createdAt]
    );
  }
};

// ─── REMINDERS ──────────────────────────────────────────
const readReminders = async () => {
  const [rows] = await pool.execute('SELECT * FROM reminders');
  return rows.map(r => ({ id: r.id, userId: r.user_id, title: r.title, time: r.time, active: !!r.active, createdAt: r.created_at }));
};

const writeReminders = async (reminders) => {
  for (const r of reminders) {
    await pool.execute(
      `INSERT INTO reminders (id, user_id, title, time, active, created_at)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE title=VALUES(title), time=VALUES(time), active=VALUES(active)`,
      [r.id, r.userId, r.title, r.time || null, r.active ? 1 : 0, r.createdAt]
    );
  }
};

// ─── DEVICES ────────────────────────────────────────────
const readDevices = async () => {
  const [rows] = await pool.execute('SELECT * FROM devices');
  return rows.map(r => ({ id: r.id, userId: r.user_id, token: r.token, platform: r.platform, createdAt: r.created_at }));
};

const writeDevices = async (devices) => {
  for (const d of devices) {
    await pool.execute(
      `INSERT INTO devices (id, user_id, token, platform, created_at)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE token=VALUES(token), platform=VALUES(platform)`,
      [d.id, d.userId, d.token, d.platform || null, d.createdAt]
    );
  }
};

// ─── HELPERS ────────────────────────────────────────────
function dbUserToApp(row) {
  return {
    id: row.id,
    fullName: row.full_name,
    email: row.email,
    phone: row.phone,
    role: row.role,
    passwordHash: row.password_hash,
    createdAt: row.created_at,
    lastLoginAt: row.last_login_at,
  };
}

module.exports = {
  ensureDataFiles,
  readUsers, writeUsers,
  readMoods, writeMoods,
  readTriageResults, writeTriageResults,
  readReferrals, writeReferrals,
  readResourceFavorites, writeResourceFavorites,
  readReminders, writeReminders,
  readDevices, writeDevices,
};