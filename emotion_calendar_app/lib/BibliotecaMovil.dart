import 'package:flutter/material.dart';

class BibliotecaMovil extends StatelessWidget {
  final List<String> _techniques = [
    'Respiración diafragmática',
    'Escaneo corporal',
    'Técnica 5-4-3-2-1',
    'Meditación de atención plena',
    'Diario emocional',
    'Visualización positiva',
    'Ejercicio físico regular',
    'Técnica de relajación muscular progresiva',
    'Práctica de gratitud',
    'Técnica de reencuadre cognitivo',
  ];

  final List<String> _techniqueDescriptions = [
    'Siéntate o acuéstate cómodamente, coloca una mano en el pecho y otra en el abdomen. Inhala lentamente por la nariz, expandiendo el abdomen. Exhala lentamente por la boca, contrayendo el abdomen. Repite 5-10 veces.',
    'Acuéstate en una posición cómoda, cierra los ojos y respira profundamente. Enfócate en cada parte de tu cuerpo, empezando por los pies. Nota cualquier tensión y libérala conscientemente. Avanza gradualmente hacia la cabeza.',
    'Nombra 5 cosas que puedes ver, 4 cosas que puedes tocar, 3 cosas que puedes oír, 2 cosas que puedes oler, 1 cosa que puedes saborear.',
    'Siéntate en una posición cómoda. Enfócate en tu respiración. Observa tus pensamientos sin juzgarlos. Si te distraes, vuelve gentilmente a tu respiración.',
    'Escribe diariamente sobre tus emociones. Identifica qué las provocó. Reflexiona sobre cómo reaccionaste. Establece metas para manejar mejor tus emociones.',
    'Cierra los ojos y respira profundamente. Imagina un lugar tranquilo y seguro. Usa todos tus sentidos para hacerlo más real. Quédate en ese lugar por 5-10 minutos.',
    'Elige una actividad que disfrutes (caminar, nadar, bailar). Establece un horario regular. Comienza con sesiones cortas y aumenta gradualmente. Presta atención a cómo te sientes durante y después.',
    'Acuéstate o siéntate cómodamente. Comienza por los pies, tensando los músculos por 5 segundos. Relaja los músculos completamente por 10 segundos. Avanza hacia arriba por todo el cuerpo, grupo muscular por grupo muscular.',
    'Cada noche, escribe 3 cosas por las que estés agradecido. Reflexiona sobre por qué estás agradecido por cada una. Incluye cosas pequeñas y grandes.',
    'Identifica un pensamiento negativo recurrente. Cuestiona la validez de este pensamiento. Busca evidencia que lo contradiga. Crea una interpretación alternativa más positiva o realista.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biblioteca de Técnicas'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.blue[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _techniques.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.green[400],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    _techniques[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.brown[50],
                        title: Text(
                          'Pasos a Seguir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(_techniqueDescriptions[index]),
                        actions: [
                          TextButton(
                            child: Text(
                              'Cerrar',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
