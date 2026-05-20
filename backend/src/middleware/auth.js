const { verifyToken } = require('../utils/security');
const { readUsers } = require('../storage/localDatabase');
const { fail } = require('../utils/http');

async function getAuthUser(req) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  const payload = verifyToken(token);
  if (!payload) return null;
  const users = await readUsers();
  return users.find(user => user.id === payload.userId) || null;
}

async function requireAuth(req, res) {
  const user = await getAuthUser(req);
  if (!user) {
    fail(res, 401, 'Sesión no válida o expirada');
    return null;
  }
  return user;
}

module.exports = { getAuthUser, requireAuth };