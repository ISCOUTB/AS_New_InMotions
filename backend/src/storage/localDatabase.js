const { dataDir, dataFiles } = require('../config/appConfig');
const { ensureDir, readJsonFile, writeJsonFile } = require('./jsonStore');
const { hashPassword } = require('../utils/security');
const { sanitizeStoredUser } = require('../utils/presenters');

const demoUserSeed = {
  id: 'demo-user-utb',
  fullName: 'Estudiante UTB',
  email: 'estudiante@utb.edu.co',
  phone: null,
  role: 'student',
  createdAt: new Date().toISOString(),
  lastLoginAt: null,
  password: 'Test@12345',
};

function ensureDataFiles() {
  ensureDir(dataDir);
  if (!require('fs').existsSync(dataFiles.users)) {
    const user = sanitizeStoredUser({ ...demoUserSeed, passwordHash: hashPassword(demoUserSeed.password) });
    writeJsonFile(dataFiles.users, [user]);
  }
  for (const key of ['moods', 'triageResults', 'referrals', 'resourceFavorites', 'reminders', 'devices']) {
    if (!require('fs').existsSync(dataFiles[key])) writeJsonFile(dataFiles[key], []);
  }
}

const readUsers = () => readJsonFile(dataFiles.users, []);
const writeUsers = users => writeJsonFile(dataFiles.users, users);
const readMoods = () => readJsonFile(dataFiles.moods, []);
const writeMoods = moods => writeJsonFile(dataFiles.moods, moods);
const readTriageResults = () => readJsonFile(dataFiles.triageResults, []);
const writeTriageResults = results => writeJsonFile(dataFiles.triageResults, results);
const readReferrals = () => readJsonFile(dataFiles.referrals, []);
const writeReferrals = referrals => writeJsonFile(dataFiles.referrals, referrals);
const readResourceFavorites = () => readJsonFile(dataFiles.resourceFavorites, []);
const writeResourceFavorites = favorites => writeJsonFile(dataFiles.resourceFavorites, favorites);
const readReminders = () => readJsonFile(dataFiles.reminders, []);
const writeReminders = reminders => writeJsonFile(dataFiles.reminders, reminders);
const readDevices = () => readJsonFile(dataFiles.devices, []);
const writeDevices = devices => writeJsonFile(dataFiles.devices, devices);

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
