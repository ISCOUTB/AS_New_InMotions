import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'user_data_manager.dart';
import 'package:intl/intl.dart';
import 'emotion_list_page.dart';

class EmotionCalendarPage extends StatefulWidget {
  final String userEmail;

  EmotionCalendarPage({required this.userEmail});

  @override
  _EmotionCalendarPageState createState() => _EmotionCalendarPageState();
}

class _EmotionCalendarPageState extends State<EmotionCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedEmotion = '';
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario de Emociones'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () {
              Navigator.pushNamed(context, '/instructions');
            },
          ),
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmotionListPage(userEmail: widget.userEmail),
                ),
              );
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TableCalendar(
                          focusedDay: DateTime.now(),
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2100),
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            selectedDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 213, 186, 152),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: UserManager.getEmotions(widget.userEmail),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error al cargar las emociones',
                                      style: TextStyle(color: Colors.white)));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text('No hay emociones guardadas',
                                      style: TextStyle(color: Colors.white)));
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final emotion = snapshot.data![index];
                                  final dateTime =
                                      DateTime.parse(emotion['date']);
                                  final formattedDate =
                                      DateFormat('dd/MM/yyyy').format(dateTime);
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
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Escribe una nota',
                                hintStyle: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emociones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            _emotionButton('😊', 'Feliz'),
                            _emotionButton('😐', 'Neutral'),
                            _emotionButton('😔', 'Decaído'),
                            _emotionButton('😢', 'Triste'),
                            _emotionButton('😠', 'Enojado'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedEmotion.isEmpty ||
                              _noteController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Por favor, selecciona una emoción y escribe una nota.')),
                            );
                            return;
                          }

                          await UserManager.saveEmotion(
                            widget.userEmail,
                            _selectedEmotion,
                            _noteController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Emoción guardada')),
                          );
                          _noteController.clear();
                          setState(() {
                            _selectedEmotion =
                                ''; // Limpiamos la emoción seleccionada
                          });
                        },
                        child: Text('Guardar emociones'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emotionButton(String emoji, String emotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedEmotion = emotion;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedEmotion == emotion
              ? Color.fromARGB(255, 213, 186, 152)
              : Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(emotion, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
