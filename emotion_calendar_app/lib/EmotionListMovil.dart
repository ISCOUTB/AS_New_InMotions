import 'package:flutter/material.dart';
import 'UserManagerMovil.dart';
import 'package:intl/intl.dart'; // Necesario para el formato de fechas

class EmotionListMovil extends StatefulWidget {
  final String userEmail;
  EmotionListMovil({required this.userEmail});

  @override
  _EmotionListMovilState createState() => _EmotionListMovilState();
}

class _EmotionListMovilState extends State<EmotionListMovil> {
  List<Map<String, dynamic>> _emotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    try {
      _emotions = await UserManagerMovil.getEmotions(widget.userEmail);
    } catch (e) {
      print('Error al cargar las emociones: $e');
      _emotions = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      // Convierte la cadena a un objeto DateTime
      DateTime date = DateTime.parse(dateString);
      // Formatea la fecha en "MMM dd, HH:mm" (ejemplo: "Nov 13, 14:30")
      return DateFormat('MMM dd, HH:mm').format(date);
    } catch (e) {
      print('Error formateando la fecha: $e');
      return dateString; // Devuelve la fecha sin formato si ocurre un error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Emociones'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.blue[900],
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _emotions.isEmpty
                ? Center(
                    child: Text(
                      'No hay emociones registradas.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEmotions,
                    child: ListView.builder(
                      itemCount: _emotions.length,
                      itemBuilder: (context, index) {
                        final emotion = _emotions[index];
                        return Card(
                          color: Colors.green[400],
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              emotion['emotion'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              emotion['note'] ?? '',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              _formatDate(emotion['date']), // Formatea la fecha aquí
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
