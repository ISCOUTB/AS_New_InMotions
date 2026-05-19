class TriageOptionModel {
  const TriageOptionModel({
    required this.id,
    required this.text,
    required this.score,
    this.interpretation,
  });

  final String id;
  final String text;
  final int score;
  final String? interpretation;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'score': score,
      'interpretation': interpretation,
    };
  }

  factory TriageOptionModel.fromMap(Map<String, dynamic> map) {
    return TriageOptionModel(
      id: map['id'] as String,
      text: map['text'] as String,
      score: map['score'] as int,
      interpretation: map['interpretation'] as String?,
    );
  }
}

class TriageQuestionModel {
  const TriageQuestionModel({
    required this.id,
    required this.area,
    required this.question,
    required this.type,
    required this.options,
    this.order = 0,
    this.isActive = true,
    this.isCritical = false,
  });

  final String id;
  final String area;
  final String question;
  final String type;
  final List<TriageOptionModel> options;
  final int order;
  final bool isActive;
  final bool isCritical;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area': area,
      'question': question,
      'type': type,
      'options': options.map((option) => option.toMap()).toList(),
      'order': order,
      'isActive': isActive,
      'isCritical': isCritical,
    };
  }

  factory TriageQuestionModel.fromMap(Map<String, dynamic> map) {
    return TriageQuestionModel(
      id: map['id'] as String,
      area: map['area'] as String? ?? 'General',
      question: map['question'] as String,
      type: map['type'] as String? ?? 'Estándar',
      options: (map['options'] as List<dynamic>)
          .map((option) => TriageOptionModel.fromMap(option as Map<String, dynamic>))
          .toList(),
      order: map['order'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      isCritical: map['isCritical'] as bool? ?? false,
    );
  }
}
