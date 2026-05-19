class TriageOptionModel {
  const TriageOptionModel({
    required this.id,
    required this.text,
    required this.score,
  });

  final String id;
  final String text;
  final int score;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'score': score,
    };
  }

  factory TriageOptionModel.fromMap(Map<String, dynamic> map) {
    return TriageOptionModel(
      id: map['id'] as String,
      text: map['text'] as String,
      score: map['score'] as int,
    );
  }
}

class TriageQuestionModel {
  const TriageQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.order = 0,
    this.isActive = true,
  });

  final String id;
  final String question;
  final List<TriageOptionModel> options;
  final int order;
  final bool isActive;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.map((option) => option.toMap()).toList(),
      'order': order,
      'isActive': isActive,
    };
  }

  factory TriageQuestionModel.fromMap(Map<String, dynamic> map) {
    return TriageQuestionModel(
      id: map['id'] as String,
      question: map['question'] as String,
      options: (map['options'] as List<dynamic>)
          .map((option) => TriageOptionModel.fromMap(option as Map<String, dynamic>))
          .toList(),
      order: map['order'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
