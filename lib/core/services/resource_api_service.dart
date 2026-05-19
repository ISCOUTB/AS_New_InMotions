import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class ResourceApiService {
  ResourceApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getResources({String? thematic, String? format, String? level, String? query}) {
    return _apiClient.get(
      ApiEndpoints.resources,
      queryParameters: {
        if (thematic != null && thematic.isNotEmpty) 'thematic': thematic,
        if (format != null && format.isNotEmpty) 'format': format,
        if (level != null && level.isNotEmpty) 'level': level,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
  }

  Future<Map<String, dynamic>> getResourceDetail(String id) {
    return _apiClient.get('${ApiEndpoints.resources}/$id');
  }

  Future<Map<String, dynamic>> getFavorites() {
    return _apiClient.get(ApiEndpoints.favoriteResources);
  }

  Future<Map<String, dynamic>> addFavorite(String id) {
    return _apiClient.post('${ApiEndpoints.resources}/$id/favorite');
  }

  Future<Map<String, dynamic>> removeFavorite(String id) {
    return _apiClient.delete('${ApiEndpoints.resources}/$id/favorite');
  }
}
