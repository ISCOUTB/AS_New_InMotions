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
  static const String psychologyEmail = 'psicologia@utb.edu.co';

  // Umbral definido inicialmente según el entregable del proyecto.
  static const int highRiskThreshold = 15;

  // Usuario de prueba local para comenzar sin backend.
  static const String demoEmail = 'estudiante@utb.edu.co';
  static const String demoPassword = 'Test@12345';
  static const String demoName = 'Estudiante UTB';
}
