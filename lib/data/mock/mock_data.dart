import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String route;
}

class MoodWeekItem {
  const MoodWeekItem({required this.day, required this.icon, required this.color});

  final String day;
  final IconData icon;
  final Color color;
}

class EmotionOption {
  const EmotionOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final int id;
  final String name;
  final IconData icon;
  final Color color;
}

class MockData {
  static const quickActions = [
    QuickActionItem(
      title: 'Registro Emocional',
      icon: Icons.favorite_rounded,
      color: AppColors.pink,
      route: '/mood-log',
    ),
    QuickActionItem(
      title: 'Triaje',
      icon: Icons.psychology_rounded,
      color: AppColors.purple,
      route: '/triage',
    ),
    QuickActionItem(
      title: 'Artículos',
      icon: Icons.menu_book_rounded,
      color: AppColors.primary,
      route: '/articles',
    ),
    QuickActionItem(
      title: 'Recordatorios',
      icon: Icons.notifications_rounded,
      color: AppColors.orange,
      route: '/reminders',
    ),
  ];

  static const weekMoods = [
    MoodWeekItem(day: 'Lun', icon: Icons.sentiment_satisfied_alt_rounded, color: AppColors.green),
    MoodWeekItem(day: 'Mar', icon: Icons.sentiment_neutral_rounded, color: AppColors.yellow),
    MoodWeekItem(day: 'Mié', icon: Icons.sentiment_satisfied_alt_rounded, color: AppColors.green),
    MoodWeekItem(day: 'Jue', icon: Icons.sentiment_dissatisfied_rounded, color: AppColors.red),
    MoodWeekItem(day: 'Vie', icon: Icons.sentiment_neutral_rounded, color: AppColors.yellow),
    MoodWeekItem(day: 'Sáb', icon: Icons.sentiment_satisfied_alt_rounded, color: AppColors.green),
    MoodWeekItem(day: 'Dom', icon: Icons.sentiment_satisfied_alt_rounded, color: AppColors.green),
  ];

  static const emotions = [
    EmotionOption(id: 1, name: 'Muy feliz', icon: Icons.sentiment_very_satisfied_rounded, color: AppColors.green),
    EmotionOption(id: 2, name: 'Feliz', icon: Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF4ADE80)),
    EmotionOption(id: 3, name: 'Tranquilo', icon: Icons.spa_rounded, color: AppColors.primary),
    EmotionOption(id: 4, name: 'Ansioso', icon: Icons.sentiment_neutral_rounded, color: AppColors.yellow),
    EmotionOption(id: 5, name: 'Triste', icon: Icons.sentiment_dissatisfied_rounded, color: AppColors.orange),
    EmotionOption(id: 6, name: 'Estresado', icon: Icons.bolt_rounded, color: AppColors.purple),
    EmotionOption(id: 7, name: 'Cansado', icon: Icons.bedtime_rounded, color: AppColors.red),
  ];

  static const activities = [
    'Ansiedad',
    'Estrés académico',
    'Sueño',
    'Familia',
    'Relaciones',
    'Parciales',
    'Trabajo',
    'Soledad',
    'Cansancio',
    'Motivación',
  ];
}

class EmotionalHistoryItem {
  const EmotionalHistoryItem({
    required this.date,
    required this.dayLabel,
    required this.mood,
    required this.level,
    required this.activities,
    required this.note,
    required this.icon,
    required this.color,
  });

  final String date;
  final String dayLabel;
  final String mood;
  final int level;
  final List<String> activities;
  final String note;
  final IconData icon;
  final Color color;
}

class TriageQuestion {
  const TriageQuestion({required this.question, required this.options});

  final String question;
  final List<TriageOption> options;
}

class TriageOption {
  const TriageOption({required this.text, required this.score});

  final String text;
  final int score;
}

class ArticleItem {
  const ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.description,
    required this.content,
    required this.icon,
    required this.color,
  });

  final int id;
  final String title;
  final String category;
  final String readTime;
  final String description;
  final String content;
  final IconData icon;
  final Color color;
}

