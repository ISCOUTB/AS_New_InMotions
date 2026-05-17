import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserManager {
  static const String _usersKey = 'users';

  // Registrar un nuevo usuario
  static Future<bool> registerUser(
      String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String users = prefs.getString(_usersKey) ?? '';

      // Verificar si el usuario o el correo ya existe
      if (users.contains(email) || users.contains(name)) {
        return false; // Usuario o correo ya existe
      }

      users += '$email:$password:$name\n';
      await prefs.setString(_usersKey, users);
      print('Usuario registrado: $email:$password:$name');
      return true;
    } catch (e) {
      print('Error registrando usuario: $e');
      return false;
    }
  }

  // Iniciar sesión con correo o nombre de usuario
  static Future<bool> loginUser(String identifier, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String users = prefs.getString(_usersKey) ?? '';
      List<String> userList = users.split('\n');
      for (var user in userList) {
        List<String> userData = user.split(':');
        if (userData.length >= 3 &&
            (userData[0] == identifier || userData[2] == identifier) &&
            userData[1] == password) {
          print('Inicio de sesión exitoso para $identifier');
          return true;
        }
      }
      print('Usuario no encontrado: $identifier');
      return false;
    } catch (e) {
      print('Error en el inicio de sesión: $e');
      return false;
    }
  }

  // Obtener detalles del usuario por correo o nombre de usuario
  static Future<Map<String, String>?> getUserDetails(String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String users = prefs.getString(_usersKey) ?? '';
      List<String> userList = users.split('\n');
      for (var user in userList) {
        List<String> userData = user.split(':');
        if (userData.length >= 3 &&
            (userData[0] == identifier || userData[2] == identifier)) {
          return {
            'email': userData[0],
            'name': userData[2],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalles del usuario: $e');
      return null;
    }
  }

  // Actualizar los detalles del usuario
  static Future<bool> updateUserDetails(
      String identifier, String newName, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String users = prefs.getString(_usersKey) ?? '';
      List<String> userList = users.split('\n');
      for (int i = 0; i < userList.length; i++) {
        List<String> userData = userList[i].split(':');
        if (userData.length >= 3 &&
            (userData[0] == identifier || userData[2] == identifier)) {
          userList[i] = '${userData[0]}:$newPassword:$newName';
          String updatedUsers = userList.join('\n');
          await prefs.setString(_usersKey, updatedUsers);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error actualizando detalles del usuario: $e');
      return false;
    }
  }

  // Eliminar usuario
  static Future<bool> deleteUser(String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String users = prefs.getString(_usersKey) ?? '';
      List<String> userList = users.split('\n');
      userList.removeWhere((user) =>
          user.split(':')[0] == identifier || user.split(':')[2] == identifier);
      String updatedUsers = userList.join('\n');
      await prefs.setString(_usersKey, updatedUsers);
      return true;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }

  // Guardar emoción para un usuario específico
  static Future<void> saveEmotion(
      String identifier, String emotion, String note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userEmotions = prefs.getString(identifier) ?? '[]';
      List<Map<String, dynamic>> emotionList =
          List<Map<String, dynamic>>.from(json.decode(userEmotions));

      emotionList.add({
        'emotion': emotion,
        'note': note,
        'date': DateTime.now().toIso8601String(),
      });

      await prefs.setString(identifier, json.encode(emotionList));
    } catch (e) {
      print('Error guardando emoción: $e');
    }
  }

  // Obtener emociones para un usuario específico
  static Future<List<Map<String, dynamic>>> getEmotions(
      String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userEmotions = prefs.getString(identifier) ?? '[]';
      List<Map<String, dynamic>> emotionList =
          List<Map<String, dynamic>>.from(json.decode(userEmotions));

      return emotionList;
    } catch (e) {
      print('Error obteniendo emociones: $e');
      return [];
    }
  }
}
