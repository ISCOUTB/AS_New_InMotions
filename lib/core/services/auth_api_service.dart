import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class AuthApiService {
  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
  }) {
    return _apiClient.post(
      ApiEndpoints.register,
      authenticated: false,
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) {
    return _apiClient.post(
      ApiEndpoints.login,
      authenticated: false,
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> me() {
    return _apiClient.get(ApiEndpoints.me);
  }

  Future<Map<String, dynamic>> logout() {
    return _apiClient.post(ApiEndpoints.logout);
  }
}
