const { verifyToken } = require('../utils/security');
const { readUsers } = require('../storage/localDatabase');
const { fail } = require('../utils/http');

function getAuthUser(req) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  const payload = verifyToken(token);
  if (!payload) return null;
  return readUsers().find(user => user.id === payload.userId) || null;
}

function requireAuth(req, res) {
  const user = getAuthUser(req);
  if (!user) {
    fail(res, 401, 'Sesión no válida o expirada');
    return null;
  }
  return user;
}

module.exports = { getAuthUser, requireAuth };
