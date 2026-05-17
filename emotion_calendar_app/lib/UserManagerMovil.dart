import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class UserManagerMovil {
  static late File _userFile;

  // Inicializa el archivo de usuarios, asegurándose de que se ha llamado antes de cualquier operación
  static Future<void> initializeUsers() async {
    final directory = await getApplicationDocumentsDirectory();
    _userFile = File('${directory.path}/users.json');
    if (!_userFile.existsSync()) {
      await _userFile
          .writeAsString(jsonEncode([])); // Si no existe, crea el archivo vacío
    }
  }

  // Login de usuario: Verifica si las credenciales son correctas
  static Future<bool> login(String email, String password) async {
    // Asegurarse de que los usuarios se inicialicen primero
    await initializeUsers();

    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {}, // Devuelve un mapa vacío si no se encuentra el usuario
    );

    return user.isNotEmpty; // Si el mapa no está vacío, el usuario se encontró
  }

  // Registro de un nuevo usuario
  static Future<bool> register(String email, String password) async {
    // Asegurarse de que los usuarios se inicialicen primero
    await initializeUsers();

    final users = await _getUsers();
    if (users.any((user) => user['email'] == email)) {
      return false; // Ya existe un usuario con ese email
    }

    users.add({'email': email, 'password': password, 'emotions': []});
    await _saveUsers(users);
    return true;
  }

  // Obtener las emociones de un usuario
  static Future<List<Map<String, dynamic>>> getEmotions(String email) async {
    // Asegurarse de que los usuarios se inicialicen primero
    await initializeUsers();

    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {}, // Devuelve un mapa vacío si no se encuentra el usuario
    );

    if (user.isNotEmpty && user.containsKey('emotions')) {
      return List<Map<String, dynamic>>.from(user['emotions']);
    }
    return [];
  }

  // Añadir una emoción a un usuario
  static Future<void> addEmotion(
      String email, DateTime date, String emotion, String note) async {
    // Asegurarse de que los usuarios se inicialicen primero
    await initializeUsers();

    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {}, // Devuelve un mapa vacío si no se encuentra el usuario
    );

    if (user.isNotEmpty) {
      user['emotions'] =
          user['emotions'] ?? []; // Inicializa la lista si no existe
      user['emotions'].add({
        'date': date.toIso8601String(),
        'emotion': emotion,
        'note': note,
      });
      await _saveUsers(users);
    }
  }

  // Eliminar una emoción por fecha
  static Future<void> deleteEmotion(String email, DateTime date) async {
    // Asegurarse de que los usuarios se inicialicen primero
    await initializeUsers();

    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {}, // Devuelve un mapa vacío si no se encuentra el usuario
    );

    if (user.isNotEmpty) {
      user['emotions'] = user['emotions'] ?? [];
      user['emotions'].removeWhere(
          (emotion) => DateTime.parse(emotion['date']).isAtSameMomentAs(date));
      await _saveUsers(users);
    }
  }

  // Obtener todos los usuarios (internamente)
  static Future<List<Map<String, dynamic>>> _getUsers() async {
    final fileContents = await _userFile.readAsString();
    final List<dynamic> jsonData = jsonDecode(fileContents);
    return List<Map<String, dynamic>>.from(jsonData);
  }

  // Guardar los datos de los usuarios en el archivo
  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final String jsonString = jsonEncode(users);
    await _userFile.writeAsString(jsonString);
  }
}
