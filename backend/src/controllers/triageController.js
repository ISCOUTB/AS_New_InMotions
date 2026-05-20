const { readRequestBody, ok, created, fail } = require('../utils/http');
const { createId } = require('../utils/security');
const { publicTriageQuestion, publicTriageResult, publicReferral } = require('../utils/presenters');
const { requireAuth } = require('../middleware/auth');
const { triageThresholds, criticalQuestionIds, psychologyEmail } = require('../config/appConfig');
const { TRIAGE_QUESTIONS } = require('../catalogs/triageQuestions');
const {
  readTriageResults, insertTriageResult, updateTriageReferralStatus,
  readReferrals, insertReferral,
} = require('../storage/localDatabase');

function calculateRiskLevel(score) {
  if (score <= triageThresholds.greenMax) return 'green';
  if (score <= triageThresholds.yellowMax) return 'yellow';
  if (score <= triageThresholds.orangeMax) return 'orange';
  return 'red';
}

function getRecommendationsByRiskLevel(riskLevel) {
  switch (riskLevel) {
    case 'green': return ['Explora recursos preventivos de bienestar.', 'Mantén hábitos de descanso y autocuidado.', 'Puedes repetir el test el próximo mes.'];
    case 'yellow': return ['Explora recursos de autorregulación y biblioterapia.', 'Activa un recordatorio para revisar cómo evolucionas.', 'Si el malestar persiste, agenda una cita con Psicología UTB.'];
    case 'orange': return ['Agenda una cita con Psicología UTB.', 'Usa la biblioteca como apoyo paralelo, no como sustituto profesional.', 'Comparte cómo te sientes con una persona de confianza.'];
    case 'red': return ['Contacta a Psicología UTB hoy mismo.', 'Ten disponibles líneas de crisis: 192 y 123.', 'Evita quedarte solo/a si sientes que estás en riesgo.'];
    case 'critical': return ['Llama a la línea 123 si estás en peligro inmediato.', 'Comunícate con la línea 192 de salud mental.', 'Contacta a Psicología UTB con prioridad.'];
    default: return [];
  }
}

function validateAndBuildTriageAnswers(rawAnswers) {
  if (!Array.isArray(rawAnswers)) return { error: 'Las respuestas deben enviarse como una lista' };
  const byQuestionId = new Map(rawAnswers.map(a => [String(a.questionId || ''), a]));
  const missing = TRIAGE_QUESTIONS.filter(q => !byQuestionId.has(q.id));
  if (missing.length > 0) return { error: 'Responde todas las preguntas antes de ver el resultado', missingQuestions: missing.map(q => q.id) };
  const answers = [];
  for (const question of TRIAGE_QUESTIONS) {
    const raw = byQuestionId.get(question.id);
    const optionId = String(raw.optionId || '');
    const option = question.options.find(o => o.id === optionId);
    if (!option) return { error: `La respuesta seleccionada para ${question.id} no es válida` };
    answers.push({ questionId: question.id, optionId: option.id, score: option.score, question: question.question, selectedText: option.text, area: question.area, isCritical: question.isCritical });
  }
  return { answers };
}

async function createReferralForResult(user, result) {
  const referral = {
    id: createId('referral'),
    userId: user.id,
    triageResultId: result.id,
    score: result.score,
    riskLevel: result.riskLevel,
    status: 'pending',
    method: 'local-simulated-email',
    psychologyEmail,
    message: `Derivación simulada para ${user.email}. Resultado ${result.riskLevel} con puntaje ${result.score}.`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  await insertReferral(referral);
  return referral;
}

function getQuestions(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  ok(res, { questions: TRIAGE_QUESTIONS.map(publicTriageQuestion) }, 'Preguntas de triaje cargadas');
}

async function submitTriage(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const body = await readRequestBody(req);
  const validation = validateAndBuildTriageAnswers(body.answers);
  if (validation.error) return fail(res, 400, validation.error, validation.missingQuestions ? { missingQuestions: validation.missingQuestions } : null);

  const score = validation.answers.reduce((sum, a) => sum + a.score, 0);
  const criticalHits = validation.answers.filter(a => criticalQuestionIds.includes(a.questionId) && a.score >= triageThresholds.criticalActivationScore).map(a => a.questionId);
  const isCriticalProtocol = criticalHits.length > 0;
  const riskLevel = isCriticalProtocol ? 'critical' : calculateRiskLevel(score);
  const requiresReferral = ['orange', 'red', 'critical'].includes(riskLevel);
  const now = new Date().toISOString();
  const result = {
    id: createId('triage'),
    userId: user.id,
    score,
    riskLevel,
    requiresReferral,
    answers: validation.answers,
    recommendations: getRecommendationsByRiskLevel(riskLevel),
    createdAt: now,
    referralStatus: requiresReferral ? 'pending' : null,
    isCriticalProtocol,
    criticalQuestionIds: criticalHits,
  };
  await insertTriageResult(result);

  let referral = null;
  if (requiresReferral) {
    referral = await createReferralForResult(user, result);
    result.referralStatus = referral.status;
    await updateTriageReferralStatus(result.id, referral.status);
  }

  created(res, { result: publicTriageResult(result), referral: referral ? publicReferral(referral) : null }, 'Resultado de triaje calculado');
}

async function getResults(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const results = (await readTriageResults()).filter(r => r.userId === user.id);
  ok(res, { results: results.map(publicTriageResult) }, 'Resultados de triaje cargados');
}

async function getReferrals(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const referrals = (await readReferrals()).filter(r => r.userId === user.id);
  ok(res, { referrals: referrals.map(publicReferral) }, 'Derivaciones cargadas');
}

module.exports = { getQuestions, submitTriage, getResults, getReferrals };