class ReminderItem {
  const ReminderItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.days,
    required this.icon,
    required this.color,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final String time;
  final String days;
  final IconData icon;
  final Color color;
  final bool enabled;
}

class MoreMockData {
  static const historyItems = [
    EmotionalHistoryItem(
      date: '18 mayo 2026',
      dayLabel: 'Hoy',
      mood: 'Ansioso',
      level: 3,
      activities: ['Estudios', 'Trabajo', 'Descanso'],
      note: 'Semana de parciales, pero pude organizar mis pendientes.',
      icon: Icons.sentiment_neutral_rounded,
      color: AppColors.yellow,
    ),
    EmotionalHistoryItem(
      date: '17 mayo 2026',
      dayLabel: 'Ayer',
      mood: 'Feliz',
      level: 4,
      activities: ['Amigos', 'Ejercicio'],
      note: 'Me sentí acompañado y con buena energía durante el día.',
      icon: Icons.sentiment_satisfied_alt_rounded,
      color: AppColors.green,
    ),
    EmotionalHistoryItem(
      date: '16 mayo 2026',
      dayLabel: 'Sábado',
      mood: 'Triste',
      level: 2,
      activities: ['Familia', 'Lectura'],
      note: 'Día tranquilo, con momentos de cansancio emocional.',
      icon: Icons.sentiment_dissatisfied_rounded,
      color: AppColors.orange,
    ),
    EmotionalHistoryItem(
      date: '15 mayo 2026',
      dayLabel: 'Viernes',
      mood: 'Muy feliz',
      level: 5,
      activities: ['Hobbies', 'Naturaleza'],
      note: 'Pude descansar y hacer actividades que me gustan.',
      icon: Icons.sentiment_very_satisfied_rounded,
      color: AppColors.green,
    ),
  ];

  static const triageQuestions = [
    TriageQuestion(
      question: 'Durante los últimos días, ¿con qué frecuencia te has sentido con ansiedad o preocupación excesiva?',
      options: [
        TriageOption(text: 'Nunca', score: 0),
        TriageOption(text: 'Algunos días', score: 1),
        TriageOption(text: 'Más de la mitad de los días', score: 2),
        TriageOption(text: 'Casi todos los días', score: 3),
      ],
    ),
    TriageQuestion(
      question: '¿Has tenido dificultad para dormir, descansar o mantener una rutina de sueño?',
      options: [
        TriageOption(text: 'No he tenido dificultad', score: 0),
        TriageOption(text: 'Un poco', score: 1),
        TriageOption(text: 'Con frecuencia', score: 2),
        TriageOption(text: 'Casi siempre', score: 3),
      ],
    ),
    TriageQuestion(
      question: '¿Has perdido interés en actividades que antes disfrutabas?',
      options: [
        TriageOption(text: 'No', score: 0),
        TriageOption(text: 'Levemente', score: 1),
        TriageOption(text: 'Bastante', score: 2),
        TriageOption(text: 'Mucho', score: 3),
      ],
    ),
    TriageQuestion(
      question: '¿Qué tanto han afectado tus emociones tu rendimiento académico o tus relaciones?',
      options: [
        TriageOption(text: 'Nada', score: 0),
        TriageOption(text: 'Poco', score: 1),
        TriageOption(text: 'Moderadamente', score: 2),
        TriageOption(text: 'Mucho', score: 3),
      ],
    ),
    TriageQuestion(
      question: '¿Sientes que necesitas apoyo profesional para manejar lo que estás viviendo?',
      options: [
        TriageOption(text: 'No lo considero necesario', score: 0),
        TriageOption(text: 'Tal vez', score: 1),
        TriageOption(text: 'Sí, me gustaría orientación', score: 2),
        TriageOption(text: 'Sí, lo necesito pronto', score: 3),
      ],
    ),
  ];

