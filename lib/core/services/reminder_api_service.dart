import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class ReminderApiService {
  ReminderApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getReminders() {
    return _apiClient.get(ApiEndpoints.reminders);
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> data) {
    return _apiClient.post(ApiEndpoints.reminders, body: data);
  }

  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> data) {
    return _apiClient.put('${ApiEndpoints.reminders}/$id', body: data);
  }

  Future<Map<String, dynamic>> deleteReminder(String id) {
    return _apiClient.delete('${ApiEndpoints.reminders}/$id');
  }

  Future<Map<String, dynamic>> registerDeviceToken(String token) {
    return _apiClient.post(
      ApiEndpoints.registerDevice,
      body: {'token': token},
    );
  }
}
