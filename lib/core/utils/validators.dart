import '../constants/app_config.dart';

class Validators {
  const Validators._();

  static String? requiredField(String value, {String fieldName = 'Este campo'}) {
    if (value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  static String? validateName(String value) {
    final required = requiredField(value, fieldName: 'El nombre');
    if (required != null) return required;

    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    return null;
  }

  static String? validateInstitutionalEmail(String value) {
    final email = value.trim().toLowerCase();
    final required = requiredField(email, fieldName: 'El correo');
    if (required != null) return required;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    if (!email.endsWith(AppConfig.institutionalDomain)) {
      return 'Debes usar tu correo institucional ${AppConfig.institutionalDomain}';
    }

    return null;
  }

  static String? validatePassword(String value) {
    final required = requiredField(value, fieldName: 'La contraseña');
    if (required != null) return required;

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    final required = requiredField(confirmPassword, fieldName: 'La confirmación de contraseña');
    if (required != null) return required;

    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  static String? validateOptionalPhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return null;

    if (phone.length < 7) {
      return 'Ingresa un teléfono válido o deja el campo vacío';
    }

    return null;
  }

  static String? validateMoodSelection(String? mood) {
    if (mood == null || mood.trim().isEmpty) {
      return 'Selecciona una emoción antes de guardar';
    }

    return null;
  }

  static String? validateMoodLevel(int level) {
    if (level < 1 || level > 5) {
      return 'El nivel emocional debe estar entre 1 y 5';
    }

    return null;
  }

  static String? validateMoodNote(String note, {int maxLength = 280}) {
    if (note.length > maxLength) {
      return 'La nota no debe superar $maxLength caracteres';
    }

    return null;
  }

}
