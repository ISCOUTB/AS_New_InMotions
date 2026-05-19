const path = require('path');

const rootDir = path.join(__dirname, '..', '..');
const dataDir = process.env.DATA_DIR || path.join(rootDir, 'data');

module.exports = {
  port: Number(process.env.PORT || 3000),
  host: process.env.HOST || '0.0.0.0',
  apiPrefix: process.env.API_PREFIX || '/api',
  institutionalDomain: process.env.INSTITUTIONAL_DOMAIN || '@utb.edu.co',
  psychologyEmail: process.env.PSYCHOLOGY_EMAIL || 'bienestar@utb.edu.co',
  tokenSecret: process.env.TOKEN_SECRET || 'as-new-inmotions-local-secret-change-later',
  dataDir,
  dataFiles: {
    users: path.join(dataDir, 'local-users.json'),
    moods: path.join(dataDir, 'local-moods.json'),
    triageResults: path.join(dataDir, 'local-triage-results.json'),
    referrals: path.join(dataDir, 'local-referrals.json'),
    resourceFavorites: path.join(dataDir, 'local-resource-favorites.json'),
    reminders: path.join(dataDir, 'local-reminders.json'),
    devices: path.join(dataDir, 'local-devices.json'),
  },
  triageThresholds: {
    greenMax: 45,
    yellowMax: 70,
    orangeMax: 95,
    redMax: 115,
    criticalActivationScore: 4,
  },
  criticalQuestionIds: ['A5', 'F1', 'F2'],
};
