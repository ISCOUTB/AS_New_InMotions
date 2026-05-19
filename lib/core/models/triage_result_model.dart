import 'triage_answer_model.dart';

enum RiskLevel { green, yellow, orange, red, critical }

extension RiskLevelText on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.green:
        return 'Verde';
      case RiskLevel.yellow:
        return 'Amarillo';
      case RiskLevel.orange:
        return 'Naranja';
      case RiskLevel.red:
        return 'Rojo';
      case RiskLevel.critical:
        return 'Crítico';
    }
  }

  String get title {
    switch (this) {
      case RiskLevel.green:
        return 'Bienestar estable';
      case RiskLevel.yellow:
        return 'Malestar moderado';
      case RiskLevel.orange:
        return 'Malestar significativo';
      case RiskLevel.red:
        return 'Malestar alto';
      case RiskLevel.critical:
        return 'Protocolo crítico activado';
    }
  }

  String get message {
    switch (this) {
      case RiskLevel.green:
        return '¡Gracias por completar el test! Tus respuestas sugieren que estás transitando un momento de bienestar emocional. Te invitamos a explorar los recursos de la aplicación para mantener y fortalecer tu salud mental.';
      case RiskLevel.yellow:
        return 'Gracias por completar el test. Tus respuestas indican que has estado experimentando algunos desafíos emocionales. Es normal pasar por momentos así, y hay herramientas que pueden ayudarte.';
      case RiskLevel.orange:
        return 'Gracias por tu honestidad al completar el test. Tus respuestas sugieren que estás pasando por un momento difícil y que podrías beneficiarte significativamente de conversar con un profesional.';
      case RiskLevel.red:
        return 'Gracias por confiar en esta herramienta. Tus respuestas indican que estás experimentando un malestar significativo y que es importante recibir apoyo profesional lo antes posible.';
      case RiskLevel.critical:
        return 'Gracias por compartir algo tan importante. Lo que estás sintiendo importa, y no tienes que enfrentarlo solo/a. Por favor revisa primero los recursos de ayuda inmediata.';
    }
  }

  bool get requiresReferral => this == RiskLevel.orange || this == RiskLevel.red || this == RiskLevel.critical;

  bool get restrictsLibrary => this == RiskLevel.red || this == RiskLevel.critical;
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
    this.isCriticalProtocol = false,
    this.criticalQuestionIds = const [],
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
  final bool isCriticalProtocol;
  final List<String> criticalQuestionIds;

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
      'isCriticalProtocol': isCriticalProtocol,
      'criticalQuestionIds': criticalQuestionIds,
    };
  }

  factory TriageResultModel.fromMap(Map<String, dynamic> map) {
    return TriageResultModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      score: map['score'] as int,
      riskLevel: RiskLevel.values.firstWhere(
        (level) => level.name == map['riskLevel'],
        orElse: () => RiskLevel.green,
      ),
      requiresReferral: map['requiresReferral'] as bool? ?? false,
      answers: (map['answers'] as List<dynamic>? ?? [])
          .map((answer) => TriageAnswerModel.fromMap(answer as Map<String, dynamic>))
          .toList(),
      recommendations: (map['recommendations'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      referralStatus: map['referralStatus'] as String?,
      isCriticalProtocol: map['isCriticalProtocol'] as bool? ?? false,
      criticalQuestionIds: (map['criticalQuestionIds'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
