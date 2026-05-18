import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class MoodVisuals {
  const MoodVisuals._();

  static IconData iconFor(String mood) {
    switch (mood.toLowerCase()) {
      case 'muy feliz':
        return Icons.sentiment_very_satisfied_rounded;
      case 'feliz':
      case 'tranquilo':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'ansioso':
      case 'estresado':
      case 'cansado':
        return Icons.sentiment_neutral_rounded;
      case 'triste':
      case 'muy triste':
        return Icons.sentiment_dissatisfied_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  static Color colorFor(String mood) {
    switch (mood.toLowerCase()) {
      case 'muy feliz':
      case 'feliz':
      case 'tranquilo':
        return AppColors.green;
      case 'ansioso':
      case 'estresado':
      case 'cansado':
        return AppColors.yellow;
      case 'triste':
        return AppColors.orange;
      case 'muy triste':
        return AppColors.red;
      default:
        return AppColors.primary;
    }
  }

  static String interpretationForLevel(int level) {
    if (level <= 2) return 'Intensidad baja';
    if (level == 3) return 'Intensidad moderada';
    return 'Intensidad alta';
  }
}
