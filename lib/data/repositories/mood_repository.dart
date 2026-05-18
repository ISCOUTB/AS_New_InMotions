import '../../core/models/mood_record_model.dart';
import '../../core/storage/local_mood_storage.dart';
import '../../core/utils/date_formatter.dart';
import 'auth_repository.dart';

class MoodRepository {
  MoodRepository({LocalMoodStorage? storage, AuthRepository? authRepository})
      : _storage = storage ?? LocalMoodStorage(),
        _authRepository = authRepository ?? AuthRepository();

  final LocalMoodStorage _storage;
  final AuthRepository _authRepository;

  Future<MoodRecord> saveMoodRecord({
    required String mood,
    required int level,
    required List<String> tags,
    required String note,
  }) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('No hay una sesión activa para guardar el registro emocional.');
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

  Future<List<MoodRecord>> getMoodHistory() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) return <MoodRecord>[];

    final records = await _storage.getAllRecords();
    return records.where((record) => record.userId == user.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<MoodRecord?> getTodayMoodRecord() async {
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
    final records = await _storage.getAllRecords();
    records.removeWhere((record) => record.id == recordId);
    await _storage.saveAllRecords(records);
  }
}
