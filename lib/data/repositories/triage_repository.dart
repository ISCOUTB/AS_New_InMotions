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
    return _officialQuestions.where((question) => question.isActive).toList()
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
    final criticalQuestionIds = _criticalQuestionIdsFromAnswers(answers);
    final isCritical = criticalQuestionIds.isNotEmpty;
    final riskLevel = isCritical ? RiskLevel.critical : calculateRiskLevel(score);
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
      isCriticalProtocol: isCritical,
      criticalQuestionIds: criticalQuestionIds,
    );

    await _triageStorage.saveResult(result);
    return result;
  }

  Future<TriageResultModel?> getMyLatestResult() async {
    final user = await _sessionStorage.getCurrentUser();
    if (user == null) return null;

    final results = await _triageStorage.getResultsByUser(user.id);
    if (results.isEmpty) return null;
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.first;
  }

  Future<List<TriageResultModel>> getMyResults() async {
    final user = await _sessionStorage.getCurrentUser();
    if (user == null) return [];
    final results = await _triageStorage.getResultsByUser(user.id);
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  int calculateScore(List<TriageAnswerModel> answers) {
    return answers.fold<int>(0, (sum, answer) => sum + answer.score);
  }

  RiskLevel calculateRiskLevel(int score) {
    if (score <= AppConfig.greenMaxScore) return RiskLevel.green;
    if (score <= AppConfig.yellowMaxScore) return RiskLevel.yellow;
    if (score <= AppConfig.orangeMaxScore) return RiskLevel.orange;
    return RiskLevel.red;
  }

  List<String> _criticalQuestionIdsFromAnswers(List<TriageAnswerModel> answers) {
    return answers
        .where((answer) => _criticalQuestionIds.contains(answer.questionId) && answer.score >= AppConfig.criticalActivationScore)
        .map((answer) => answer.questionId)
        .toList();
  }

  List<String> getRecommendationsByRiskLevel(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.green:
        return const [
          'Explora el blog de bienestar y recursos preventivos de la aplicación.',
          'Mantén tu diario emocional como herramienta de seguimiento.',
          'Realiza una reevaluación mensual o cuando notes cambios importantes.',
        ];
      case RiskLevel.yellow:
        return const [
          'Explora recursos de autorregulación, biblioterapia y ejercicios prácticos.',
          'Activa un recordatorio para revisar cómo te sientes en las próximas dos semanas.',
          'Si el malestar persiste, agenda una cita con Psicología UTB para recibir apoyo personalizado.',
        ];
      case RiskLevel.orange:
        return const [
          'Agenda una cita con Bienestar Universitario - Área de Psicología.',
          'Usa la biblioteca como apoyo paralelo, no como sustituto de la atención profesional.',
          'Busca acompañamiento de una persona de confianza mientras recibes orientación.',
        ];
      case RiskLevel.red:
        return const [
          'Contacta a Psicología UTB hoy mismo: bienestar@utb.edu.co.',
          'Mantén disponibles líneas de crisis: Línea 192 y Línea 123.',
          'Evita manejar este malestar en soledad; busca apoyo inmediato.',
        ];
      case RiskLevel.critical:
        return const [
          'Si estás en peligro inmediato, llama al 123.',
          'Contacta la Línea 192 de Salud Mental Colombia, gratuita y disponible 24/7.',
          'Contacta a Psicología UTB: bienestar@utb.edu.co.',
          'No tienes que enfrentar esto solo/a; busca apoyo ahora mismo.',
        ];
    }
  }

  static const List<String> _criticalQuestionIds = ['A5', 'F1', 'F2'];

  static List<TriageOptionModel> _likertOptions(String questionId) => [
        TriageOptionModel(
          id: '${questionId}_1',
          text: 'No me identifico',
          score: 1,
          interpretation: 'Esto no me ha ocurrido en el periodo evaluado.',
        ),
        TriageOptionModel(
          id: '${questionId}_2',
          text: 'Poco',
          score: 2,
          interpretation: 'Me ha ocurrido muy esporádicamente.',
        ),
        TriageOptionModel(
          id: '${questionId}_3',
          text: 'Moderadamente',
          score: 3,
          interpretation: 'Me ha ocurrido con cierta frecuencia.',
        ),
        TriageOptionModel(
          id: '${questionId}_4',
          text: 'Bastante',
          score: 4,
          interpretation: 'Me ha ocurrido frecuentemente.',
        ),
        TriageOptionModel(
          id: '${questionId}_5',
          text: 'Totalmente',
          score: 5,
          interpretation: 'Esta afirmación me describe completamente.',
        ),
      ];

  static TriageQuestionModel _q({
    required String id,
    required int order,
    required String area,
    required String question,
    String type = 'Estándar',
    bool isCritical = false,
  }) {
    return TriageQuestionModel(
      id: id,
      order: order,
      area: area,
      question: question,
      type: type,
      isCritical: isCritical,
      options: _likertOptions(id),
    );
  }

  static final List<TriageQuestionModel> _officialQuestions = [
    _q(id: 'A1', order: 1, area: 'Depresión', question: 'He sentido poco interés o placer en hacer cosas que antes disfrutaba.'),
    _q(id: 'A2', order: 2, area: 'Depresión', question: 'Me he sentido triste, vacío/a o sin esperanza la mayor parte del tiempo.'),
    _q(id: 'A3', order: 3, area: 'Depresión', question: 'He tenido dificultad para dormir (insomnio) o he dormido demasiado.'),
    _q(id: 'A4', order: 4, area: 'Depresión', question: 'Me he sentido cansado/a o con poca energía, incluso después de descansar.'),
    _q(id: 'A5', order: 5, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true),
    _q(id: 'B1', order: 6, area: 'Ansiedad', question: 'Me he sentido nervioso/a, ansioso/a o con los nervios de punta.'),
    _q(id: 'B2', order: 7, area: 'Ansiedad', question: 'No he podido dejar de preocuparme o controlar mis pensamientos ansiosos.'),
    _q(id: 'B3', order: 8, area: 'Ansiedad', question: 'Me he preocupado demasiado por diferentes situaciones de mi vida.'),
    _q(id: 'B4', order: 9, area: 'Ansiedad', question: 'He tenido dificultad para relajarme o me siento inquieto/a físicamente.'),
    _q(id: 'B5', order: 10, area: 'Ansiedad', question: 'Me he irritado o molestado con facilidad por cosas pequeñas.'),
    _q(id: 'C1', order: 11, area: 'Estrés', question: 'Me he sentido abrumado/a por mis responsabilidades diarias.'),
    _q(id: 'C2', order: 12, area: 'Estrés', question: 'He tenido dificultad para concentrarme en tareas cotidianas.'),
    _q(id: 'C3', order: 13, area: 'Estrés', question: 'Siento que no tengo tiempo para descansar o recuperarme.'),
    _q(id: 'C4', order: 14, area: 'Estrés', question: 'He experimentado tensión muscular, dolores de cabeza o malestar físico sin causa médica clara.'),
    _q(id: 'D1', order: 15, area: 'Regulación', question: 'Me cuesta manejar emociones intensas como tristeza, enojo o miedo.'),
    _q(id: 'D2', order: 16, area: 'Regulación', question: 'Cuando algo sale mal, tiendo a pensar que todo está perdido.'),
    _q(id: 'D3', order: 17, area: 'Regulación', question: 'Siento que no tengo herramientas para afrontar momentos difíciles.'),
    _q(id: 'D4', order: 18, area: 'Regulación', question: 'Evito enfrentar problemas porque me generan mucha ansiedad o malestar.'),
    _q(id: 'E1', order: 19, area: 'Social', question: 'Me he aislado de familiares o amigos, evitando contacto social.'),
    _q(id: 'E2', order: 20, area: 'Social', question: 'He sentido que no puedo cumplir con mis responsabilidades (estudio, trabajo, hogar).'),
    _q(id: 'E3', order: 21, area: 'Social', question: 'He notado que mi estado emocional afecta mis relaciones con otras personas.'),
    _q(id: 'F1', order: 22, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true),
    _q(id: 'F2', order: 23, area: 'Crisis', question: 'He tenido pensamientos sobre lastimarme o terminar con mi vida.', type: 'Crítico', isCritical: true),
  ];
}