  static const articles = [
    ArticleItem(
      id: 1,
      title: 'Manejo de la ansiedad en época de parciales',
      category: 'Ansiedad',
      readTime: '5 min',
      description: 'Estrategias prácticas para regular la ansiedad antes y durante evaluaciones académicas.',
      content: 'La ansiedad académica puede aparecer cuando una persona percibe que las demandas superan sus recursos. Para manejarla, es útil dividir las tareas, priorizar el descanso, practicar respiración lenta y pedir apoyo cuando los síntomas afectan la vida diaria.\n\nAntes de un parcial, prepara un plan realista de estudio con pausas. Durante el examen, identifica pensamientos catastróficos y reemplázalos por instrucciones concretas: lee, respira, responde una pregunta a la vez.\n\nSi la ansiedad se vuelve frecuente, intensa o interfiere con tus actividades, busca orientación profesional en los canales de bienestar universitario.',
      icon: Icons.psychology_rounded,
      color: AppColors.purple,
    ),
    ArticleItem(
      id: 2,
      title: 'Rutinas de sueño para estudiantes universitarios',
      category: 'Sueño',
      readTime: '4 min',
      description: 'Consejos para mejorar el descanso y sostener energía durante la semana.',
      content: 'El sueño influye en la memoria, la atención y el estado emocional. Una rutina estable ayuda a que el cuerpo anticipe los momentos de descanso y actividad.\n\nProcura dormir y despertar en horarios similares, reducir pantallas antes de acostarte y evitar estudiar en la cama. Si tienes muchas tareas, organiza bloques breves en lugar de extenderte hasta la madrugada.\n\nUn descanso adecuado no es pérdida de tiempo: es una condición para aprender mejor.',
      icon: Icons.nightlight_round,
      color: AppColors.primary,
    ),
    ArticleItem(
      id: 3,
      title: 'Señales para pedir ayuda a tiempo',
      category: 'Bienestar',
      readTime: '6 min',
      description: 'Reconoce cuándo una emoción requiere acompañamiento profesional.',
      content: 'Pedir ayuda es una decisión responsable. Algunas señales de alerta son: aislamiento persistente, llanto frecuente, dificultad para cumplir tareas básicas, cambios fuertes en sueño o apetito, sensación de desesperanza o pensamientos de hacerse daño.\n\nHablar con alguien de confianza puede ser el primer paso. También es importante acudir a servicios de orientación psicológica cuando el malestar se mantiene o aumenta.\n\nInMotions busca apoyar el seguimiento emocional, pero no reemplaza una atención profesional.',
      icon: Icons.favorite_rounded,
      color: AppColors.pink,
    ),
    ArticleItem(
      id: 4,
      title: 'Respiración consciente en tres minutos',
      category: 'Autocuidado',
      readTime: '3 min',
      description: 'Una práctica breve para recuperar calma durante el día.',
      content: 'Busca una posición cómoda. Inhala lentamente contando hasta cuatro, sostén el aire dos segundos y exhala contando hasta seis. Repite durante tres minutos.\n\nMientras respiras, intenta observar tus pensamientos sin pelear con ellos. La meta no es dejar la mente en blanco, sino volver al presente con amabilidad.\n\nPuedes usar esta práctica antes de estudiar, dormir o entrar a una evaluación.',
      icon: Icons.self_improvement_rounded,
      color: AppColors.green,
    ),
  ];

  static const reminders = [
    ReminderItem(
      title: 'Registro emocional',
      subtitle: 'Anotar cómo te sentiste hoy',
      time: '8:00 PM',
      days: 'Todos los días',
      icon: Icons.favorite_rounded,
      color: AppColors.pink,
      enabled: true,
    ),
    ReminderItem(
      title: 'Meditación breve',
      subtitle: 'Respiración consciente de 3 minutos',
      time: '7:30 AM',
      days: 'Lun, Mié, Vie',
      icon: Icons.self_improvement_rounded,
      color: AppColors.purple,
      enabled: true,
    ),
    ReminderItem(
      title: 'Hora de dormir',
      subtitle: 'Preparar descanso y desconexión',
      time: '10:30 PM',
      days: 'Dom - Jue',
      icon: Icons.nightlight_round,
      color: AppColors.primary,
      enabled: false,
    ),
  ];
}
