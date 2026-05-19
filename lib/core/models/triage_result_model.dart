import 'triage_answer_model.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelText on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Bajo';
      case RiskLevel.medium:
        return 'Medio';
      case RiskLevel.high:
        return 'Alto';
    }
  }

  String get title {
    switch (this) {
      case RiskLevel.low:
        return 'Tu resultado está en rango bajo';
      case RiskLevel.medium:
        return 'Necesitas fortalecer tu autocuidado';
      case RiskLevel.high:
        return 'Se recomienda apoyo profesional';
    }
  }

  String get message {
    switch (this) {
      case RiskLevel.low:
        return 'Tus respuestas no muestran señales fuertes de riesgo en este momento. Mantén hábitos de bienestar y seguimiento emocional.';
      case RiskLevel.medium:
        return 'Tus respuestas muestran señales moderadas de tensión emocional. Puedes beneficiarte de hábitos de regulación y seguimiento.';
      case RiskLevel.high:
        return 'Tus respuestas indican un nivel alto de malestar emocional. Es importante que no lo manejes en soledad y busques acompañamiento.';
    }
  }

  bool get requiresReferral => this == RiskLevel.high;
}

class TriageResultModel {
  const TriageResultModel({
    required this.id,
    required this.userId,
    required this.score,
    required this.riskLevel,
    required this.requiresReferral,
    required this.answers,
    required this.recommendations,
    required this.createdAt,
    this.referralStatus,
  });

  final String id;
  final String userId;
  final int score;
  final RiskLevel riskLevel;
  final bool requiresReferral;
  final List<TriageAnswerModel> answers;
  final List<String> recommendations;
  final DateTime createdAt;
  final String? referralStatus;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'score': score,
      'riskLevel': riskLevel.name,
      'requiresReferral': requiresReferral,
      'answers': answers.map((answer) => answer.toMap()).toList(),
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'referralStatus': referralStatus,
    };
  }

  factory TriageResultModel.fromMap(Map<String, dynamic> map) {
    return TriageResultModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      score: map['score'] as int,
      riskLevel: RiskLevel.values.firstWhere(
        (level) => level.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      requiresReferral: map['requiresReferral'] as bool? ?? false,
      answers: (map['answers'] as List<dynamic>? ?? [])
          .map((answer) => TriageAnswerModel.fromMap(answer as Map<String, dynamic>))
          .toList(),
      recommendations: (map['recommendations'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      referralStatus: map['referralStatus'] as String?,
    );
  }
}
