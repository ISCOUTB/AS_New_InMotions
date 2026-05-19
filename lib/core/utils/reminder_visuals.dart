import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ReminderVisuals {
  const ReminderVisuals._();

  static Color colorForType(String type) {
    switch (type) {
      case 'Registrar emoción':
        return AppColors.pink;
      case 'Pausa de respiración':
        return AppColors.purple;
      case 'Revisar recursos':
        return AppColors.primary;
      case 'Triaje mensual':
        return AppColors.orange;
      case 'Descanso activo':
        return AppColors.green;
      case 'Higiene del sueño':
        return AppColors.primaryDark;
      case 'Contactar apoyo':
        return AppColors.red;
      // Compatibilidad con recordatorios guardados de versiones anteriores.
      case 'Registro emocional':
        return AppColors.pink;
      case 'Triaje emocional':
        return AppColors.orange;
      case 'Lectura de artículo':
        return AppColors.primary;
      case 'Respiración consciente':
        return AppColors.purple;
      default:
        return AppColors.primary;
    }
  }

  static IconData iconForType(String type) {
    switch (type) {
      case 'Registrar emoción':
        return Icons.favorite_rounded;
      case 'Pausa de respiración':
        return Icons.self_improvement_rounded;
      case 'Revisar recursos':
        return Icons.menu_book_rounded;
      case 'Triaje mensual':
        return Icons.psychology_alt_rounded;
      case 'Descanso activo':
        return Icons.directions_walk_rounded;
      case 'Higiene del sueño':
        return Icons.bedtime_rounded;
      case 'Contactar apoyo':
        return Icons.support_agent_rounded;
      // Compatibilidad con recordatorios guardados de versiones anteriores.
      case 'Registro emocional':
        return Icons.favorite_rounded;
      case 'Triaje emocional':
        return Icons.psychology_alt_rounded;
      case 'Lectura de artículo':
        return Icons.menu_book_rounded;
      case 'Respiración consciente':
        return Icons.self_improvement_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  static String defaultSubtitleForType(String type) {
    switch (type) {
      case 'Registrar emoción':
        return 'Anotar cómo te sentiste hoy';
      case 'Pausa de respiración':
        return 'Tomar una pausa breve de 3 minutos';
      case 'Revisar recursos':
        return 'Explorar una guía de bienestar';
      case 'Triaje mensual':
        return 'Revisar tu bienestar emocional';
      case 'Descanso activo':
        return 'Levantarte, estirar y despejarte';
      case 'Higiene del sueño':
        return 'Prepararte para descansar mejor';
      case 'Contactar apoyo':
        return 'Recordar canales de apoyo institucional';
      // Compatibilidad con recordatorios guardados de versiones anteriores.
      case 'Registro emocional':
        return 'Anotar cómo te sentiste hoy';
      case 'Triaje emocional':
        return 'Revisar tu bienestar emocional';
      case 'Lectura de artículo':
        return 'Explorar un recurso de bienestar';
      case 'Respiración consciente':
        return 'Pausa breve de 3 minutos';
      default:
        return 'Cuidar tu bienestar emocional';
    }
  }
}
