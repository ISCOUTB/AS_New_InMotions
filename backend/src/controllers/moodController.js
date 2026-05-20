const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId } = require('../utils/security');
const { validateMoodPayload } = require('../utils/validators');
const { publicMood } = require('../utils/presenters');
const { isSameDay, getStartOfWeek } = require('../utils/dateUtils');
const { requireAuth } = require('../middleware/auth');
const { readMoodsByUser, insertMood, deleteMoodById } = require('../storage/localDatabase');

async function createMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateMoodPayload(body);
  if (validation.error) return fail(res, 400, validation.error);

  const now = new Date().toISOString();
  const record = { id: createId('mood'), userId: user.id, ...validation, createdAt: now, updatedAt: now };
  await insertMood(record);
  created(res, { record: publicMood(record) }, 'Registro emocional guardado');
}

async function getMoods(req, res, url) {
  const user = requireAuth(req, res);
  if (!user) return;
  let records = await readMoodsByUser(user.id);
  const startDate = url.searchParams.get('startDate');
  const endDate = url.searchParams.get('endDate');
  if (startDate) {
    const start = new Date(startDate);
    if (!Number.isNaN(start.getTime())) records = records.filter(r => new Date(r.createdAt) >= start);
  }
  if (endDate) {
    const end = new Date(endDate);
    if (!Number.isNaN(end.getTime())) records = records.filter(r => new Date(r.createdAt) <= end);
  }
  ok(res, { records: records.map(publicMood) }, 'Historial emocional cargado');
}

async function getTodayMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const records = await readMoodsByUser(user.id);
  const record = records.find(r => isSameDay(r.createdAt)) || null;
  ok(res, { record: record ? publicMood(record) : null }, record ? 'Estado emocional de hoy cargado' : 'No hay registro emocional de hoy');
}

async function weeklyStats(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const start = getStartOfWeek();
  const records = (await readMoodsByUser(user.id)).filter(r => new Date(r.createdAt) >= start);
  const average = records.length ? records.reduce((sum, r) => sum + Number(r.level || 0), 0) / records.length : 0;
  ok(res, { count: records.length, average: Number(average.toFixed(2)), records: records.map(publicMood) }, 'Resumen semanal cargado');
}

async function deleteMood(req, res, moodId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const deleted = await deleteMoodById(moodId, user.id);
  if (!deleted) return fail(res, 404, 'Registro emocional no encontrado');
  ok(res, null, 'Registro emocional eliminado');
}

module.exports = { createMood, getMoods, getTodayMood, weeklyStats, deleteMood };