import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ReminderVisuals {
  const ReminderVisuals._();

  static Color colorForType(String type) {
    switch (type) {
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
