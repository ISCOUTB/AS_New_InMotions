const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId } = require('../utils/security');
const { requireAuth } = require('../middleware/auth');
const { publicReminder } = require('../utils/presenters');
const { validateReminderPayload } = require('../utils/validators');
const { defaultSubtitleForReminderType, buildDefaultRemindersForUser } = require('../catalogs/reminderCatalog');
const { readReminders, writeReminders, readDevices, writeDevices } = require('../storage/localDatabase');

function ensureUserHasDefaultReminders(userId) {
  const reminders = readReminders();
  const hasAny = reminders.some(reminder => reminder.userId === userId);
  if (!hasAny) {
    const defaults = buildDefaultRemindersForUser(userId);
    writeReminders([...reminders, ...defaults]);
    return defaults;
  }
  return reminders.filter(reminder => reminder.userId === userId);
}

function getReminders(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  ensureUserHasDefaultReminders(user.id);
  const reminders = readReminders().filter(reminder => reminder.userId === user.id).sort((a, b) => a.hour - b.hour || a.minute - b.minute);
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
  const reminders = readReminders();
  reminders.push(reminder);
  writeReminders(reminders);
  created(res, { reminder: publicReminder(reminder) }, 'Recordatorio creado');
}

async function updateReminder(req, res, reminderId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateReminderPayload(body, { partial: true });
  if (validation.error) return fail(res, 400, validation.error);
  const reminders = readReminders();
  const index = reminders.findIndex(reminder => reminder.id === reminderId && reminder.userId === user.id);
  if (index < 0) return fail(res, 404, 'Recordatorio no encontrado');
  const current = reminders[index];
  const updated = {
    ...current,
    ...validation,
    title: validation.title || current.title,
    subtitle: validation.subtitle || (validation.type ? defaultSubtitleForReminderType(validation.type) : current.subtitle),
    updatedAt: new Date().toISOString(),
  };
  reminders[index] = updated;
  writeReminders(reminders);
  ok(res, { reminder: publicReminder(updated) }, 'Recordatorio actualizado');
}

function deleteReminder(req, res, reminderId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const reminders = readReminders();
  const index = reminders.findIndex(reminder => reminder.id === reminderId && reminder.userId === user.id);
  if (index < 0) return fail(res, 404, 'Recordatorio no encontrado');
  reminders.splice(index, 1);
  writeReminders(reminders);
  ok(res, null, 'Recordatorio eliminado');
}

function resetReminders(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const others = readReminders().filter(reminder => reminder.userId !== user.id);
  const defaults = buildDefaultRemindersForUser(user.id);
  writeReminders([...others, ...defaults]);
  ok(res, { reminders: defaults.map(publicReminder) }, 'Recordatorios restaurados');
}

async function registerDevice(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const token = String(body.token || '').trim();
  if (!token) return fail(res, 400, 'El token del dispositivo es obligatorio');
  const platform = String(body.platform || 'unknown').trim();
  const devices = readDevices();
  const now = new Date().toISOString();
  const index = devices.findIndex(device => device.userId === user.id && device.token === token);
  const device = { userId: user.id, token, platform, updatedAt: now, createdAt: index >= 0 ? devices[index].createdAt : now };
  if (index >= 0) devices[index] = device;
  else devices.push(device);
  writeDevices(devices);
  ok(res, { registered: true }, 'Dispositivo registrado localmente');
}

module.exports = { getReminders, createReminder, updateReminder, deleteReminder, resetReminders, registerDevice };
