function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(payload));
}

function ok(res, data, message = 'Operación exitosa') { sendJson(res, 200, { success: true, message, data }); }
function created(res, data, message = 'Registro creado correctamente') { sendJson(res, 201, { success: true, message, data }); }
function fail(res, statusCode, message, details = null) { sendJson(res, statusCode, { success: false, message, details }); }

function readRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      if (body.length > 1_000_000) reject(new Error('La solicitud es demasiado grande'));
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try { resolve(JSON.parse(body)); }
      catch (_) { reject(new Error('JSON inválido')); }
    });
    req.on('error', reject);
  });
}

module.exports = { sendJson, ok, created, fail, readRequestBody };
