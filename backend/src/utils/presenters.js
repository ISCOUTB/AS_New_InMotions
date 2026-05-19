function publicUser(user) {
  if (!user) return null;
  return { id: user.id, fullName: user.fullName, email: user.email, phone: user.phone || null, role: user.role || 'student', createdAt: user.createdAt, lastLoginAt: user.lastLoginAt || null };
}
function publicMood(record) { return { id: record.id, userId: record.userId, mood: record.mood, level: record.level, tags: record.tags || [], note: record.note || '', createdAt: record.createdAt, updatedAt: record.updatedAt || record.createdAt }; }
function publicTriageQuestion(question) { return { id: question.id, order: question.order, area: question.area, question: question.question, type: question.type, isCritical: question.isCritical, options: question.options }; }
function publicTriageResult(result) { return result; }
function publicReferral(referral) { return referral; }
function publicResource(resource) { return resource; }
function publicReminder(reminder) { const { userId, ...publicData } = reminder; return publicData; }
function sanitizeStoredUser(user) { const { password, ...safeUser } = user; return safeUser; }
module.exports = { publicUser, publicMood, publicTriageQuestion, publicTriageResult, publicReferral, publicResource, publicReminder, sanitizeStoredUser };
