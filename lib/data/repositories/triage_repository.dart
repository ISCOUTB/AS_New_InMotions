import '../../core/constants/app_config.dart';
import '../../core/models/triage_answer_model.dart';
import '../../core/models/triage_question_model.dart';
import '../../core/models/triage_result_model.dart';
import '../../core/storage/local_session_storage.dart';
import '../../core/storage/local_triage_storage.dart';

class TriageException implements Exception {
  TriageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TriageRepository {
  TriageRepository({
    LocalSessionStorage? sessionStorage,
    LocalTriageStorage? triageStorage,
  })  : _sessionStorage = sessionStorage ?? LocalSessionStorage(),
        _triageStorage = triageStorage ?? LocalTriageStorage();

  final LocalSessionStorage _sessionStorage;
  final LocalTriageStorage _triageStorage;

  Future<List<TriageQuestionModel>> getActiveQuestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _defaultQuestions.where((question) => question.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<TriageResultModel> submitAnswers(Map<String, TriageOptionModel> selectedOptions) async {
    final user = await _sessionStorage.getCurrentUser();
    if (user == null) {
      throw TriageException('Debes iniciar sesión para realizar el triaje');
    }

    final questions = await getActiveQuestions();
    final missingQuestions = questions.where((question) => !selectedOptions.containsKey(question.id)).toList();

    if (missingQuestions.isNotEmpty) {
      throw TriageException('Responde todas las preguntas antes de ver el resultado');
    }

    final answers = questions.map((question) {
      final selectedOption = selectedOptions[question.id]!;
      return TriageAnswerModel(
        questionId: question.id,
        optionId: selectedOption.id,
        optionText: selectedOption.text,
        score: selectedOption.score,
      );
    }).toList();

    final score = calculateScore(answers);
    final riskLevel = calculateRiskLevel(score);
    final now = DateTime.now();

    final result = TriageResultModel(
      id: 'triage-${now.millisecondsSinceEpoch}',
      userId: user.id,
      score: score,
      riskLevel: riskLevel,
      requiresReferral: riskLevel.requiresReferral,
      answers: answers,
      recommendations: getRecommendationsByRiskLevel(riskLevel),
      createdAt: now,
      referralStatus: riskLevel.requiresReferral ? 'pendiente_backend' : null,
    );

    await _triageStorage.saveResult(result);
    return result;
  }

  Future<List<TriageResultModel>> getMyResults() async {
    final user = await _sessionStorage.getCurrentUser();
    if (user == null) return [];
    return _triageStorage.getResultsByUser(user.id);
  }

  Future<TriageResultModel?> getMyLatestResult() async {
    final user = await _sessionStorage.getCurrentUser();
    if (user == null) return null;
    return _triageStorage.getLatestResultByUser(user.id);
  }

  int calculateScore(List<TriageAnswerModel> answers) {
    return answers.fold<int>(0, (sum, answer) => sum + answer.score);
  }

  RiskLevel calculateRiskLevel(int score) {
    if (score >= AppConfig.highRiskThreshold) return RiskLevel.high;
    if (score >= 8) return RiskLevel.medium;
    return RiskLevel.low;
  }

  List<String> getRecommendationsByRiskLevel(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return const [
          'Continuar con el registro emocional diario.',
          'Mantener descanso, actividad física y redes de apoyo.',
          'Consultar recursos educativos de bienestar dentro de la app.',
        ];
      case RiskLevel.medium:
        return const [
          'Registrar emociones durante la semana para identificar patrones.',
          'Practicar respiración consciente o pausas activas.',
          'Buscar orientación si el malestar se mantiene o aumenta.',
        ];
      case RiskLevel.high:
        return const [
          'Contactar al área de Psicología UTB.',
          'Hablar con una persona de confianza hoy.',
          'Evitar tomar decisiones importantes mientras te sientes sobrecargado.',
        ];
    }
  }

  static const List<TriageQuestionModel> _defaultQuestions = [
    TriageQuestionModel(
      id: 'q1',
      order: 1,
      question: 'Durante la última semana, ¿con qué frecuencia te has sentido ansioso/a o con preocupación excesiva?',
      options: [
        TriageOptionModel(id: 'q1_o0', text: 'Nunca', score: 0),
        TriageOptionModel(id: 'q1_o1', text: 'Algunos días', score: 1),
        TriageOptionModel(id: 'q1_o2', text: 'Más de la mitad de los días', score: 2),
        TriageOptionModel(id: 'q1_o3', text: 'Casi todos los días', score: 3),
      ],
    ),
    TriageQuestionModel(
      id: 'q2',
      order: 2,
      question: '¿Has tenido dificultad para dormir, descansar o mantener una rutina de sueño?',
      options: [
        TriageOptionModel(id: 'q2_o0', text: 'No he tenido dificultad', score: 0),
        TriageOptionModel(id: 'q2_o1', text: 'Un poco', score: 1),
        TriageOptionModel(id: 'q2_o2', text: 'Con frecuencia', score: 2),
        TriageOptionModel(id: 'q2_o3', text: 'Casi siempre', score: 3),
      ],
    ),
    TriageQuestionModel(
      id: 'q3',
      order: 3,
      question: '¿Has perdido interés o motivación por actividades que antes disfrutabas?',
      options: [
        TriageOptionModel(id: 'q3_o0', text: 'No', score: 0),
        TriageOptionModel(id: 'q3_o1', text: 'Levemente', score: 1),
        TriageOptionModel(id: 'q3_o2', text: 'Bastante', score: 2),
        TriageOptionModel(id: 'q3_o3', text: 'Mucho', score: 3),
      ],
    ),
    TriageQuestionModel(
      id: 'q4',
      order: 4,
      question: '¿Qué tanto han afectado tus emociones tu rendimiento académico o tus relaciones?',
      options: [
        TriageOptionModel(id: 'q4_o0', text: 'Nada', score: 0),
        TriageOptionModel(id: 'q4_o1', text: 'Poco', score: 1),
        TriageOptionModel(id: 'q4_o2', text: 'Moderadamente', score: 2),
        TriageOptionModel(id: 'q4_o3', text: 'Mucho', score: 3),
      ],
    ),
    TriageQuestionModel(
      id: 'q5',
      order: 5,
      question: '¿Sientes que necesitas apoyo profesional para manejar lo que estás viviendo?',
      options: [
        TriageOptionModel(id: 'q5_o0', text: 'No lo considero necesario', score: 0),
        TriageOptionModel(id: 'q5_o1', text: 'Tal vez', score: 1),
        TriageOptionModel(id: 'q5_o2', text: 'Sí, me gustaría orientación', score: 2),
        TriageOptionModel(id: 'q5_o3', text: 'Sí, lo necesito pronto', score: 3),
      ],
    ),
  ];
}
