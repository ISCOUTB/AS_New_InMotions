class AppConfig {
  const AppConfig._();

  static const String appName = 'AS_New_InMotions';
  static const String appDisplayName = 'InMotions';
  static const String appSlogan = 'Tu bienestar mental en movimiento';
  static const String universityName = 'Universidad Tecnológica de Bolívar';

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
