import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GestorEjercicios {
  static const String _clave_ejercicios = 'ejercicios';

  // Guardar un ejercicio
  static Future<bool> guardarEjercicio(
      String email, String nombre, String descripcion, int duracion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String ejerciciosJson = prefs.getString(_clave_ejercicios) ?? '[]';
      List<Map<String, dynamic>> listaEjercicios =
          List<Map<String, dynamic>>.from(json.decode(ejerciciosJson));

      listaEjercicios.add({
        'email': email,
        'nombre': nombre,
        'descripcion': descripcion,
        'duracion': duracion,
        'fecha': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_clave_ejercicios, json.encode(listaEjercicios));
      return true;
    } catch (e) {
      print('Error al guardar el ejercicio: $e');
      return false;
    }
  }

  // Obtener ejercicios
  static Future<List<Map<String, dynamic>>> obtenerEjercicios(
      String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String ejerciciosJson = prefs.getString(_clave_ejercicios) ?? '[]';
      List<Map<String, dynamic>> listaEjercicios =
          List<Map<String, dynamic>>.from(json.decode(ejerciciosJson));

      return listaEjercicios
          .where((ejercicio) => ejercicio['email'] == email)
          .toList();
    } catch (e) {
      print('Error al obtener los ejercicios: $e');
      return [];
    }
  }

  // Eliminar un ejercicio
  static Future<bool> eliminarEjercicio(
      String email, String nombre, String fecha) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String ejerciciosJson = prefs.getString(_clave_ejercicios) ?? '[]';
      List<Map<String, dynamic>> listaEjercicios =
          List<Map<String, dynamic>>.from(json.decode(ejerciciosJson));

      listaEjercicios.removeWhere((ejercicio) =>
          ejercicio['email'] == email &&
          ejercicio['nombre'] == nombre &&
          ejercicio['fecha'] == fecha);

      await prefs.setString(_clave_ejercicios, json.encode(listaEjercicios));
      return true;
    } catch (e) {
      print('Error al eliminar el ejercicio: $e');
      return false;
    }
  }
}
