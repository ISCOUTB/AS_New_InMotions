import '../../core/constants/app_config.dart';
import '../../core/models/user_model.dart';
import '../../core/storage/local_session_storage.dart';
import '../../core/utils/validators.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({LocalSessionStorage? storage}) : _storage = storage ?? LocalSessionStorage();

  final LocalSessionStorage _storage;

  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    _throwIfInvalid(Validators.validateInstitutionalEmail(normalizedEmail));
    _throwIfInvalid(Validators.validatePassword(password));

    await Future<void>.delayed(const Duration(milliseconds: 600));

    final registeredUser = await _storage.getRegisteredUser();
    final registeredPassword = await _storage.getRegisteredPassword();

    final isDemoUser = normalizedEmail == AppConfig.demoEmail && password == AppConfig.demoPassword;
    final isRegisteredUser = registeredUser != null &&
        registeredUser.email.toLowerCase() == normalizedEmail &&
        registeredPassword == password;

    if (!isDemoUser && !isRegisteredUser) {
      throw AuthException('Correo o contraseña incorrectos');
    }

    final now = DateTime.now();
    late final UserModel user;

    if (isDemoUser) {
      user = UserModel(
        id: 'demo-user-utb',
        fullName: AppConfig.demoName,
        email: AppConfig.demoEmail,
        role: 'student',
        createdAt: now,
        lastLoginAt: now,
      );
    } else if (registeredUser != null && isRegisteredUser) {
      user = registeredUser.copyWith(lastLoginAt: now);
    } else {
      throw AuthException('Correo o contraseña incorrectos');
    }

    final token = 'local-token-${user.id}-${now.millisecondsSinceEpoch}';
    await _storage.saveSession(token: token, user: user);

    return user;
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final cleanPhone = phone?.trim();

    _throwIfInvalid(Validators.validateName(fullName));
    _throwIfInvalid(Validators.validateInstitutionalEmail(normalizedEmail));
    _throwIfInvalid(Validators.validateOptionalPhone(cleanPhone ?? ''));
    _throwIfInvalid(Validators.validatePassword(password));
    _throwIfInvalid(Validators.validateConfirmPassword(password, confirmPassword));

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final registeredUser = await _storage.getRegisteredUser();
    if (registeredUser != null && registeredUser.email.toLowerCase() == normalizedEmail) {
      throw AuthException('Ya existe una cuenta registrada con este correo');
    }

    if (normalizedEmail == AppConfig.demoEmail) {
      throw AuthException('Este correo está reservado como usuario de prueba');
    }

    final now = DateTime.now();
    final user = UserModel(
      id: 'local-user-${now.millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: cleanPhone == null || cleanPhone.isEmpty ? null : cleanPhone,
      role: 'student',
      createdAt: now,
      lastLoginAt: now,
    );

    await _storage.saveRegisteredUser(user: user, password: password);
    await _storage.saveSession(token: 'local-token-${user.id}-${now.millisecondsSinceEpoch}', user: user);

    return user;
  }

  Future<UserModel?> getCurrentUser() {
    return _storage.getCurrentUser();
  }

  Future<bool> isLoggedIn() {
    return _storage.isLoggedIn();
  }

  Future<void> logout() {
    return _storage.clearSession();
  }

  void _throwIfInvalid(String? error) {
    if (error != null) throw AuthException(error);
  }
}
