const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PORT || 3000);
const HOST = process.env.HOST || '0.0.0.0';
const API_PREFIX = '/api';
const INSTITUTIONAL_DOMAIN = '@utb.edu.co';
const PSYCHOLOGY_EMAIL = process.env.PSYCHOLOGY_EMAIL || 'bienestar@utb.edu.co';
const TOKEN_SECRET = process.env.TOKEN_SECRET || 'as-new-inmotions-local-secret-change-later';
const DATA_DIR = path.join(__dirname, '..', 'data');
const USERS_FILE = path.join(DATA_DIR, 'local-users.json');
const MOODS_FILE = path.join(DATA_DIR, 'local-moods.json');
const TRIAGE_RESULTS_FILE = path.join(DATA_DIR, 'local-triage-results.json');
const REFERRALS_FILE = path.join(DATA_DIR, 'local-referrals.json');

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

const TRIAGE_THRESHOLDS = {
  greenMax: 45,
  yellowMax: 70,
  orangeMax: 95,
  redMax: 115,
  criticalActivationScore: 4,
};

const CRITICAL_QUESTION_IDS = ['A5', 'F1', 'F2'];

function likertOptions(questionId) {
  return [
    {
      id: `${questionId}_1`,
      text: 'No me identifico',
      score: 1,
      interpretation: 'Esto no me ha ocurrido en el periodo evaluado.',
    },
    {
      id: `${questionId}_2`,
      text: 'Poco',
      score: 2,
      interpretation: 'Me ha ocurrido muy esporádicamente.',
    },
    {
      id: `${questionId}_3`,
      text: 'Moderadamente',
      score: 3,
      interpretation: 'Me ha ocurrido con cierta frecuencia.',
    },
    {
      id: `${questionId}_4`,
      text: 'Bastante',
      score: 4,
      interpretation: 'Me ha ocurrido frecuentemente.',
    },
    {
      id: `${questionId}_5`,
      text: 'Totalmente',
      score: 5,
      interpretation: 'Esta afirmación me describe completamente.',
    },
  ];
}

function q({ id, order, area, question, type = 'Estándar', isCritical = false }) {
  return {
    id,
    order,
    area,
    question,
    type,
    isCritical,
    isActive: true,
    options: likertOptions(id),
  };
}

const TRIAGE_QUESTIONS = [
  q({ id: 'A1', order: 1, area: 'Depresión', question: 'He sentido poco interés o placer en hacer cosas que antes disfrutaba.' }),
  q({ id: 'A2', order: 2, area: 'Depresión', question: 'Me he sentido triste, vacío/a o sin esperanza la mayor parte del tiempo.' }),
  q({ id: 'A3', order: 3, area: 'Depresión', question: 'He tenido dificultad para dormir (insomnio) o he dormido demasiado.' }),
  q({ id: 'A4', order: 4, area: 'Depresión', question: 'Me he sentido cansado/a o con poca energía, incluso después de descansar.' }),
  q({ id: 'A5', order: 5, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true }),
  q({ id: 'B1', order: 6, area: 'Ansiedad', question: 'Me he sentido nervioso/a, ansioso/a o con los nervios de punta.' }),
  q({ id: 'B2', order: 7, area: 'Ansiedad', question: 'No he podido dejar de preocuparme o controlar mis pensamientos ansiosos.' }),
  q({ id: 'B3', order: 8, area: 'Ansiedad', question: 'Me he preocupado demasiado por diferentes situaciones de mi vida.' }),
  q({ id: 'B4', order: 9, area: 'Ansiedad', question: 'He tenido dificultad para relajarme o me siento inquieto/a físicamente.' }),
  q({ id: 'B5', order: 10, area: 'Ansiedad', question: 'Me he irritado o molestado con facilidad por cosas pequeñas.' }),
  q({ id: 'C1', order: 11, area: 'Estrés', question: 'Me he sentido abrumado/a por mis responsabilidades diarias.' }),
  q({ id: 'C2', order: 12, area: 'Estrés', question: 'He tenido dificultad para concentrarme en tareas cotidianas.' }),
  q({ id: 'C3', order: 13, area: 'Estrés', question: 'Siento que no tengo tiempo para descansar o recuperarme.' }),
  q({ id: 'C4', order: 14, area: 'Estrés', question: 'He experimentado tensión muscular, dolores de cabeza o malestar físico sin causa médica clara.' }),
  q({ id: 'D1', order: 15, area: 'Regulación', question: 'Me cuesta manejar emociones intensas como tristeza, enojo o miedo.' }),
  q({ id: 'D2', order: 16, area: 'Regulación', question: 'Cuando algo sale mal, tiendo a pensar que todo está perdido.' }),
  q({ id: 'D3', order: 17, area: 'Regulación', question: 'Siento que no tengo herramientas para afrontar momentos difíciles.' }),
  q({ id: 'D4', order: 18, area: 'Regulación', question: 'Evito enfrentar problemas porque me generan mucha ansiedad o malestar.' }),
  q({ id: 'E1', order: 19, area: 'Social', question: 'Me he aislado de familiares o amigos, evitando contacto social.' }),
  q({ id: 'E2', order: 20, area: 'Social', question: 'He sentido que no puedo cumplir con mis responsabilidades (estudio, trabajo, hogar).' }),
  q({ id: 'E3', order: 21, area: 'Social', question: 'He notado que mi estado emocional afecta mis relaciones con otras personas.' }),
  q({ id: 'F1', order: 22, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true }),
  q({ id: 'F2', order: 23, area: 'Crisis', question: 'He tenido pensamientos sobre lastimarme o terminar con mi vida.', type: 'Crítico', isCritical: true }),
];

