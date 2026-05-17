import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'UserManagerMovil.dart';
import 'EmotionListMovil.dart';
import 'BibliotecaMovil.dart';

class CalendarPageMovil extends StatefulWidget {
  final String userEmail;
  CalendarPageMovil({required this.userEmail});

  @override
  _CalendarPageMovilState createState() => _CalendarPageMovilState();
}

class _CalendarPageMovilState extends State<CalendarPageMovil> {
  late DateTime _selectedDay;
  DateTime _focusedDay = DateTime.now();
  TextEditingController _emotionController = TextEditingController();
  String _selectedEmotion = 'Feliz';

  final List<String> _emotions = [
    'Feliz',
    'Neutral',
    'Decaído',
    'Triste',
    'Enojado'
  ];

  final Map<String, IconData> _emotionIcons = {
    'Feliz': Icons.sentiment_very_satisfied,
    'Neutral': Icons.sentiment_neutral,
    'Decaído': Icons.sentiment_dissatisfied,
    'Triste': Icons.sentiment_very_dissatisfied,
    'Enojado': Icons.mood_bad,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _addEmotion() async {
    if (_emotionController.text.isNotEmpty) {
      await UserManagerMovil.addEmotion(
        widget.userEmail,
        _selectedDay,
        _selectedEmotion,
        _emotionController.text,
      );
      _emotionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Nota agregada'),
        backgroundColor: Colors.blue[700],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E), // Dark blue background
      appBar: AppBar(
        title: Text('Calendario de emociones'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmotionListMovil(userEmail: widget.userEmail),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BibliotecaMovil(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 01, 01),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue[300],
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emociones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          value: _selectedEmotion,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          items: _emotions.map((String emotion) {
                            return DropdownMenuItem<String>(
                              value: emotion,
                              child: Row(
                                children: [
                                  Icon(_emotionIcons[emotion], 
                                       color: Colors.grey[600]),
                                  SizedBox(width: 10),
                                  Text(emotion),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedEmotion = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nota',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emotionController,
                        decoration: InputDecoration(
                          hintText: 'Agregar una nota',
                          border: OutlineInputBorder(),
                          fillColor: Colors.grey[100],
                          filled: true,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _addEmotion,
                          child: Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}