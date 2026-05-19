import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalSessionStorage {
  static const String _tokenKey = 'as_new_inmotions_auth_token';
  static const String _currentUserKey = 'as_new_inmotions_current_user';
  static const String _registeredUserKey = 'as_new_inmotions_registered_user';
  static const String _registeredPasswordKey = 'as_new_inmotions_registered_password';
  static const String _profileImagesByEmailKey = 'as_new_inmotions_profile_images_by_email';

  Future<void> saveSession({required String token, required UserModel user}) async {
    final prefs = await SharedPreferences.getInstance();
    final profileImagePath = user.profileImagePath ?? await getProfileImagePathByEmail(user.email);
    final userWithImage = profileImagePath == null ? user : user.copyWith(profileImagePath: profileImagePath);

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_currentUserKey, jsonEncode(userWithImage.toMap()));
  }

  Future<void> updateCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));

    if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
      await saveProfileImagePathByEmail(email: user.email, imagePath: user.profileImagePath!);
    }

    final registeredUser = await getRegisteredUser();
    if (registeredUser != null && registeredUser.email.toLowerCase() == user.email.toLowerCase()) {
      await prefs.setString(_registeredUserKey, jsonEncode(user.toMap()));
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_currentUserKey);
    if (rawUser == null) return null;

    try {
      final user = UserModel.fromMap(jsonDecode(rawUser) as Map<String, dynamic>);
      final profileImagePath = user.profileImagePath ?? await getProfileImagePathByEmail(user.email);
      return profileImagePath == null ? user : user.copyWith(profileImagePath: profileImagePath);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getCurrentUser();
    return token != null && user != null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_currentUserKey);
  }

  Future<void> saveRegisteredUser({required UserModel user, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredUserKey, jsonEncode(user.toMap()));

    // Solo para simulación local. En backend real, la contraseña debe guardarse cifrada con hash.
    await prefs.setString(_registeredPasswordKey, password);
  }

  Future<UserModel?> getRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_registeredUserKey);
    if (rawUser == null) return null;

    try {
      final user = UserModel.fromMap(jsonDecode(rawUser) as Map<String, dynamic>);
      final profileImagePath = user.profileImagePath ?? await getProfileImagePathByEmail(user.email);
      return profileImagePath == null ? user : user.copyWith(profileImagePath: profileImagePath);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRegisteredPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registeredPasswordKey);
  }

  Future<void> saveProfileImagePathByEmail({required String email, required String imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _getProfileImagesMap();
    map[email.trim().toLowerCase()] = imagePath;
    await prefs.setString(_profileImagesByEmailKey, jsonEncode(map));
  }

  Future<String?> getProfileImagePathByEmail(String email) async {
    final map = await _getProfileImagesMap();
    return map[email.trim().toLowerCase()];
  }

  Future<Map<String, String>> _getProfileImagesMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileImagesByEmailKey);
    if (raw == null) return <String, String>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return <String, String>{};
    }
  }
}
