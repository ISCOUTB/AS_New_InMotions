function isSameDay(isoDate, referenceDate = new Date()) {
  const date = new Date(isoDate);
  return date.getFullYear() === referenceDate.getFullYear() && date.getMonth() === referenceDate.getMonth() && date.getDate() === referenceDate.getDate();
}
function getStartOfWeek(date = new Date()) {
  const current = new Date(date);
  const day = current.getDay() || 7;
  current.setHours(0, 0, 0, 0);
  current.setDate(current.getDate() - day + 1);
  return current;
}
module.exports = { isSameDay, getStartOfWeek };
