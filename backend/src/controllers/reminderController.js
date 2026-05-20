const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId } = require('../utils/security');
const { requireAuth } = require('../middleware/auth');
const { publicReminder } = require('../utils/presenters');
const { validateReminderPayload } = require('../utils/validators');
const { defaultSubtitleForReminderType, buildDefaultRemindersForUser } = require('../catalogs/reminderCatalog');
const {
  readReminders, insertReminder, updateReminderById,
  deleteReminderById, deleteRemindersByUser,
  readDevices, upsertDevice,
} = require('../storage/localDatabase');

async function ensureUserHasDefaultReminders(userId) {
  const all = await readReminders();
  const hasAny = all.some(r => r.userId === userId);
  if (!hasAny) {
    const defaults = buildDefaultRemindersForUser(userId);
    for (const reminder of defaults) await insertReminder(reminder);
    return defaults;
  }
  return all.filter(r => r.userId === userId);
}

async function getReminders(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const reminders = await ensureUserHasDefaultReminders(user.id);
  ok(res, { reminders: reminders.map(publicReminder) }, 'Recordatorios cargados');
}

async function createReminder(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateReminderPayload(body);
  if (validation.error) return fail(res, 400, validation.error);
  const now = new Date().toISOString();
  const reminder = {
    id: createId('reminder'),
    userId: user.id,
    type: validation.type,
    title: validation.title || validation.type,
    subtitle: validation.subtitle || defaultSubtitleForReminderType(validation.type),
    hour: validation.hour,
    minute: validation.minute,
    days: validation.days,
    enabled: validation.enabled,
    createdAt: now,
    updatedAt: now,
  };
  await insertReminder(reminder);
  created(res, { reminder: publicReminder(reminder) }, 'Recordatorio creado');
}

async function updateReminder(req, res, reminderId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateReminderPayload(body, { partial: true });
  if (validation.error) return fail(res, 400, validation.error);
  const all = await readReminders();
  const current = all.find(r => r.id === reminderId && r.userId === user.id);
  if (!current) return fail(res, 404, 'Recordatorio no encontrado');
  const updated = {
    ...current,
    ...validation,
    title: validation.title || current.title,
    subtitle: validation.subtitle || (validation.type ? defaultSubtitleForReminderType(validation.type) : current.subtitle),
    updatedAt: new Date().toISOString(),
  };
  await updateReminderById(reminderId, user.id, updated);
  ok(res, { reminder: publicReminder(updated) }, 'Recordatorio actualizado');
}

async function deleteReminder(req, res, reminderId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const deleted = await deleteReminderById(reminderId, user.id);
  if (!deleted) return fail(res, 404, 'Recordatorio no encontrado');
  ok(res, null, 'Recordatorio eliminado');
}

async function resetReminders(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  await deleteRemindersByUser(user.id);
  const defaults = buildDefaultRemindersForUser(user.id);
  for (const reminder of defaults) await insertReminder(reminder);
  ok(res, { reminders: defaults.map(publicReminder) }, 'Recordatorios restaurados');
}

async function registerDevice(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const token = String(body.token || '').trim();
  if (!token) return fail(res, 400, 'El token del dispositivo es obligatorio');
  const platform = String(body.platform || 'unknown').trim();
  const now = new Date().toISOString();
  await upsertDevice({ userId: user.id, token, platform, createdAt: now, updatedAt: now });
  ok(res, { registered: true }, 'Dispositivo registrado');
}

module.exports = { getReminders, createReminder, updateReminder, deleteReminder, resetReminders, registerDevice };