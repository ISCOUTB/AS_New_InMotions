import 'package:shared_preferences/shared_preferences.dart';

class LocalResourceStorage {
  static const String _favoritesKey = 'as_new_inmotions.favorite_resource_ids';
  static const String _redAccessAcknowledgedKey = 'as_new_inmotions.red_resource_access_acknowledged';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []).toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList()..sort());
  }

  Future<bool> isFavorite(String resourceId) async {
    final ids = await getFavoriteIds();
    return ids.contains(resourceId);
  }

  Future<bool> toggleFavorite(String resourceId) async {
    final ids = await getFavoriteIds();
    final isNowFavorite = !ids.contains(resourceId);
    if (isNowFavorite) {
      ids.add(resourceId);
    } else {
      ids.remove(resourceId);
    }
    await saveFavoriteIds(ids);
    return isNowFavorite;
  }

  Future<bool> hasAcknowledgedRedAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_redAccessAcknowledgedKey) ?? false;
  }

  Future<void> acknowledgeRedAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_redAccessAcknowledgedKey, true);
  }
}
