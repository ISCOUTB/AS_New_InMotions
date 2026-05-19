const { institutionalDomain } = require('../config/appConfig');
const { REMINDER_TYPES } = require('../catalogs/reminderCatalog');

function normalizeEmail(email) { return String(email || '').trim().toLowerCase(); }
function isValidEmail(email) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }

function validateInstitutionalEmail(email) {
  const normalized = normalizeEmail(email);
  if (!normalized) return 'El correo es obligatorio';
  if (!isValidEmail(normalized)) return 'Ingresa un correo válido';
  if (!normalized.endsWith(institutionalDomain)) return `Debes usar tu correo institucional ${institutionalDomain}`;
  return null;
}

function validatePassword(password) {
  const value = String(password || '');
  if (!value) return 'La contraseña es obligatoria';
  if (value.length < 8) return 'La contraseña debe tener al menos 8 caracteres';
  return null;
}

function validateName(fullName) {
  const value = String(fullName || '').trim();
  if (!value) return 'El nombre es obligatorio';
  if (value.length < 3) return 'El nombre debe tener al menos 3 caracteres';
  return null;
}

function validateMoodPayload(body) {
  const mood = String(body.mood || '').trim();
  const level = Number(body.level);
  const tags = Array.isArray(body.tags) ? body.tags.map(item => String(item).trim()).filter(Boolean) : [];
  const note = String(body.note || '').trim();
  if (!mood) return { error: 'Selecciona una emoción para continuar' };
  if (!Number.isInteger(level) || level < 1 || level > 5) return { error: 'El nivel emocional debe estar entre 1 y 5' };
  if (note.length > 500) return { error: 'La nota no debe superar los 500 caracteres' };
  return { mood, level, tags, note };
}

function validateReminderPayload(body, { partial = false } = {}) {
  const result = {};
  if (!partial || Object.prototype.hasOwnProperty.call(body, 'type')) {
    const type = String(body.type || '').trim();
    if (!type) return { error: 'Selecciona un motivo para el recordatorio' };
    if (!REMINDER_TYPES.includes(type)) return { error: 'El motivo del recordatorio no es válido' };
    result.type = type;
    result.title = String(body.title || type).trim() || type;
    result.subtitle = String(body.subtitle || '').trim();
  }
  if (!partial || Object.prototype.hasOwnProperty.call(body, 'hour')) {
    const hour = Number(body.hour);
    if (!Number.isInteger(hour) || hour < 0 || hour > 23) return { error: 'La hora debe estar entre 0 y 23' };
    result.hour = hour;
  }
  if (!partial || Object.prototype.hasOwnProperty.call(body, 'minute')) {
    const minute = Number(body.minute);
    if (!Number.isInteger(minute) || minute < 0 || minute > 59) return { error: 'Los minutos deben estar entre 0 y 59' };
    result.minute = minute;
  }
  if (!partial || Object.prototype.hasOwnProperty.call(body, 'days')) {
    if (!Array.isArray(body.days)) return { error: 'Selecciona al menos un día' };
    const days = body.days.map(Number).filter(day => Number.isInteger(day) && day >= 1 && day <= 7);
    if (days.length === 0) return { error: 'Selecciona al menos un día' };
    result.days = [...new Set(days)].sort((a, b) => a - b);
  }
  if (!partial || Object.prototype.hasOwnProperty.call(body, 'enabled')) {
    result.enabled = Boolean(body.enabled);
  }
  return result;
}

module.exports = { normalizeEmail, validateInstitutionalEmail, validatePassword, validateName, validateMoodPayload, validateReminderPayload };
