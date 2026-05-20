class AppConfig {
  const AppConfig._();

  static const String appName = 'AS_New_InMotions';
  static const String appDisplayName = 'InMotions';
  static const String appSlogan = 'Tu bienestar mental en movimiento';
  static const String universityName = 'Universidad Tecnológica de Bolívar';

  // Paso 12: backend local para auth, registro emocional, triaje, biblioteca y recordatorios.
  // En true, estos módulos usan el servidor local en /backend.
  // Si quieres volver a modo 100% local, cambia este valor a false.
  static const bool useRemoteBackend = true;
  static const String localApiBaseUrl =
      'https://as-new-inmotions.onrender.com/api';
  static const String webOrDesktopApiBaseUrl =
      'https://as-new-inmotions.onrender.com/api';

  // Cuando el backend esté listo, este dominio también debe validarse en servidor.
  static const String institutionalDomain = '@utb.edu.co';

  // Dato temporal para pruebas locales. Reemplazar por correo oficial o endpoint real.
  static const String psychologyDepartmentName = 'Psicología UTB';
  static const String psychologyEmail = 'bienestar@utb.edu.co';

  // Umbrales oficiales del anexo de triaje emocional.
  static const int greenMaxScore = 45;
  static const int yellowMaxScore = 70;
  static const int orangeMaxScore = 95;
  static const int redMaxScore = 115;
  static const int criticalActivationScore = 4;

  // Usuario de prueba local para comenzar sin backend.
  static const String demoEmail = 'estudiante@utb.edu.co';
  static const String demoPassword = 'Test@12345';
  static const String demoName = 'Estudiante UTB';
}
