import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class TriageApiService {
  TriageApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getQuestions() {
    return _apiClient.get(ApiEndpoints.triageQuestions);
  }

  Future<Map<String, dynamic>> submitAnswers(List<Map<String, dynamic>> answers) {
    return _apiClient.post(
      ApiEndpoints.triageSubmit,
      body: {'answers': answers},
    );
  }

  Future<Map<String, dynamic>> getResults() {
    return _apiClient.get(ApiEndpoints.triageResults);
  }
}
