import '../../core/constants/app_config.dart';
import '../../core/models/resource_model.dart';
import '../../core/models/triage_result_model.dart';
import '../../core/services/resource_api_service.dart';
import '../../core/storage/local_resource_storage.dart';
import '../../core/storage/local_triage_storage.dart';

class ResourceRepository {
  ResourceRepository({
    LocalResourceStorage? resourceStorage,
    LocalTriageStorage? triageStorage,
    ResourceApiService? apiService,
  })  : _resourceStorage = resourceStorage ?? LocalResourceStorage(),
        _triageStorage = triageStorage ?? LocalTriageStorage(),
        _apiService = apiService ?? ResourceApiService();

  final LocalResourceStorage _resourceStorage;
  final LocalTriageStorage _triageStorage;
  final ResourceApiService _apiService;

  bool get _useBackend => AppConfig.useRemoteBackend;

  Future<List<ResourceModel>> getAllResources() async {
    if (_useBackend) {
      final response = await _apiService.getResources();
      return _resourcesFromResponse(response);
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<ResourceModel>.from(_resources);
  }

  Future<ResourceModel?> getById(String id) async {
    if (_useBackend) {
      final response = await _apiService.getResourceDetail(id);
      final data = response['data'] as Map<String, dynamic>?;
      final resource = data?['resource'];
      if (resource is Map<String, dynamic>) return ResourceModel.fromMap(resource);
      return null;
    }

    final resources = await getAllResources();
    for (final resource in resources) {
      if (resource.id == id) return resource;
    }
    return null;
  }

  Future<List<ResourceModel>> searchResources({
    String query = '',
    String thematic = 'Todos',
    String format = 'Todos',
    String level = 'Todos',
    bool favoritesOnly = false,
  }) async {
    if (_useBackend) {
      final response = await _apiService.getResources(
        query: query.trim().isEmpty ? null : query.trim(),
        thematic: thematic == 'Todos' ? null : thematic,
        format: format == 'Todos' ? null : format,
        level: level == 'Todos' ? null : level,
        favoritesOnly: favoritesOnly,
      );
      return _resourcesFromResponse(response);
    }

    final resources = await getAllResources();
    final favoriteIds = await _resourceStorage.getFavoriteIds();
    final normalizedQuery = query.trim().toLowerCase();

    return resources.where((resource) {
      final matchesQuery = normalizedQuery.isEmpty ||
          resource.title.toLowerCase().contains(normalizedQuery) ||
          resource.thematic.toLowerCase().contains(normalizedQuery) ||
          resource.format.toLowerCase().contains(normalizedQuery) ||
          resource.description.toLowerCase().contains(normalizedQuery);
      final matchesThematic = thematic == 'Todos' || resource.thematic.toLowerCase().contains(thematic.toLowerCase());
      final matchesFormat = format == 'Todos' || resource.format.toLowerCase().contains(format.toLowerCase());
      final matchesLevel = level == 'Todos' || resource.level == level;
      final matchesFavorite = !favoritesOnly || favoriteIds.contains(resource.id);
      return matchesQuery && matchesThematic && matchesFormat && matchesLevel && matchesFavorite;
    }).toList();
  }

  Future<List<ResourceModel>> getRecommendedResources({int limit = 5}) async {
    final resources = await getAllResources();
    final latestResult = await _triageStorage.getLatestResult();
    final allowedLevels = _levelsForResult(latestResult?.riskLevel);
    final filtered = resources.where((resource) => allowedLevels.contains(resource.level)).toList();

    if (latestResult == null) {
      return filtered.take(limit).toList();
    }

    final priorityAreas = _priorityAreasFromResult(latestResult);
    filtered.sort((a, b) {
      final aPriority = priorityAreas.any((area) => a.thematic.toLowerCase().contains(area.toLowerCase())) ? 0 : 1;
      final bPriority = priorityAreas.any((area) => b.thematic.toLowerCase().contains(area.toLowerCase())) ? 0 : 1;
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      return a.id.compareTo(b.id);
    });

    return filtered.take(limit).toList();
  }

  Future<Set<String>> getFavoriteIds() async {
    if (_useBackend) {
      final response = await _apiService.getFavorites();
      final data = response['data'] as Map<String, dynamic>?;
      final ids = data?['favoriteIds'];
      if (ids is List) return ids.map((item) => item.toString()).toSet();
      return <String>{};
    }
    return _resourceStorage.getFavoriteIds();
  }

  Future<bool> toggleFavorite(String resourceId) async {
    if (_useBackend) {
      final favoriteIds = await getFavoriteIds();
      final response = favoriteIds.contains(resourceId)
          ? await _apiService.removeFavorite(resourceId)
          : await _apiService.addFavorite(resourceId);
      final data = response['data'] as Map<String, dynamic>?;
      final isFavorite = data?['isFavorite'];
      return isFavorite is bool ? isFavorite : !favoriteIds.contains(resourceId);
    }
    return _resourceStorage.toggleFavorite(resourceId);
  }

  Future<bool> hasRestrictedAccessAcknowledgement() => _resourceStorage.hasAcknowledgedRedAccess();

  Future<void> acknowledgeRestrictedAccess() => _resourceStorage.acknowledgeRedAccess();

  Future<TriageResultModel?> getLatestTriageResult() => _triageStorage.getLatestResult();

  List<String> getThematics() {
    final values = _resources.map((resource) => resource.thematic).toSet().toList()..sort();
    return ['Todos', ...values];
  }

  List<String> getFormats() {
    final values = _resources.map((resource) => resource.format).toSet().toList()..sort();
    return ['Todos', ...values];
  }

  List<String> getLevels() => const ['Todos', 'Verde', 'Amarillo', 'Naranja', 'Rojo'];

  List<ResourceModel> _resourcesFromResponse(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>?;
    final rawResources = data?['resources'];
    if (rawResources is! List) return <ResourceModel>[];
    return rawResources
        .whereType<Map<String, dynamic>>()
        .map(ResourceModel.fromMap)
        .toList();
  }

  Set<String> _levelsForResult(RiskLevel? level) {
    if (level == null) return {'Verde'};

    switch (level) {
      case RiskLevel.green:
        return {'Verde'};
      case RiskLevel.yellow:
        return {'Amarillo', 'Verde'};
      case RiskLevel.orange:
        return {'Naranja', 'Amarillo'};
      case RiskLevel.red:
      case RiskLevel.critical:
        return {'Rojo', 'Naranja'};
    }
  }

  List<String> _priorityAreasFromResult(TriageResultModel result) {
    final areas = <String>[];
    final highScores = result.answers.where((answer) => answer.score >= 3).map((answer) => answer.questionId).toList();

    int countPrefix(String prefix) => highScores.where((id) => id.startsWith(prefix)).length;

    if (countPrefix('B') >= 2) areas.add('Ansiedad');
    if (countPrefix('C') >= 2) areas.add('Estrés');
    if (countPrefix('D') >= 2) areas.add('Regulación');
    if (countPrefix('A') >= 2) areas.add('Autoestima');
    if (countPrefix('E') >= 2) areas.add('Relaciones');
    if (result.riskLevel == RiskLevel.red || result.riskLevel == RiskLevel.critical) areas.insert(0, 'Crisis');

    return areas;
  }

  static const List<ResourceModel> _resources = [
    ResourceModel(
      id: 'B01',
      title: 'El poder del ahora',
      thematic: 'Regulación Emocional',
      format: 'Libro',
      description: 'Guía de presencia mental y reducción de rumiación.',
      level: 'Amarillo',
      validation: 'Recurso de biblioterapia revisado para psicoeducación.',
      author: 'E. Tolle',
      content: 'Recurso orientado a fortalecer la presencia mental, observar pensamientos repetitivos y practicar pausas de atención plena. Úsalo como apoyo preventivo o complementario cuando notes rumiación o preocupación constante.',
    ),
    ResourceModel(
      id: 'B02',
      title: 'Mindfulness para principiantes',
      thematic: 'Ansiedad',
      format: 'Libro/Audio',
      description: 'Técnicas de atención plena para manejar estrés cotidiano.',
      level: 'Verde',
      validation: 'Basado en prácticas de mindfulness ampliamente usadas en bienestar emocional.',
      author: 'J. Kabat-Zinn',
      content: 'Introduce prácticas breves de respiración consciente, observación del cuerpo y atención al presente. Puede usarse para mantener bienestar emocional y reducir activación fisiológica leve.',
    ),
    ResourceModel(
      id: 'B03',
      title: 'Podcast: La mente en calma',
      thematic: 'Estrés',
      format: 'Audio/Podcast',
      description: 'Episodios breves con estrategias de regulación emocional.',
      level: 'Verde',
      validation: 'Psicoeducación preventiva en formato breve.',
      content: 'Serie de audios cortos para acompañar pausas de descanso, manejo de pensamientos acelerados y organización de rutinas durante semanas académicas exigentes.',
    ),
    ResourceModel(
      id: 'B04',
      title: 'Curso: Gestión emocional en 7 días',
      thematic: 'Regulación Emocional',
      format: 'Video/Interactivo',
      description: 'Micro-lecciones con ejercicios prácticos y registro de progreso.',
      level: 'Amarillo',
      validation: 'Contenido psicoeducativo estructurado para autorregulación.',
      content: 'Plan corto de ejercicios para reconocer emociones, identificar detonantes, practicar respiración y organizar acciones de autocuidado durante una semana.',
    ),
    ResourceModel(
      id: 'B05',
      title: 'App: Sanvello',
      thematic: 'Ansiedad',
      format: 'Herramienta Digital',
      description: 'Seguimiento de ánimo, CBT guiada y ejercicios de respiración.',
      level: 'Naranja',
      validation: 'Herramienta digital complementaria basada en principios CBT.',
      content: 'Recurso digital complementario para seguimiento emocional, ejercicios guiados y prácticas de respiración. No sustituye atención profesional cuando hay malestar significativo.',
    ),
    ResourceModel(
      id: 'B06',
      title: 'Espacio: Sala de Bienestar UTB',
      thematic: 'Hábitos Saludables',
      format: 'Espacio Físico/Institucional',
      description: 'Lugar silencioso para lectura, meditación y desconexión en campus.',
      level: 'Verde',
      validation: 'Recurso institucional UTB.',
      isInstitutional: true,
      content: 'Espacio físico sugerido para pausas, lectura tranquila, respiración y desconexión. Recomendado como recurso de mantenimiento y prevención dentro del campus.',
    ),
    ResourceModel(
      id: 'B07',
      title: 'Cuando el cuerpo dice no',
      thematic: 'Estrés/Cuerpo',
      format: 'Libro',
      description: 'Exploración del vínculo entre estrés crónico y salud física.',
      level: 'Naranja',
      validation: 'Biblioterapia complementaria para reflexión sobre estrés crónico.',
      author: 'G. Maté',
      content: 'Recurso de lectura para comprender cómo el estrés sostenido puede relacionarse con malestar físico. Debe usarse como apoyo paralelo si ya existe recomendación profesional.',
    ),
    ResourceModel(
      id: 'B08',
      title: 'Taller: Primeros auxilios psicológicos',
      thematic: 'Crisis/Prevención',
      format: 'Video/Institucional',
      description: 'Protocolo básico de contención emocional para pares y autocuidado.',
      level: 'Naranja',
      validation: 'Recurso institucional y preventivo.',
      isInstitutional: true,
      content: 'Material introductorio sobre escucha, contención, identificación de señales de alerta y rutas de apoyo. Útil para reconocer cuándo buscar ayuda inmediata.',
    ),
    ResourceModel(
      id: 'B09',
      title: 'Guía: Higiene del sueño universitario',
      thematic: 'Sueño',
      format: 'PDF/Interactivo',
      description: 'Rutinas para mejorar descanso y rendimiento académico.',
      level: 'Verde',
      validation: 'Psicoeducación preventiva para hábitos saludables.',
      content: 'Guía práctica con horarios de sueño, reducción de pantallas antes de dormir, planificación de estudio y señales para consultar si el problema persiste.',
    ),
    ResourceModel(
      id: 'B10',
      title: 'Biblioteca UTB – Zona de Calma',
      thematic: 'Hábitos Saludables',
      format: 'Espacio Físico/Institucional',
      description: 'Área designada para lectura tranquila y desconexión digital.',
      level: 'Verde',
      validation: 'Recurso institucional UTB.',
      isInstitutional: true,
      content: 'Espacio sugerido para pausas de lectura, concentración y desconexión. Puede complementar el diario emocional y las rutinas de autocuidado.',
    ),
    ResourceModel(
      id: 'B11',
      title: 'Ansiedad: cómo enfrentarla',
      thematic: 'Ansiedad',
      format: 'Libro',
      description: 'Estrategias prácticas basadas en terapia cognitivo-conductual.',
      level: 'Amarillo',
      validation: 'Biblioterapia con enfoque CBT.',
      author: 'F. Sarramona',
      content: 'Lectura de apoyo con herramientas para identificar pensamientos ansiosos, cuestionarlos y aplicar conductas de afrontamiento saludables.',
    ),
    ResourceModel(
      id: 'B12',
      title: 'Audio: Respiración 4-7-8 guiada',
      thematic: 'Regulación Emocional',
      format: 'Audio',
      description: 'Técnica de respiración para reducir activación fisiológica en 3 minutos.',
      level: 'Verde',
      validation: 'Ejercicio de respiración usado en autorregulación emocional.',
      content: 'Ejercicio breve: inhalar 4 segundos, sostener 7 y exhalar 8. Repite varias rondas en un lugar seguro y cómodo.',
    ),
    ResourceModel(
      id: 'B13',
      title: 'Video: Manejo del estrés académico',
      thematic: 'Estrés',
      format: 'Video',
      description: 'Consejos para estudiantes universitarios.',
      level: 'Amarillo',
      validation: 'Psicoeducación para población universitaria.',
      content: 'Video con estrategias para dividir tareas, priorizar pendientes, cuidar pausas y reconocer cuándo el estrés académico requiere apoyo adicional.',
    ),
    ResourceModel(
      id: 'B14',
      title: 'App: Woebot',
      thematic: 'Regulación Emocional',
      format: 'Herramienta Digital',
      description: 'Conversaciones guiadas con IA basada en principios CBT.',
      level: 'Naranja',
      validation: 'Herramienta digital complementaria basada en CBT.',
      content: 'Herramienta complementaria para identificar pensamientos y practicar reestructuración cognitiva básica. No reemplaza atención psicológica.',
    ),
    ResourceModel(
      id: 'B15',
      title: 'Guía: Autocompasión en tiempos difíciles',
      thematic: 'Autoestima',
      format: 'PDF',
      description: 'Ejercicios de autocompasión adaptados al contexto universitario.',
      level: 'Amarillo',
      validation: 'Ejercicios adaptados de psicoeducación en autocompasión.',
      content: 'Guía con ejercicios para reconocer sufrimiento sin juicio, hablarse con amabilidad y construir acciones pequeñas de cuidado durante periodos difíciles.',
    ),
    ResourceModel(
      id: 'B16',
      title: 'Contactos de emergencia y apoyo inmediato',
      thematic: 'Crisis/Prevención',
      format: 'Espacio Físico/Institucional',
      description: 'Línea 192, Línea 123 y Psicología UTB para situaciones de crisis.',
      level: 'Rojo',
      validation: 'Rutas institucionales y nacionales de apoyo.',
      isInstitutional: true,
      content: 'Si estás en peligro inmediato, llama al 123. También puedes contactar la Línea 192 de Salud Mental Colombia y Psicología UTB en bienestar@utb.edu.co. Tu vida es valiosa y no tienes que afrontar esto solo/a.',
    ),
  ];
}
