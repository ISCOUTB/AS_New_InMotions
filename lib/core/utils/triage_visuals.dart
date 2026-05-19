import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/triage_result_model.dart';

class TriageVisuals {
  const TriageVisuals._();

  static Color colorForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.green;
      case RiskLevel.medium:
        return AppColors.orange;
      case RiskLevel.high:
        return AppColors.red;
    }
  }

  static IconData iconForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.priority_high_rounded;
    }
  }
}
