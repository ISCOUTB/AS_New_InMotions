function defaultSubtitleForReminderType(type) {
  switch (type) {
    case 'Registrar emoción': return 'Registrar cómo te sentiste hoy';
    case 'Pausa de respiración': return 'Tomar una pausa breve de 3 minutos';
    case 'Revisar recursos': return 'Explorar una guía de bienestar';
    case 'Triaje mensual': return 'Revisar tu bienestar emocional';
    case 'Descanso activo': return 'Levantarte, estirar y despejarte';
    case 'Higiene del sueño': return 'Prepararte para descansar mejor';
    case 'Contactar apoyo': return 'Recordar canales de apoyo institucional';
    default: return 'Cuidar tu bienestar emocional';
  }
}

const REMINDER_TYPES = [
  'Registrar emoción',
  'Pausa de respiración',
  'Revisar recursos',
  'Triaje mensual',
  'Descanso activo',
  'Higiene del sueño',
  'Contactar apoyo',
];function buildDefaultRemindersForUser(userId) {
  const now = new Date().toISOString();
  return [
    { id: `reminder-mood-daily-${userId}`, userId, type: 'Registrar emoción', title: 'Registrar emoción', subtitle: defaultSubtitleForReminderType('Registrar emoción'), hour: 20, minute: 0, days: [1, 2, 3, 4, 5, 6, 7], enabled: true, createdAt: now, updatedAt: now },
    { id: `reminder-breathing-mwf-${userId}`, userId, type: 'Pausa de respiración', title: 'Pausa de respiración', subtitle: defaultSubtitleForReminderType('Pausa de respiración'), hour: 7, minute: 30, days: [1, 3, 5], enabled: true, createdAt: now, updatedAt: now },
    { id: `reminder-sleep-weekdays-${userId}`, userId, type: 'Higiene del sueño', title: 'Higiene del sueño', subtitle: defaultSubtitleForReminderType('Higiene del sueño'), hour: 22, minute: 0, days: [1, 2, 3, 4, 5], enabled: false, createdAt: now, updatedAt: now },
  ];
}

module.exports = { REMINDER_TYPES, defaultSubtitleForReminderType, buildDefaultRemindersForUser };
