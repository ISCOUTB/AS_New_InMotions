const { ok } = require('../utils/http');

function health(req, res) {
  ok(res, {
    status: 'running',
    project: 'AS_New_InMotions',
    mode: 'local-json-modular',
    modules: ['auth', 'moods', 'triage', 'resources', 'reminders'],
    storage: 'JSON local preparado para migrar a MongoDB/Cosmos DB',
    timestamp: new Date().toISOString(),
  }, 'Backend local activo');
}

module.exports = { health };
