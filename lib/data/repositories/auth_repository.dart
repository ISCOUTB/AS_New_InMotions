import '../../core/constants/app_config.dart';
import '../../core/models/user_model.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/auth_api_service.dart';
import '../../core/storage/local_session_storage.dart';
import '../../core/utils/validators.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    LocalSessionStorage? storage,
    AuthApiService? authApiService,
  })  : _storage = storage ?? LocalSessionStorage(),
        _authApiService = authApiService ?? AuthApiService();

  final LocalSessionStorage _storage;
  final AuthApiService _authApiService;

  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    _throwIfInvalid(Validators.validateInstitutionalEmail(normalizedEmail));
    _throwIfInvalid(Validators.validatePassword(password));

    if (AppConfig.useRemoteBackend) {
      return _loginRemote(email: normalizedEmail, password: password);
    }

    return _loginLocal(email: normalizedEmail, password: password);
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

    if (AppConfig.useRemoteBackend) {
      return _registerRemote(
        fullName: fullName.trim(),
        email: normalizedEmail,
        phone: cleanPhone,
        password: password,
      );
    }

    return _registerLocal(
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: cleanPhone,
      password: password,
    );
  }

  Future<UserModel?> getCurrentUser() {
    return _storage.getCurrentUser();
  }

  Future<void> updateCurrentUser(UserModel user) {
    return _storage.updateCurrentUser(user);
  }

  Future<bool> isLoggedIn() {
    return _storage.isLoggedIn();
  }

  Future<void> logout() async {
    if (AppConfig.useRemoteBackend) {
      try {
        await _authApiService.logout();
      } catch (_) {
        // Si el backend local no está disponible, igual se borra la sesión local.
      }
    }

    await _storage.clearSession();
  }

  Future<UserModel> _loginRemote({required String email, required String password}) async {
    try {
      final response = await _authApiService.login(email: email, password: password);
      final session = _parseSessionResponse(response);
      await _storage.saveSession(token: session.token, user: session.user);
      return session.user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } catch (_) {
      throw AuthException('No fue posible conectar con el backend local. Verifica que esté ejecutándose.');
    }
  }

  Future<UserModel> _registerRemote({
    required String fullName,
    required String email,
    String? phone,
    required String password,
  }) async {
    try {
      final response = await _authApiService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      final session = _parseSessionResponse(response);
      await _storage.saveSession(token: session.token, user: session.user);
      return session.user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } catch (_) {
      throw AuthException('No fue posible conectar con el backend local. Verifica que esté ejecutándose.');
    }
  }

  Future<UserModel> _loginLocal({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final registeredUser = await _storage.getRegisteredUser();
    final registeredPassword = await _storage.getRegisteredPassword();

    final isDemoUser = email == AppConfig.demoEmail && password == AppConfig.demoPassword;
    final isRegisteredUser = registeredUser != null &&
        registeredUser.email.toLowerCase() == email &&
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

  Future<UserModel> _registerLocal({
    required String fullName,
    required String email,
    String? phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final registeredUser = await _storage.getRegisteredUser();
    if (registeredUser != null && registeredUser.email.toLowerCase() == email) {
      throw AuthException('Ya existe una cuenta registrada con este correo');
    }

    if (email == AppConfig.demoEmail) {
      throw AuthException('Este correo está reservado como usuario de prueba');
    }

    final now = DateTime.now();
    final user = UserModel(
      id: 'local-user-${now.millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone == null || phone.isEmpty ? null : phone,
      role: 'student',
      createdAt: now,
      lastLoginAt: now,
    );

    await _storage.saveRegisteredUser(user: user, password: password);
    await _storage.saveSession(token: 'local-token-${user.id}-${now.millisecondsSinceEpoch}', user: user);

    return user;
  }

  _RemoteSession _parseSessionResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AuthException('Respuesta inválida del servidor');
    }

    final token = data['token'] as String?;
    final userData = data['user'];

    if (token == null || token.isEmpty || userData is! Map<String, dynamic>) {
      throw AuthException('Respuesta de autenticación incompleta');
    }

    return _RemoteSession(
      token: token,
      user: UserModel.fromMap(userData),
    );
  }

  void _throwIfInvalid(String? error) {
    if (error != null) throw AuthException(error);
  }
}

class _RemoteSession {
  const _RemoteSession({required this.token, required this.user});

  final String token;
  final UserModel user;
}