function ensureDataFiles() {
  if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

  if (!fs.existsSync(USERS_FILE)) {
    const user = sanitizeStoredUser({
      ...demoUserSeed,
      passwordHash: hashPassword(demoUserSeed.password),
    });
    fs.writeFileSync(USERS_FILE, JSON.stringify([user], null, 2), 'utf8');
  }

  if (!fs.existsSync(MOODS_FILE)) fs.writeFileSync(MOODS_FILE, JSON.stringify([], null, 2), 'utf8');
  if (!fs.existsSync(TRIAGE_RESULTS_FILE)) fs.writeFileSync(TRIAGE_RESULTS_FILE, JSON.stringify([], null, 2), 'utf8');
  if (!fs.existsSync(REFERRALS_FILE)) fs.writeFileSync(REFERRALS_FILE, JSON.stringify([], null, 2), 'utf8');
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

function readUsers() { return readJsonFile(USERS_FILE, []); }
function writeUsers(users) { writeJsonFile(USERS_FILE, users); }
function readMoods() { return readJsonFile(MOODS_FILE, []); }
function writeMoods(records) { writeJsonFile(MOODS_FILE, records); }
function readTriageResults() { return readJsonFile(TRIAGE_RESULTS_FILE, []); }
function writeTriageResults(results) { writeJsonFile(TRIAGE_RESULTS_FILE, results); }
function readReferrals() { return readJsonFile(REFERRALS_FILE, []); }
function writeReferrals(referrals) { writeJsonFile(REFERRALS_FILE, referrals); }

function normalizeEmail(email) { return String(email || '').trim().toLowerCase(); }
function isValidEmail(email) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }

