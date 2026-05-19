const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId } = require('../utils/security');
const { validateMoodPayload } = require('../utils/validators');
const { publicMood } = require('../utils/presenters');
const { isSameDay, getStartOfWeek } = require('../utils/dateUtils');
const { requireAuth } = require('../middleware/auth');
const { readMoods, writeMoods } = require('../storage/localDatabase');

async function createMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateMoodPayload(body);
  if (validation.error) return fail(res, 400, validation.error);

  const now = new Date().toISOString();
  const record = { id: createId('mood'), userId: user.id, ...validation, createdAt: now, updatedAt: now };
  const records = readMoods();
  records.push(record);
  writeMoods(records);
  created(res, { record: publicMood(record) }, 'Registro emocional guardado');
}

function getMoods(req, res, url) {
  const user = requireAuth(req, res);
  if (!user) return;
  let records = readMoods().filter(record => record.userId === user.id);
  const startDate = url.searchParams.get('startDate');
  const endDate = url.searchParams.get('endDate');
  if (startDate) {
    const start = new Date(startDate);
    if (!Number.isNaN(start.getTime())) records = records.filter(record => new Date(record.createdAt) >= start);
  }
  if (endDate) {
    const end = new Date(endDate);
    if (!Number.isNaN(end.getTime())) records = records.filter(record => new Date(record.createdAt) <= end);
  }
  records.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  ok(res, { records: records.map(publicMood) }, 'Historial emocional cargado');
}

function getTodayMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const record = readMoods().filter(item => item.userId === user.id && isSameDay(item.createdAt)).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0] || null;
  ok(res, { record: record ? publicMood(record) : null }, record ? 'Estado emocional de hoy cargado' : 'No hay registro emocional de hoy');
}

function weeklyStats(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const start = getStartOfWeek();
  const records = readMoods().filter(record => record.userId === user.id && new Date(record.createdAt) >= start);
  const average = records.length ? records.reduce((sum, record) => sum + Number(record.level || 0), 0) / records.length : 0;
  ok(res, { count: records.length, average: Number(average.toFixed(2)), records: records.map(publicMood) }, 'Resumen semanal cargado');
}

function deleteMood(req, res, moodId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const records = readMoods();
  const index = records.findIndex(record => record.id === moodId && record.userId === user.id);
  if (index < 0) return fail(res, 404, 'Registro emocional no encontrado');
  records.splice(index, 1);
  writeMoods(records);
  ok(res, null, 'Registro emocional eliminado');
}

module.exports = { createMood, getMoods, getTodayMood, weeklyStats, deleteMood };
