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
const MOODS_FILE = path.join(DATA_DIR, 'local-moods.json');

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
  if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

  if (!fs.existsSync(USERS_FILE)) {
    const user = sanitizeStoredUser({
      ...demoUserSeed,
      passwordHash: hashPassword(demoUserSeed.password),
    });
    fs.writeFileSync(USERS_FILE, JSON.stringify([user], null, 2), 'utf8');
  }

  if (!fs.existsSync(MOODS_FILE)) {
    fs.writeFileSync(MOODS_FILE, JSON.stringify([], null, 2), 'utf8');
  }
}

function readJsonFile(filePath, fallback) {
  ensureDataFiles();
  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(raw);
  } catch (_) {
    return fallback;
  }
}

function writeJsonFile(filePath, data) {
  ensureDataFiles();
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

function readUsers() {
  return readJsonFile(USERS_FILE, []);
}

function writeUsers(users) {
  writeJsonFile(USERS_FILE, users);
}

function readMoods() {
  return readJsonFile(MOODS_FILE, []);
}

function writeMoods(records) {
  writeJsonFile(MOODS_FILE, records);
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

function validateMoodPayload(body) {
  const mood = String(body.mood || '').trim();
  const level = Number(body.level);
  const note = String(body.note || '').trim();
  const tags = Array.isArray(body.tags) ? body.tags.map(tag => String(tag).trim()).filter(Boolean) : [];

  if (!mood) return { error: 'Selecciona una emoción para continuar' };
  if (!Number.isInteger(level) || level < 1 || level > 5) {
    return { error: 'El nivel emocional debe estar entre 1 y 5' };
  }
  if (note.length > 500) return { error: 'La nota no debe superar los 500 caracteres' };

  return { mood, level, note, tags };
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

function publicMood(record) {
  return {
    id: record.id,
    userId: record.userId,
    mood: record.mood,
    level: record.level,
    tags: record.tags || [],
    note: record.note || '',
    createdAt: record.createdAt,
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

function requireAuth(req, res) {
  const user = getAuthUser(req);
  if (!user) {
    fail(res, 401, 'Sesión inválida o expirada');
    return null;
  }
  return user;
}

function isSameDay(isoDate, referenceDate = new Date()) {
  const date = new Date(isoDate);
  return date.getFullYear() === referenceDate.getFullYear()
    && date.getMonth() === referenceDate.getMonth()
    && date.getDate() === referenceDate.getDate();
}

function getStartOfWeek(date = new Date()) {
  const current = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const day = current.getDay() === 0 ? 7 : current.getDay();
  current.setDate(current.getDate() - (day - 1));
  current.setHours(0, 0, 0, 0);
  return current;
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
  const user = requireAuth(req, res);
  if (!user) return;
  return ok(res, { user: publicUser(user) }, 'Usuario autenticado');
}

async function handleCreateMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const body = await readRequestBody(req);
  const validation = validateMoodPayload(body);
  if (validation.error) return fail(res, 400, validation.error);

  const now = new Date().toISOString();
  const record = {
    id: `mood-local-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`,
    userId: user.id,
    mood: validation.mood,
    level: validation.level,
    tags: validation.tags,
    note: validation.note,
    createdAt: now,
  };

  const records = readMoods();
  records.unshift(record);
  writeMoods(records);

  return created(res, { record: publicMood(record) }, 'Registro emocional guardado correctamente');
}

function handleGetMoods(req, res, url) {
  const user = requireAuth(req, res);
  if (!user) return;

  const startDate = url.searchParams.get('startDate');
  const endDate = url.searchParams.get('endDate');
  const start = startDate ? new Date(startDate) : null;
  const end = endDate ? new Date(endDate) : null;

  let records = readMoods().filter(record => record.userId === user.id);

  if (start && !Number.isNaN(start.getTime())) {
    records = records.filter(record => new Date(record.createdAt) >= start);
  }

  if (end && !Number.isNaN(end.getTime())) {
    records = records.filter(record => new Date(record.createdAt) <= end);
  }

  records.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return ok(res, { records: records.map(publicMood) }, 'Historial emocional cargado');
}

function handleGetTodayMood(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const record = readMoods()
    .filter(item => item.userId === user.id && isSameDay(item.createdAt))
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0] || null;

  return ok(res, { record: record ? publicMood(record) : null }, 'Registro emocional de hoy cargado');
}

function handleWeeklyMoodStats(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const startOfWeek = getStartOfWeek();
  const endOfWeek = new Date(startOfWeek);
  endOfWeek.setDate(endOfWeek.getDate() + 7);

  const records = readMoods().filter(record => {
    const createdAt = new Date(record.createdAt);
    return record.userId === user.id && createdAt >= startOfWeek && createdAt < endOfWeek;
  });

  const total = records.reduce((sum, record) => sum + Number(record.level || 0), 0);
  const average = records.length ? total / records.length : 0;

  return ok(res, {
    count: records.length,
    average,
    startDate: startOfWeek.toISOString(),
    endDate: endOfWeek.toISOString(),
  }, 'Estadísticas semanales cargadas');
}

function handleDeleteMood(req, res, moodId) {
  const user = requireAuth(req, res);
  if (!user) return;

  const records = readMoods();
  const index = records.findIndex(record => record.id === moodId && record.userId === user.id);
  if (index < 0) return fail(res, 404, 'Registro emocional no encontrado');

  records.splice(index, 1);
  writeMoods(records);

  return ok(res, null, 'Registro emocional eliminado');
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
        modules: ['auth', 'moods'],
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

    if (req.method === 'POST' && pathname === `${API_PREFIX}/moods`) {
      return handleCreateMood(req, res);
    }

    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods`) {
      return handleGetMoods(req, res, url);
    }

    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods/today`) {
      return handleGetTodayMood(req, res);
    }

    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods/stats/weekly`) {
      return handleWeeklyMoodStats(req, res);
    }

    if (req.method === 'DELETE' && pathname.startsWith(`${API_PREFIX}/moods/`)) {
      const moodId = decodeURIComponent(pathname.substring(`${API_PREFIX}/moods/`.length));
      return handleDeleteMood(req, res, moodId);
    }

    return fail(res, 404, 'Ruta no encontrada');
  } catch (error) {
    return fail(res, 500, error.message || 'Error interno del servidor');
  }
}

ensureDataFiles();

const server = http.createServer(router);
server.listen(PORT, HOST, () => {
  console.log(`AS_New_InMotions backend local activo en http://localhost:${PORT}/api`);
  console.log('Módulos activos: auth + moods');
  console.log('Usuario de prueba: estudiante@utb.edu.co / Test@12345');
});
