import 'package:flutter/material.dart';

class BibliotecaArchivos extends StatefulWidget {
  @override
  _BibliotecaArchivosState createState() => _BibliotecaArchivosState();
}

class _BibliotecaArchivosState extends State<BibliotecaArchivos> {
  List<Map<String, String>> archivos = [
    {
      "nombre": "Respiración diafragmática",
      "contenido":
          "1. Respiración diafragmática\n1.1. Siéntate o acuéstate cómodamente\n1.2. Coloca una mano en el pecho y otra en el abdomen\n1.3. Inhala lentamente por la nariz, expandiendo el abdomen\n1.4. Exhala lentamente por la boca, contrayendo el abdomen\n1.5. Repite 5-10 veces"
    },
    {
      "nombre": "Escaneo corporal",
      "contenido":
          "2. Escaneo corporal\n2.1. Acuéstate en una posición cómoda\n2.2. Cierra los ojos y respira profundamente\n2.3. Enfócate en cada parte de tu cuerpo, empezando por los pies\n2.4. Nota cualquier tensión y libérala conscientemente\n2.5. Avanza gradualmente hacia la cabeza"
    },
    {
      "nombre": "Técnica 5-4-3-2-1",
      "contenido":
          "3. Técnica 5-4-3-2-1\n3.1. Nombra 5 cosas que puedes ver\n3.2. Nombra 4 cosas que puedes tocar\n3.3. Nombra 3 cosas que puedes oír\n3.4. Nombra 2 cosas que puedes oler\n3.5. Nombra 1 cosa que puedes saborear"
    },
    {
      "nombre": "Meditación de atención plena",
      "contenido":
          "4. Meditación de atención plena\n4.1. Siéntate en una posición cómoda\n4.2. Enfócate en tu respiración\n4.3. Observa tus pensamientos sin juzgarlos\n4.4. Si te distraes, vuelve gentilmente a tu respiración\n4.5. Practica por 5-10 minutos diariamente"
    },
    {
      "nombre": "Diario emocional",
      "contenido":
          "5. Diario emocional\n5.1. Escribe diariamente sobre tus emociones\n5.2. Identifica qué las provocó\n5.3. Reflexiona sobre cómo reaccionaste\n5.4. Piensa en formas alternativas de responder\n5.5. Establece metas para manejar mejor tus emociones"
    },
    {
      "nombre": "Visualización positiva",
      "contenido":
          "6. Visualización positiva\n6.1. Cierra los ojos y respira profundamente\n6.2. Imagina un lugar tranquilo y seguro\n6.3. Usa todos tus sentidos para hacerlo más real\n6.4. Quédate en ese lugar por 5-10 minutos\n6.5. Abre los ojos lentamente"
    },
    {
      "nombre": "Ejercicio físico regular",
      "contenido":
          "7. Ejercicio físico regular\n7.1. Elige una actividad que disfrutes (caminar, nadar, bailar)\n7.2. Establece un horario regular\n7.3. Comienza con sesiones cortas y aumenta gradualmente\n7.4. Presta atención a cómo te sientes durante y después\n7.5. Usa este tiempo para despejar tu mente"
    },
    {
      "nombre": "Técnica de relajación muscular progresiva",
      "contenido":
          "8. Técnica de relajación muscular progresiva\n8.1. Acuéstate o siéntate cómodamente\n8.2. Comienza por los pies, tensando los músculos por 5 segundos\n8.3. Relaja los músculos completamente por 10 segundos\n8.4. Avanza hacia arriba por todo el cuerpo, grupo muscular por grupo muscular\n8.5. Nota la diferencia entre tensión y relajación"
    },
    {
      "nombre": "Práctica de gratitud",
      "contenido":
          "9. Práctica de gratitud\n9.1. Cada noche, escribe 3 cosas por las que estés agradecido\n9.2. Reflexiona sobre por qué estás agradecido por cada una\n9.3. Incluye cosas pequeñas y grandes\n9.4. Trata de no repetir elementos durante al menos una semana\n9.5. Observa cómo esto afecta tu estado de ánimo general"
    },
    {
      "nombre": "Técnica de reencuadre cognitivo",
      "contenido":
          "10. Técnica de reencuadre cognitivo\n10.1. Identifica un pensamiento negativo recurrente\n10.2. Cuestiona la validez de este pensamiento\n10.3. Busca evidencia que lo contradiga\n10.4. Crea una interpretación alternativa más positiva o realista\n10.5. Practica reemplazar el pensamiento negativo con el nuevo cuando surja"
    },
  ];

  String contenidoSeleccionado =
      "Selecciona un ejercicio para ver su paso a paso.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001F3F), Color(0xFF003366)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Biblioteca de Archivos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Archivos Disponibles',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: archivos.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        contenidoSeleccionado =
                                            archivos[index]["contenido"]!;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 16),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        archivos[index]["nombre"]!,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 11, 78, 133), // Fondo negro original
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                                255, 216, 202, 169), // Color beige
                          ),
                          padding: EdgeInsets.all(16), // Espaciado interno
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pasos a Seguir',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Cambia el color a negro
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    contenidoSeleccionado,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0,
                                          0), // Cambia el color a negro
                                      fontSize:
                                          28, // Aumenta el tamaño de la fuente
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
