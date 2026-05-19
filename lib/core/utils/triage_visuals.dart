import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/triage_result_model.dart';

class TriageVisuals {
  const TriageVisuals._();

  static Color colorForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return AppColors.green;
      case RiskLevel.yellow:
        return AppColors.yellow;
      case RiskLevel.orange:
        return AppColors.orange;
      case RiskLevel.red:
        return AppColors.red;
      case RiskLevel.critical:
        return const Color(0xFF991B1B);
    }
  }

  static IconData iconForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return Icons.check_circle_rounded;
      case RiskLevel.yellow:
        return Icons.lightbulb_rounded;
      case RiskLevel.orange:
        return Icons.support_agent_rounded;
      case RiskLevel.red:
        return Icons.priority_high_rounded;
      case RiskLevel.critical:
        return Icons.emergency_share_rounded;
    }
  }
}
