import '../../core/constants/app_config.dart';
import '../../core/models/reminder_model.dart';
import '../../core/services/reminder_api_service.dart';
import '../../core/storage/local_reminder_storage.dart';
import '../../core/utils/reminder_visuals.dart';

class ReminderRepository {
  ReminderRepository({
    LocalReminderStorage? storage,
    ReminderApiService? apiService,
  })  : _storage = storage ?? LocalReminderStorage(),
        _apiService = apiService ?? ReminderApiService();

  final LocalReminderStorage _storage;
  final ReminderApiService _apiService;

  bool get _useBackend => AppConfig.useRemoteBackend;

  Future<List<ReminderModel>> getReminders() async {
    final reminders = _useBackend ? await _getRemoteReminders() : await _storage.getReminders();
    reminders.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return reminders;
  }

  Future<ReminderModel?> getNextReminder() async {
    final reminders = (await getReminders()).where((reminder) => reminder.enabled).toList();
    if (reminders.isEmpty) return null;

    final now = DateTime.now();
    ReminderModel? next;
    Duration? shortestDifference;

    for (final reminder in reminders) {
      final nextDate = _nextDateForReminder(reminder, now);
      final difference = nextDate.difference(now);
      if (shortestDifference == null || difference < shortestDifference) {
        shortestDifference = difference;
        next = reminder;
      }
    }

    return next;
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());

    if (_useBackend) {
      final reminders = await _getRemoteReminders();
      final exists = reminders.any((item) => item.id == reminder.id);
      if (exists) {
        await _apiService.updateReminder(reminder.id, updatedReminder.toJson());
      } else {
        await _apiService.createReminder(updatedReminder.toJson());
      }
      return;
    }

    final reminders = await _storage.getReminders();
    final index = reminders.indexWhere((item) => item.id == reminder.id);

    if (index == -1) {
      reminders.add(updatedReminder);
    } else {
      reminders[index] = updatedReminder;
    }

    await _storage.saveReminders(reminders);
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    if (_useBackend) {
      await _apiService.updateReminder(id, {
        'enabled': enabled,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return;
    }

    final reminders = await _storage.getReminders();
    final index = reminders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    reminders[index] = reminders[index].copyWith(enabled: enabled, updatedAt: DateTime.now());
    await _storage.saveReminders(reminders);
  }

  Future<void> deleteReminder(String id) async {
    if (_useBackend) {
      await _apiService.deleteReminder(id);
      return;
    }

    final reminders = await _storage.getReminders();
    reminders.removeWhere((item) => item.id == id);
    await _storage.saveReminders(reminders);
  }

  Future<void> resetDefaults() async {
    if (_useBackend) {
      await _apiService.resetDefaults();
      return;
    }

    await _storage.clearReminders();
    await _storage.getReminders();
  }

  ReminderModel buildNewReminder({
    required String type,
    required int hour,
    required int minute,
    required List<int> days,
    bool enabled = true,
  }) {
    final now = DateTime.now();
    final safeDays = days.isEmpty ? const [1, 2, 3, 4, 5, 6, 7] : [...days]..sort();

    return ReminderModel(
      id: 'reminder_${now.microsecondsSinceEpoch}',
      type: type,
      title: type,
      subtitle: ReminderVisuals.defaultSubtitleForType(type),
      hour: hour,
      minute: minute,
      days: safeDays,
      enabled: enabled,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<List<ReminderModel>> _getRemoteReminders() async {
    final response = await _apiService.getReminders();
    final data = response['data'] as Map<String, dynamic>?;
    final rawReminders = data?['reminders'];
    if (rawReminders is! List) return <ReminderModel>[];
    return rawReminders
        .whereType<Map<String, dynamic>>()
        .map(ReminderModel.fromJson)
        .toList();
  }

  DateTime _nextDateForReminder(ReminderModel reminder, DateTime from) {
    for (var offset = 0; offset <= 7; offset++) {
      final candidateDay = from.add(Duration(days: offset));
      if (!reminder.days.contains(candidateDay.weekday)) continue;

      final candidate = DateTime(
        candidateDay.year,
        candidateDay.month,
        candidateDay.day,
        reminder.hour,
        reminder.minute,
      );

      if (candidate.isAfter(from)) return candidate;
    }

    final fallback = from.add(const Duration(days: 1));
    return DateTime(fallback.year, fallback.month, fallback.day, reminder.hour, reminder.minute);
  }
}