function validateInstitutionalEmail(email) {
  const normalized = normalizeEmail(email);
  if (!normalized) return 'El correo es obligatorio';
  if (!isValidEmail(normalized)) return 'Ingresa un correo válido';
  if (!normalized.endsWith(INSTITUTIONAL_DOMAIN)) return `Debes usar tu correo institucional ${INSTITUTIONAL_DOMAIN}`;
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
  if (!Number.isInteger(level) || level < 1 || level > 5) return { error: 'El nivel emocional debe estar entre 1 y 5' };
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
  const payload = { sub: user.id, email: user.email, iat: Date.now() };
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

function publicTriageQuestion(question) {
  return {
    id: question.id,
    area: question.area,
    question: question.question,
    type: question.type,
    options: question.options,
    order: question.order,
    isActive: question.isActive,
    isCritical: question.isCritical,
  };
}

function publicTriageResult(result) {
  return {
    id: result.id,
    userId: result.userId,
    score: result.score,
    riskLevel: result.riskLevel,
    requiresReferral: result.requiresReferral,
    answers: result.answers || [],
    recommendations: result.recommendations || [],
    createdAt: result.createdAt,
    referralStatus: result.referralStatus || null,
    isCriticalProtocol: result.isCriticalProtocol || false,
    criticalQuestionIds: result.criticalQuestionIds || [],
  };
}

function publicReferral(referral) {
  return {
    id: referral.id,
    userId: referral.userId,
    triageResultId: referral.triageResultId,
    score: referral.score,
    riskLevel: referral.riskLevel,
    status: referral.status,
    method: referral.method,
    contactEmail: referral.contactEmail,
    createdAt: referral.createdAt,
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

function ok(res, data, message = 'Operación exitosa') { sendJson(res, 200, { success: true, message, data }); }
function created(res, data, message = 'Registro creado correctamente') { sendJson(res, 201, { success: true, message, data }); }
function fail(res, statusCode, message, details = null) { sendJson(res, statusCode, { success: false, message, details }); }

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
      try { resolve(JSON.parse(body)); } catch (_) { reject(new Error('El cuerpo de la solicitud no es un JSON válido')); }
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

function calculateRiskLevel(score) {
  if (score <= TRIAGE_THRESHOLDS.greenMax) return 'green';
  if (score <= TRIAGE_THRESHOLDS.yellowMax) return 'yellow';
  if (score <= TRIAGE_THRESHOLDS.orangeMax) return 'orange';
  return 'red';
}

function getRecommendationsByRiskLevel(riskLevel) {
  switch (riskLevel) {
    case 'green':
      return [
        'Explora el blog de bienestar y recursos preventivos de la aplicación.',
        'Mantén tu diario emocional como herramienta de seguimiento.',
        'Realiza una reevaluación mensual o cuando notes cambios importantes.',
      ];
    case 'yellow':
      return [
        'Explora recursos de autorregulación, biblioterapia y ejercicios prácticos.',
        'Activa un recordatorio para revisar cómo te sientes en las próximas dos semanas.',
        'Si el malestar persiste, agenda una cita con Psicología UTB para recibir apoyo personalizado.',
      ];
    case 'orange':
      return [
        'Agenda una cita con Bienestar Universitario - Área de Psicología.',
        'Usa la biblioteca como apoyo paralelo, no como sustituto de la atención profesional.',
        'Busca acompañamiento de una persona de confianza mientras recibes orientación.',
      ];
    case 'red':
      return [
        'Contacta a Psicología UTB hoy mismo: bienestar@utb.edu.co.',
        'Mantén disponibles líneas de crisis: Línea 192 y Línea 123.',
        'Evita manejar este malestar en soledad; busca apoyo inmediato.',
      ];
    case 'critical':
      return [
        'Si estás en peligro inmediato, llama al 123.',
        'Contacta la Línea 192 de Salud Mental Colombia, gratuita y disponible 24/7.',
        'Contacta a Psicología UTB: bienestar@utb.edu.co.',
        'No tienes que enfrentar esto solo/a; busca apoyo ahora mismo.',
      ];
    default:
      return [];
  }
}

function requiresReferral(riskLevel) {
  return riskLevel === 'orange' || riskLevel === 'red' || riskLevel === 'critical';
}

function validateAndBuildTriageAnswers(rawAnswers) {
  if (!Array.isArray(rawAnswers)) return { error: 'Las respuestas deben enviarse como una lista' };

  const activeQuestions = TRIAGE_QUESTIONS.filter(question => question.isActive).sort((a, b) => a.order - b.order);
  const answersByQuestionId = new Map();

  for (const item of rawAnswers) {
    const questionId = String(item.questionId || '').trim();
    const optionId = String(item.optionId || '').trim();
    if (!questionId || !optionId) return { error: 'Cada respuesta debe incluir questionId y optionId' };
    answersByQuestionId.set(questionId, optionId);
  }

  const missing = activeQuestions.filter(question => !answersByQuestionId.has(question.id));
  if (missing.length > 0) return { error: 'Responde todas las preguntas antes de ver el resultado', missingQuestions: missing.map(q => q.id) };

  const normalizedAnswers = [];

  for (const question of activeQuestions) {
    const optionId = answersByQuestionId.get(question.id);
    const option = question.options.find(candidate => candidate.id === optionId);
    if (!option) return { error: `La respuesta seleccionada para ${question.id} no es válida` };

    normalizedAnswers.push({
      questionId: question.id,
      optionId: option.id,
      optionText: option.text,
      score: option.score,
    });
  }

  return { answers: normalizedAnswers };
}

function createReferralForResult(user, result) {
  const referral = {
    id: `referral-local-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`,
    userId: user.id,
    studentEmail: user.email,
    studentName: user.fullName,
    triageResultId: result.id,
    score: result.score,
    riskLevel: result.riskLevel,
    status: 'pendiente_atencion',
    method: 'simulacion_local',
    contactEmail: PSYCHOLOGY_EMAIL,
    createdAt: new Date().toISOString(),
  };

  const referrals = readReferrals();
  referrals.unshift(referral);
  writeReferrals(referrals);

  return referral;
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
  if (!verifyPassword(password, user.passwordHash)) return fail(res, 401, 'Correo o contraseña incorrectos');

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

  if (start && !Number.isNaN(start.getTime())) records = records.filter(record => new Date(record.createdAt) >= start);
  if (end && !Number.isNaN(end.getTime())) records = records.filter(record => new Date(record.createdAt) <= end);

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

  return ok(res, { count: records.length, average, startDate: startOfWeek.toISOString(), endDate: endOfWeek.toISOString() }, 'Estadísticas semanales cargadas');
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

function handleGetTriageQuestions(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const questions = TRIAGE_QUESTIONS
    .filter(question => question.isActive)
    .sort((a, b) => a.order - b.order)
    .map(publicTriageQuestion);

  return ok(res, { questions }, 'Preguntas de triaje cargadas');
}

async function handleSubmitTriage(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const body = await readRequestBody(req);
  const validation = validateAndBuildTriageAnswers(body.answers);
  if (validation.error) return fail(res, 400, validation.error, validation.missingQuestions ? { missingQuestions: validation.missingQuestions } : null);

  const answers = validation.answers;
  const score = answers.reduce((sum, answer) => sum + answer.score, 0);
  const criticalQuestionIds = answers
    .filter(answer => CRITICAL_QUESTION_IDS.includes(answer.questionId) && answer.score >= TRIAGE_THRESHOLDS.criticalActivationScore)
    .map(answer => answer.questionId);
  const isCriticalProtocol = criticalQuestionIds.length > 0;
  const riskLevel = isCriticalProtocol ? 'critical' : calculateRiskLevel(score);
  const now = new Date().toISOString();

  const result = {
    id: `triage-local-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`,
    userId: user.id,
    score,
    riskLevel,
    requiresReferral: requiresReferral(riskLevel),
    answers,
    recommendations: getRecommendationsByRiskLevel(riskLevel),
    createdAt: now,
    referralStatus: requiresReferral(riskLevel) ? 'pendiente_atencion' : null,
    isCriticalProtocol,
    criticalQuestionIds,
  };

  const results = readTriageResults();
  results.unshift(result);
  writeTriageResults(results);

  const referral = result.requiresReferral ? createReferralForResult(user, result) : null;

  return created(res, {
    result: publicTriageResult(result),
    referral: referral ? publicReferral(referral) : null,
  }, isCriticalProtocol ? 'Protocolo crítico activado y resultado guardado' : 'Resultado de triaje calculado correctamente');
}

function handleGetTriageResults(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const results = readTriageResults()
    .filter(result => result.userId === user.id)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  return ok(res, { results: results.map(publicTriageResult) }, 'Resultados de triaje cargados');
}

function handleGetReferrals(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;

  const referrals = readReferrals()
    .filter(referral => referral.userId === user.id)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  return ok(res, { referrals: referrals.map(publicReferral) }, 'Derivaciones locales cargadas');
}

async function router(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  if (req.method === 'OPTIONS') return sendJson(res, 200, { success: true, message: 'OK' });

  try {
    if (req.method === 'GET' && pathname === `${API_PREFIX}/health`) {
      return ok(res, {
        app: 'AS_New_InMotions Backend Local',
        status: 'running',
        timestamp: new Date().toISOString(),
        modules: ['auth', 'moods', 'triage'],
      }, 'Backend local activo');
    }

    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/register`) return handleRegister(req, res);
    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/login`) return handleLogin(req, res);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/auth/me`) return handleMe(req, res);
    if (req.method === 'POST' && pathname === `${API_PREFIX}/auth/logout`) return ok(res, null, 'Sesión cerrada localmente');

    if (req.method === 'POST' && pathname === `${API_PREFIX}/moods`) return handleCreateMood(req, res);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods`) return handleGetMoods(req, res, url);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods/today`) return handleGetTodayMood(req, res);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/moods/stats/weekly`) return handleWeeklyMoodStats(req, res);
    if (req.method === 'DELETE' && pathname.startsWith(`${API_PREFIX}/moods/`)) {
      const moodId = decodeURIComponent(pathname.substring(`${API_PREFIX}/moods/`.length));
      return handleDeleteMood(req, res, moodId);
    }

    if (req.method === 'GET' && pathname === `${API_PREFIX}/triage/questions`) return handleGetTriageQuestions(req, res);
    if (req.method === 'POST' && pathname === `${API_PREFIX}/triage/submit`) return handleSubmitTriage(req, res);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/triage/results`) return handleGetTriageResults(req, res);
    if (req.method === 'GET' && pathname === `${API_PREFIX}/referrals`) return handleGetReferrals(req, res);

    return fail(res, 404, 'Ruta no encontrada');
  } catch (error) {
    return fail(res, 500, error.message || 'Error interno del servidor');
  }
}

ensureDataFiles();
const server = http.createServer(router);
server.listen(PORT, HOST, () => {
  console.log(`AS_New_InMotions backend local activo en http://localhost:${PORT}/api`);
  console.log('Módulos activos: auth + moods + triage');
  console.log('Usuario de prueba: estudiante@utb.edu.co / Test@12345');
});
