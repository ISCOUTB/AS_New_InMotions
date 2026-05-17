import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de las versiones web
import 'register_page.dart';
import 'emotion_list_page.dart';
import 'login_page.dart';
import 'emotion_calendar_page.dart';
import 'biblioteca_archivos.dart';

// Importaciones de las versiones móvil
import 'RegisterMovil.dart';
import 'EmotionListMovil.dart';
import 'LoginMovil.dart';
import 'CalendarPageMovil.dart';
import 'BibliotecaMovil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _createTestUser();
  runApp(MyApp());
}

Future<void> _createTestUser() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('users')) {
    await prefs.setString('users', 'testuser:testpassword' + ':Test User\n');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienestar Mental',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Definimos un límite para considerar "móvil" (por ejemplo, 600 píxeles)
    const mobileWidthThreshold = 600;

    if (screenWidth < mobileWidthThreshold) {
      // Si es menor al límite, muestra el diseño móvil
      return MobileApp();
    } else {
      // Si es mayor o igual al límite, muestra el diseño web
      return WebApp();
    }
  }
}

// Aplicación web
class WebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienestar Mental',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/emotion_list': (context) =>
            EmotionListPage(userEmail: 'user@example.com'),
        '/calendar': (context) =>
            EmotionCalendarPage(userEmail: 'testuser@example.com'),
        '/instructions': (context) =>
            BibliotecaArchivos(), // Cambia la ruta a BibliotecaArchivos
      },
    );
  }
}

// Aplicación móvil
class MobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginMovil(),
        '/register': (context) => RegisterMovil(),
        '/calendar': (context) => CalendarPageMovil(userEmail: ''),
        '/biblioteca': (context) => BibliotecaMovil(),
        '/emotionList': (context) => EmotionListMovil(userEmail: ''),
      },
    );
  }
}
