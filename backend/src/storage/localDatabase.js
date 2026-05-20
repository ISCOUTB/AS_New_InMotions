const pool = require('../config/database');
const { hashPassword } = require('../utils/security');

// ─── INIT ────────────────────────────────────────────────────────────────────

async function ensureDataFiles() {
  try {
    const passwordHash = hashPassword('Test@12345');
    await pool.execute(
      `INSERT IGNORE INTO usuarios (id, full_name, email, phone, role, password_hash, created_at, last_login_at)
       VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      ['demo-user-utb', 'Estudiante UTB', 'estudiante@utb.edu.co', null, 'student', passwordHash]
    );
    console.log('✅ Base de datos CleverCloud conectada correctamente');
  } catch (err) {
    console.error('❌ Error conectando a la base de datos:', err.message);
    throw err;
  }
}

// ─── USUARIOS ────────────────────────────────────────────────────────────────

async function readUsers() {
  const [rows] = await pool.execute('SELECT * FROM usuarios');
  return rows.map(dbUserToApp);
}

async function writeUsers(users) {
  // No se usa directamente — se usan funciones específicas
}

async function findUserByEmail(email) {
  const [rows] = await pool.execute('SELECT * FROM usuarios WHERE email = ?', [email]);
  return rows.length ? dbUserToApp(rows[0]) : null;
}

async function findUserById(id) {
  const [rows] = await pool.execute('SELECT * FROM usuarios WHERE id = ?', [id]);
  return rows.length ? dbUserToApp(rows[0]) : null;
}

async function insertUser(user) {
  await pool.execute(
    `INSERT INTO usuarios (id, full_name, email, phone, role, password_hash, created_at, last_login_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [user.id, user.fullName, user.email, user.phone || null, user.role, user.passwordHash, user.createdAt, user.lastLoginAt]
  );
  return user;
}

async function updateUserLogin(id) {
  await pool.execute('UPDATE usuarios SET last_login_at = NOW() WHERE id = ?', [id]);
}

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

// ─── MOODS ───────────────────────────────────────────────────────────────────

async function readMoods() {
  const [rows] = await pool.execute('SELECT * FROM moods ORDER BY created_at DESC');
  return rows.map(dbMoodToApp);
}

async function writeMoods(moods) {
  // No se usa directamente
}

async function insertMood(mood) {
  await pool.execute(
    `INSERT INTO moods (id, user_id, level, note, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [mood.id, mood.userId, mood.level, mood.note || null, mood.createdAt, mood.updatedAt]
  );
}

async function deleteMoodById(id, userId) {
  const [result] = await pool.execute('DELETE FROM moods WHERE id = ? AND user_id = ?', [id, userId]);
  return result.affectedRows > 0;
}

async function readMoodsByUser(userId) {
  const [rows] = await pool.execute('SELECT * FROM moods WHERE user_id = ? ORDER BY created_at DESC', [userId]);
  return rows.map(dbMoodToApp);
}

function dbMoodToApp(row) {
  return {
    id: row.id,
    userId: row.user_id,
    level: row.level,
    note: row.note,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// ─── TRIAGE ──────────────────────────────────────────────────────────────────

async function readTriageResults() {
  const [rows] = await pool.execute('SELECT * FROM triage_results ORDER BY created_at DESC');
  return rows.map(dbTriageToApp);
}

async function writeTriageResults(results) {
  // No se usa directamente
}

async function insertTriageResult(result) {
  await pool.execute(
    `INSERT INTO triage_results (id, user_id, score, risk_level, requires_referral, answers, recommendations, referral_status, is_critical_protocol, critical_question_ids, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      result.id, result.userId, result.score, result.riskLevel,
      result.requiresReferral ? 1 : 0,
      JSON.stringify(result.answers),
      JSON.stringify(result.recommendations),
      result.referralStatus || null,
      result.isCriticalProtocol ? 1 : 0,
      JSON.stringify(result.criticalQuestionIds),
      result.createdAt,
    ]
  );
}

async function updateTriageReferralStatus(id, status) {
  await pool.execute('UPDATE triage_results SET referral_status = ? WHERE id = ?', [status, id]);
}

function dbTriageToApp(row) {
  return {
    id: row.id,
    userId: row.user_id,
    score: row.score,
    riskLevel: row.risk_level,
    requiresReferral: !!row.requires_referral,
    answers: typeof row.answers === 'string' ? JSON.parse(row.answers) : row.answers,
    recommendations: typeof row.recommendations === 'string' ? JSON.parse(row.recommendations) : row.recommendations,
    referralStatus: row.referral_status,
    isCriticalProtocol: !!row.is_critical_protocol,
    criticalQuestionIds: typeof row.critical_question_ids === 'string' ? JSON.parse(row.critical_question_ids) : row.critical_question_ids,
    createdAt: row.created_at,
  };
}

// ─── REFERRALS ───────────────────────────────────────────────────────────────

async function readReferrals() {
  const [rows] = await pool.execute('SELECT * FROM referrals ORDER BY created_at DESC');
  return rows.map(dbReferralToApp);
}

async function writeReferrals(referrals) {
  // No se usa directamente
}

async function insertReferral(referral) {
  await pool.execute(
    `INSERT INTO referrals (id, user_id, triage_result_id, score, risk_level, status, method, psychology_email, message, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      referral.id, referral.userId, referral.triageResultId, referral.score,
      referral.riskLevel, referral.status, referral.method,
      referral.psychologyEmail, referral.message,
      referral.createdAt, referral.updatedAt,
    ]
  );
}

function dbReferralToApp(row) {
  return {
    id: row.id,
    userId: row.user_id,
    triageResultId: row.triage_result_id,
    score: row.score,
    riskLevel: row.risk_level,
    status: row.status,
    method: row.method,
    psychologyEmail: row.psychology_email,
    message: row.message,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// ─── REMINDERS ───────────────────────────────────────────────────────────────

async function readReminders() {
  const [rows] = await pool.execute('SELECT * FROM reminders ORDER BY hour ASC, minute ASC');
  return rows.map(dbReminderToApp);
}

async function writeReminders(reminders) {
  // No se usa directamente
}

async function insertReminder(reminder) {
  await pool.execute(
    `INSERT INTO reminders (id, user_id, type, title, subtitle, hour, minute, days, enabled, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      reminder.id, reminder.userId, reminder.type, reminder.title,
      reminder.subtitle, reminder.hour, reminder.minute,
      JSON.stringify(reminder.days), reminder.enabled ? 1 : 0,
      reminder.createdAt, reminder.updatedAt,
    ]
  );
}

async function updateReminderById(id, userId, fields) {
  await pool.execute(
    `UPDATE reminders SET type=?, title=?, subtitle=?, hour=?, minute=?, days=?, enabled=?, updated_at=? WHERE id=? AND user_id=?`,
    [
      fields.type, fields.title, fields.subtitle, fields.hour, fields.minute,
      JSON.stringify(fields.days), fields.enabled ? 1 : 0, fields.updatedAt, id, userId,
    ]
  );
}

async function deleteReminderById(id, userId) {
  const [result] = await pool.execute('DELETE FROM reminders WHERE id = ? AND user_id = ?', [id, userId]);
  return result.affectedRows > 0;
}

async function deleteRemindersByUser(userId) {
  await pool.execute('DELETE FROM reminders WHERE user_id = ?', [userId]);
}

function dbReminderToApp(row) {
  return {
    id: row.id,
    userId: row.user_id,
    type: row.type,
    title: row.title,
    subtitle: row.subtitle,
    hour: row.hour,
    minute: row.minute,
    days: typeof row.days === 'string' ? JSON.parse(row.days) : row.days,
    enabled: !!row.enabled,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// ─── DEVICES ─────────────────────────────────────────────────────────────────

async function readDevices() {
  const [rows] = await pool.execute('SELECT * FROM devices');
  return rows.map(dbDeviceToApp);
}

async function writeDevices(devices) {
  // No se usa directamente
}

async function upsertDevice(device) {
  await pool.execute(
    `INSERT INTO devices (user_id, token, platform, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE platform=VALUES(platform), updated_at=VALUES(updated_at)`,
    [device.userId, device.token, device.platform, device.createdAt, device.updatedAt]
  );
}

function dbDeviceToApp(row) {
  return {
    userId: row.user_id,
    token: row.token,
    platform: row.platform,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// ─── RESOURCE FAVORITES ──────────────────────────────────────────────────────

async function readResourceFavorites() {
  const [rows] = await pool.execute('SELECT * FROM resource_favorites');
  return rows.map(row => ({ userId: row.user_id, resourceId: row.resource_id, createdAt: row.created_at }));
}

async function writeResourceFavorites(favorites) {
  // No se usa directamente
}

async function insertResourceFavorite(userId, resourceId) {
  await pool.execute(
    `INSERT IGNORE INTO resource_favorites (user_id, resource_id, created_at) VALUES (?, ?, NOW())`,
    [userId, resourceId]
  );
}

async function deleteResourceFavorite(userId, resourceId) {
  await pool.execute('DELETE FROM resource_favorites WHERE user_id = ? AND resource_id = ?', [userId, resourceId]);
}

module.exports = {
  ensureDataFiles,
  // usuarios
  readUsers, writeUsers, findUserByEmail, findUserById, insertUser, updateUserLogin,
  // moods
  readMoods, writeMoods, insertMood, deleteMoodById, readMoodsByUser,
  // triage
  readTriageResults, writeTriageResults, insertTriageResult, updateTriageReferralStatus,
  // referrals
  readReferrals, writeReferrals, insertReferral,
  // reminders
  readReminders, writeReminders, insertReminder, updateReminderById, deleteReminderById, deleteRemindersByUser,
  // devices
  readDevices, writeDevices, upsertDevice,
  // resource favorites
  readResourceFavorites, writeResourceFavorites, insertResourceFavorite, deleteResourceFavorite,
};