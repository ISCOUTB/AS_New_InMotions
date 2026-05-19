const { URL } = require('url');
const { apiPrefix } = require('../config/appConfig');
const { sendJson, fail } = require('../utils/http');
const health = require('../controllers/healthController');
const auth = require('../controllers/authController');
const moods = require('../controllers/moodController');
const triage = require('../controllers/triageController');
const resources = require('../controllers/resourceController');
const reminders = require('../controllers/reminderController');

function extractId(pathname, prefix, suffix = '') {
  let value = pathname.slice(prefix.length);
  if (suffix && value.endsWith(suffix)) value = value.slice(0, -suffix.length);
  return decodeURIComponent(value.replace(/^\//, '').replace(/\/$/, ''));
}

async function router(req, res) {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const { pathname } = url;

  if (req.method === 'OPTIONS') return sendJson(res, 200, { success: true, message: 'OK' });

  try {
    if (req.method === 'GET' && pathname === `${apiPrefix}/health`) return health.health(req, res);

    if (req.method === 'POST' && pathname === `${apiPrefix}/auth/register`) return auth.register(req, res);
    if (req.method === 'POST' && pathname === `${apiPrefix}/auth/login`) return auth.login(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/auth/me`) return auth.me(req, res);
    if (req.method === 'POST' && pathname === `${apiPrefix}/auth/logout`) return auth.logout(req, res);

    if (req.method === 'POST' && pathname === `${apiPrefix}/moods`) return moods.createMood(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/moods`) return moods.getMoods(req, res, url);
    if (req.method === 'GET' && pathname === `${apiPrefix}/moods/today`) return moods.getTodayMood(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/moods/stats/weekly`) return moods.weeklyStats(req, res);
    if (req.method === 'DELETE' && pathname.startsWith(`${apiPrefix}/moods/`)) return moods.deleteMood(req, res, extractId(pathname, `${apiPrefix}/moods/`));

    if (req.method === 'GET' && pathname === `${apiPrefix}/triage/questions`) return triage.getQuestions(req, res);
    if (req.method === 'POST' && pathname === `${apiPrefix}/triage/submit`) return triage.submitTriage(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/triage/results`) return triage.getResults(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/referrals`) return triage.getReferrals(req, res);

    if (req.method === 'GET' && pathname === `${apiPrefix}/articles`) return resources.getArticles(req, res, url);
    if (req.method === 'GET' && pathname === `${apiPrefix}/articles/categories`) return resources.getCategories(req, res);
    if (req.method === 'GET' && pathname === `${apiPrefix}/articles/favorites`) return resources.getFavorites(req, res);
    if (req.method === 'GET' && pathname.startsWith(`${apiPrefix}/articles/`)) {
      const resourceId = extractId(pathname, `${apiPrefix}/articles/`);
      if (resourceId.includes('/')) return fail(res, 404, 'Ruta no encontrada');
      return resources.getDetail(req, res, resourceId);
    }
    if (req.method === 'POST' && pathname.startsWith(`${apiPrefix}/articles/`) && pathname.endsWith('/favorite')) return resources.addFavorite(req, res, extractId(pathname, `${apiPrefix}/articles/`, '/favorite'));
    if (req.method === 'DELETE' && pathname.startsWith(`${apiPrefix}/articles/`) && pathname.endsWith('/favorite')) return resources.removeFavorite(req, res, extractId(pathname, `${apiPrefix}/articles/`, '/favorite'));

    if (req.method === 'GET' && pathname === `${apiPrefix}/reminders`) return reminders.getReminders(req, res);
    if (req.method === 'POST' && pathname === `${apiPrefix}/reminders`) return reminders.createReminder(req, res);
    if (req.method === 'POST' && pathname === `${apiPrefix}/reminders/reset`) return reminders.resetReminders(req, res);
    if (req.method === 'PUT' && pathname.startsWith(`${apiPrefix}/reminders/`)) return reminders.updateReminder(req, res, extractId(pathname, `${apiPrefix}/reminders/`));
    if (req.method === 'DELETE' && pathname.startsWith(`${apiPrefix}/reminders/`)) return reminders.deleteReminder(req, res, extractId(pathname, `${apiPrefix}/reminders/`));
    if (req.method === 'POST' && pathname === `${apiPrefix}/devices/register`) return reminders.registerDevice(req, res);

    return fail(res, 404, 'Ruta no encontrada');
  } catch (error) {
    console.error(error);
    return fail(res, 500, error.message || 'Error interno del servidor');
  }
}

module.exports = { router };
