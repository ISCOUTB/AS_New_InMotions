import 'package:flutter/material.dart';
import 'user_data_manager.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class EmotionListPage extends StatelessWidget {
  final String userEmail;

  EmotionListPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Emociones'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () {
              Navigator.pushNamed(context, '/instructions');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F3F),
              Color(0xFF003366),
            ],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: UserManager.getEmotions(userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las emociones',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay emociones guardadas',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final emotion = snapshot.data![index];
                  final dateTime = DateTime.parse(emotion['date']);
                  final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                  return ListTile(
                    title: Text(
                      '$formattedDate - ${emotion['emotion']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${emotion['note']}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
