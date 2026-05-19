class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String moods = '/moods';
  static const String todayMood = '/moods/today';
  static const String weeklyMoodStats = '/moods/stats/weekly';

  static const String triageQuestions = '/triage/questions';
  static const String triageSubmit = '/triage/submit';
  static const String triageResults = '/triage/results';

  static const String resources = '/articles';
  static const String resourceCategories = '/articles/categories';
  static const String favoriteResources = '/articles/favorites';

  static const String reminders = '/reminders';
  static const String registerDevice = '/devices/register';
}
