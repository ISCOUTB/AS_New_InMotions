const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId, hashPassword, verifyPassword, createToken } = require('../utils/security');
const { normalizeEmail, validateInstitutionalEmail, validatePassword, validateName } = require('../utils/validators');
const { publicUser, sanitizeStoredUser } = require('../utils/presenters');
const { findUserByEmail, findUserById, insertUser, updateUserLogin } = require('../storage/localDatabase');
const { requireAuth } = require('../middleware/auth');

async function register(req, res) {
  const body = await readRequestBody(req);
  const fullName = String(body.fullName || body.name || '').trim();
  const email = normalizeEmail(body.email);
  const password = String(body.password || '');
  const phone = body.phone ? String(body.phone).trim() : null;

  const nameError = validateName(fullName);
  if (nameError) return fail(res, 400, nameError);
  const emailError = validateInstitutionalEmail(email);
  if (emailError) return fail(res, 400, emailError);
  const passwordError = validatePassword(password);
  if (passwordError) return fail(res, 400, passwordError);

  const existing = await findUserByEmail(email);
  if (existing) return fail(res, 409, 'Ya existe una cuenta registrada con este correo');

  const now = new Date().toISOString();
  const user = sanitizeStoredUser({
    id: createId('user'),
    fullName,
    email,
    phone,
    role: 'student',
    createdAt: now,
    lastLoginAt: now,
    passwordHash: hashPassword(password),
  });
  await insertUser(user);
  created(res, { user: publicUser(user), token: createToken(user) }, 'Cuenta creada correctamente');
}

async function login(req, res) {
  const body = await readRequestBody(req);
  const email = normalizeEmail(body.email);
  const password = String(body.password || '');

  const emailError = validateInstitutionalEmail(email);
  if (emailError) return fail(res, 400, emailError);
  const passwordError = validatePassword(password);
  if (passwordError) return fail(res, 400, passwordError);

  const user = await findUserByEmail(email);
  if (!user) return fail(res, 401, 'Correo o contraseña incorrectos');
  if (!verifyPassword(password, user.passwordHash)) return fail(res, 401, 'Correo o contraseña incorrectos');

  await updateUserLogin(user.id);
  ok(res, { user: publicUser(user), token: createToken(user) }, 'Inicio de sesión correcto');
}

function me(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  ok(res, { user: publicUser(user) }, 'Usuario autenticado');
}

function logout(req, res) {
  ok(res, null, 'Sesión cerrada localmente');
}

module.exports = { register, login, me, logout };