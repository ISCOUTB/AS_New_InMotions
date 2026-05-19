import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ResourceVisuals {
  const ResourceVisuals._();

  static Color colorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'verde':
      case 'preventivo':
        return AppColors.green;
      case 'amarillo':
      case 'moderado':
        return AppColors.yellow;
      case 'naranja':
      case 'apoyo':
        return AppColors.orange;
      case 'rojo':
      case 'complementario':
        return AppColors.red;
      default:
        return AppColors.primary;
    }
  }

  static IconData iconForFormat(String format) {
    final normalized = format.toLowerCase();
    if (normalized.contains('audio') || normalized.contains('podcast')) return Icons.headphones_rounded;
    if (normalized.contains('video') || normalized.contains('curso')) return Icons.play_circle_fill_rounded;
    if (normalized.contains('app') || normalized.contains('herramienta') || normalized.contains('digital')) return Icons.phone_iphone_rounded;
    if (normalized.contains('físico') || normalized.contains('institucional') || normalized.contains('espacio')) return Icons.location_on_rounded;
    if (normalized.contains('pdf') || normalized.contains('guía')) return Icons.picture_as_pdf_rounded;
    return Icons.menu_book_rounded;
  }
}
