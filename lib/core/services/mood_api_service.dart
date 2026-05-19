import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class MoodApiService {
  MoodApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createMoodRecord(Map<String, dynamic> data) {
    return _apiClient.post(ApiEndpoints.moods, body: data);
  }

  Future<Map<String, dynamic>> getMoodHistory({String? startDate, String? endDate}) {
    return _apiClient.get(
      ApiEndpoints.moods,
      queryParameters: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );
  }

  Future<Map<String, dynamic>> getTodayMood() {
    return _apiClient.get(ApiEndpoints.todayMood);
  }

  Future<Map<String, dynamic>> getWeeklyStats() {
    return _apiClient.get(ApiEndpoints.weeklyMoodStats);
  }

  Future<Map<String, dynamic>> deleteMoodRecord(String id) {
    return _apiClient.delete('${ApiEndpoints.moods}/$id');
  }
}
