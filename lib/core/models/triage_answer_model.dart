class TriageAnswerModel {
  const TriageAnswerModel({
    required this.questionId,
    required this.optionId,
    required this.optionText,
    required this.score,
  });

  final String questionId;
  final String optionId;
  final String optionText;
  final int score;

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'optionId': optionId,
      'optionText': optionText,
      'score': score,
    };
  }

  factory TriageAnswerModel.fromMap(Map<String, dynamic> map) {
    return TriageAnswerModel(
      questionId: map['questionId'] as String,
      optionId: map['optionId'] as String,
      optionText: map['optionText'] as String,
      score: map['score'] as int,
    );
  }
}
