const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PORT || 3000);
const HOST = process.env.HOST || '0.0.0.0';
const API_PREFIX = '/api';
const INSTITUTIONAL_DOMAIN = '@utb.edu.co';
const TOKEN_SECRET = process.env.TOKEN_SECRET || 'as-new-inmotions-local-secret-change-later';
const DATA_DIR = path.join(__dirname, '..', 'data');
const USERS_FILE = path.join(DATA_DIR, 'local-users.json');

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

function ensureDataFile() {
  if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

  if (!fs.existsSync(USERS_FILE)) {
    const user = sanitizeStoredUser({
      ...demoUserSeed,
      passwordHash: hashPassword(demoUserSeed.password),
    });
    fs.writeFileSync(USERS_FILE, JSON.stringify([user], null, 2), 'utf8');
  }
}

function readUsers() {
  ensureDataFile();
  const raw = fs.readFileSync(USERS_FILE, 'utf8');
  try {
    return JSON.parse(raw);
  } catch (_) {
    return [];
  }
}

function writeUsers(users) {
  ensureDataFile();
  fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2), 'utf8');
}

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateInstitutionalEmail(email) {
  const normalized = normalizeEmail(email);

  if (!normalized) return 'El correo es obligatorio';
  if (!isValidEmail(normalized)) return 'Ingresa un correo válido';
  if (!normalized.endsWith(INSTITUTIONAL_DOMAIN)) {
    return `Debes usar tu correo institucional ${INSTITUTIONAL_DOMAIN}`;
  }

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

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, storedHash) {
  if (!storedHash || !storedHash.includes(':')) return false;
  const [salt, hash] = storedHash.split(':');
  const candidate = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return crypto.timingSafeEqual(Buffer.from(hash, 'hex'), Buffer.from(candidate, 'hex'));
}

function createToken(user) {
  const payload = {
    sub: user.id,
    email: user.email,
    iat: Date.now(),
  };
  const payloadBase64 = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const signature = crypto.createHmac('sha256', TOKEN_SECRET).update(payloadBase64).digest('base64url');
  return `${payloadBase64}.${signature}`;
}

function verifyToken(token) {
  if (!token || !token.includes('.')) return null;
  const [payloadBase64, signature] = token.split('.');
  const expected = crypto.createHmac('sha256', TOKEN_SECRET).update(payloadBase64).digest('base64url');

  if (signature !== expected) return null;

  try {
    return JSON.parse(Buffer.from(payloadBase64, 'base64url').toString('utf8'));
  } catch (_) {
    return null;
  }
}

function publicUser(user) {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone || null,
    profileImagePath: user.profileImagePath || null,
    role: user.role || 'student',
    createdAt: user.createdAt,
    lastLoginAt: user.lastLoginAt || null,
  };
}

function sanitizeStoredUser(user) {
  const copy = { ...user };
  delete copy.password;
  return copy;
}

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  });
  res.end(JSON.stringify(payload));
}

function ok(res, data, message = 'Operación exitosa') {
  sendJson(res, 200, { success: true, message, data });
}

function created(res, data, message = 'Registro creado correctamente') {
  sendJson(res, 201, { success: true, message, data });
}

function fail(res, statusCode, message, details = null) {
  sendJson(res, statusCode, { success: false, message, details });
}

function readRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      if (body.length > 1_000_000) {
        req.destroy();
        reject(new Error('La solicitud es demasiado grande'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (_) {
        reject(new Error('El cuerpo de la solicitud no es un JSON válido'));
      }
    });
  });
}

function getAuthUser(req) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : null;
  const payload = verifyToken(token);
  if (!payload) return null;

  const users = readUsers();
  return users.find(user => user.id === payload.sub && user.email === payload.email) || null;
}

async function handleRegister(req, res) {
  const body = await readRequestBody(req);
  const fullName = String(body.fullName || '').trim();
  const email = normalizeEmail(body.email);
  const phone = body.phone ? String(body.phone).trim() : null;
  const password = String(body.password || '');

  const nameError = validateName(fullName);
  if (nameError) return fail(res, 400, nameError);

  const emailError = validateInstitutionalEmail(email);
  if (emailError) return fail(res, 400, emailError);

  const passwordError = validatePassword(password);
  if (passwordError) return fail(res, 400, passwordError);

  const users = readUsers();
  const exists = users.some(user => normalizeEmail(user.email) === email);
  if (exists) return fail(res, 409, 'Ya existe una cuenta registrada con este correo');

  const now = new Date().toISOString();
  const user = {
    id: `local-user-${Date.now()}`,
    fullName,
    email,
    phone,
    profileImagePath: null,
    role: 'student',
    createdAt: now,
    lastLoginAt: now,
    passwordHash: hashPassword(password),
  };

  users.push(user);
  writeUsers(users);

  const token = createToken(user);
  return created(res, { token, user: publicUser(user) }, 'Cuenta creada correctamente');
}

async function handleLogin(req, res) {
  const body = await readRequestBody(req);
  const email = normalizeEmail(body.email);
  const password = String(body.password || '');

  const emailError = validateInstitutionalEmail(email);
  if (emailError) return fail(res, 400, emailError);

  const passwordError = validatePassword(password);
  if (passwordError) return fail(res, 400, passwordError);

  const users = readUsers();
  const index = users.findIndex(user => normalizeEmail(user.email) === email);
  if (index < 0) return fail(res, 401, 'Correo o contraseña incorrectos');

  const user = users[index];
  if (!verifyPassword(password, user.passwordHash)) {
    return fail(res, 401, 'Correo o contraseña incorrectos');
  }

  user.lastLoginAt = new Date().toISOString();
  users[index] = user;
  writeUsers(users);

  const token = createToken(user);
  return ok(res, { token, user: publicUser(user) }, 'Inicio de sesión exitoso');
}

function handleMe(req, res) {
  const user = getAuthUser(req);
  if (!user) return fail(res, 401, 'Sesión inválida o expirada');
  return ok(res, { user: publicUser(user) }, 'Usuario autenticado');
}

async function router(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  if (req.method === 'OPTIONS') {
    return sendJson(res, 200, { success: true, message: 'OK' });
  }

  try {
    if (req.method === 'GET' && pathname === `${API_PREFIX}/health`) {
      return ok(res, {
        app: 'AS_New_InMotions Backend Local',
        status: 'running',
        timestamp: new Date().toISOString(),
      }, 'Backend local activo');
    }

    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/register`) {
      return handleRegister(req, res);
    }

    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/login`) {
      return handleLogin(req, res);
    }

    if (req.method === 'GET' && pathname === `${API_PREFIX}/auth/me`) {
      return handleMe(req, res);
    }

    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/logout`) {
      return ok(res, null, 'Sesión cerrada localmente');
    }

    return fail(res, 404, 'Ruta no encontrada');
  } catch (error) {
    return fail(res, 500, error.message || 'Error interno del servidor');
  }
}

ensureDataFile();

const server = http.createServer(router);
server.listen(PORT, HOST, () => {
  console.log(`AS_New_InMotions backend local activo en http://localhost:${PORT}/api`);
  console.log('Usuario de prueba: estudiante@utb.edu.co / Test@12345');
});
