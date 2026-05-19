import '../../core/constants/app_config.dart';
import '../../core/models/mood_record_model.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/mood_api_service.dart';
import '../../core/storage/local_mood_storage.dart';
import '../../core/utils/date_formatter.dart';
import 'auth_repository.dart';

class MoodRepositoryException implements Exception {
  MoodRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MoodRepository {
  MoodRepository({
    LocalMoodStorage? storage,
    AuthRepository? authRepository,
    MoodApiService? moodApiService,
  })  : _storage = storage ?? LocalMoodStorage(),
        _authRepository = authRepository ?? AuthRepository(),
        _moodApiService = moodApiService ?? MoodApiService();

  final LocalMoodStorage _storage;
  final AuthRepository _authRepository;
  final MoodApiService _moodApiService;

  Future<MoodRecord> saveMoodRecord({
    required String mood,
    required int level,
    required List<String> tags,
    required String note,
  }) async {
    if (AppConfig.useRemoteBackend) {
      return _saveMoodRecordRemote(
        mood: mood,
        level: level,
        tags: tags,
        note: note,
      );
    }

    return _saveMoodRecordLocal(
      mood: mood,
      level: level,
      tags: tags,
      note: note,
    );
  }

  Future<List<MoodRecord>> getMoodHistory() async {
    if (AppConfig.useRemoteBackend) {
      return _getMoodHistoryRemote();
    }

    return _getMoodHistoryLocal();
  }

  Future<MoodRecord?> getTodayMoodRecord() async {
    if (AppConfig.useRemoteBackend) {
      return _getTodayMoodRecordRemote();
    }

    final records = await getMoodHistory();
    final today = DateTime.now();

    for (final record in records) {
      if (DateFormatter.isSameDay(record.createdAt, today)) {
        return record;
      }
    }

    return null;
  }

  Future<List<MoodRecord>> getCurrentWeekRecords() async {
    final records = await getMoodHistory();
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return records.where((record) {
      final day = DateTime(record.createdAt.year, record.createdAt.month, record.createdAt.day);
      return !day.isBefore(startOfWeek) && day.isBefore(endOfWeek);
    }).toList();
  }

  Future<double> getWeeklyAverage() async {
    if (AppConfig.useRemoteBackend) {
      try {
        final response = await _moodApiService.getWeeklyStats();
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final average = data['average'];
          if (average is num) return average.toDouble();
        }
      } catch (_) {
        // Si el endpoint de estadísticas falla, se calcula con el historial remoto.
      }
    }

    final records = await getCurrentWeekRecords();
    if (records.isEmpty) return 0;

    final total = records.fold<int>(0, (sum, record) => sum + record.level);
    return total / records.length;
  }

  Future<String?> getMostFrequentMood() async {
    final records = await getMoodHistory();
    if (records.isEmpty) return null;

    final frequency = <String, int>{};
    for (final record in records) {
      frequency[record.mood] = (frequency[record.mood] ?? 0) + 1;
    }

    final sortedEntries = frequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.first.key;
  }

  Future<void> deleteMoodRecord(String recordId) async {
    if (AppConfig.useRemoteBackend) {
      try {
        await _moodApiService.deleteMoodRecord(recordId);
        return;
      } on ApiException catch (error) {
        throw MoodRepositoryException(error.message);
      } catch (_) {
        throw MoodRepositoryException('No fue posible eliminar el registro en el backend local.');
      }
    }

    final records = await _storage.getAllRecords();
    records.removeWhere((record) => record.id == recordId);
    await _storage.saveAllRecords(records);
  }

  Future<MoodRecord> _saveMoodRecordRemote({
    required String mood,
    required int level,
    required List<String> tags,
    required String note,
  }) async {
    try {
      final response = await _moodApiService.createMoodRecord({
        'mood': mood,
        'level': level,
        'tags': tags,
        'note': note.trim(),
      });

      final data = response['data'];
      if (data is Map<String, dynamic> && data['record'] is Map<String, dynamic>) {
        return MoodRecord.fromJson(data['record'] as Map<String, dynamic>);
      }

      throw MoodRepositoryException('Respuesta incompleta al guardar el registro emocional.');
    } on ApiException catch (error) {
      throw MoodRepositoryException(error.message);
    } on MoodRepositoryException {
      rethrow;
    } catch (_) {
      throw MoodRepositoryException('No fue posible conectar con el backend local para guardar el registro.');
    }
  }

  Future<List<MoodRecord>> _getMoodHistoryRemote() async {
    try {
      final response = await _moodApiService.getMoodHistory();
      final data = response['data'];

      final rawRecords = data is Map<String, dynamic> ? data['records'] : null;
      if (rawRecords is! List) return <MoodRecord>[];

      return rawRecords
          .whereType<Map<String, dynamic>>()
          .map(MoodRecord.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on ApiException catch (error) {
      throw MoodRepositoryException(error.message);
    } catch (_) {
      throw MoodRepositoryException('No fue posible cargar el historial desde el backend local.');
    }
  }

  Future<MoodRecord?> _getTodayMoodRecordRemote() async {
    try {
      final response = await _moodApiService.getTodayMood();
      final data = response['data'];

      if (data is Map<String, dynamic> && data['record'] is Map<String, dynamic>) {
        return MoodRecord.fromJson(data['record'] as Map<String, dynamic>);
      }

      return null;
    } on ApiException catch (error) {
      throw MoodRepositoryException(error.message);
    } catch (_) {
      throw MoodRepositoryException('No fue posible cargar el registro emocional de hoy.');
    }
  }

  Future<MoodRecord> _saveMoodRecordLocal({
    required String mood,
    required int level,
    required List<String> tags,
    required String note,
  }) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw MoodRepositoryException('No hay una sesión activa para guardar el registro emocional.');
    }

    final record = MoodRecord(
      id: 'mood_${DateTime.now().microsecondsSinceEpoch}',
      userId: user.id,
      mood: mood,
      level: level,
      tags: tags,
      note: note.trim(),
      createdAt: DateTime.now(),
    );

    final records = await _storage.getAllRecords();
    records.insert(0, record);
    await _storage.saveAllRecords(records);

    return record;
  }

  Future<List<MoodRecord>> _getMoodHistoryLocal() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) return <MoodRecord>[];

    final records = await _storage.getAllRecords();
    return records.where((record) => record.userId == user.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
