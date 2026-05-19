import '../../core/models/reminder_model.dart';
import '../../core/storage/local_reminder_storage.dart';
import '../../core/utils/reminder_visuals.dart';

class ReminderRepository {
  ReminderRepository({LocalReminderStorage? storage}) : _storage = storage ?? LocalReminderStorage();

  final LocalReminderStorage _storage;

  Future<List<ReminderModel>> getReminders() async {
    final reminders = await _storage.getReminders();
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
    final reminders = await _storage.getReminders();
    final index = reminders.indexWhere((item) => item.id == reminder.id);
    final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());

    if (index == -1) {
      reminders.add(updatedReminder);
    } else {
      reminders[index] = updatedReminder;
    }

    await _storage.saveReminders(reminders);
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final reminders = await _storage.getReminders();
    final index = reminders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    reminders[index] = reminders[index].copyWith(enabled: enabled, updatedAt: DateTime.now());
    await _storage.saveReminders(reminders);
  }

  Future<void> deleteReminder(String id) async {
    final reminders = await _storage.getReminders();
    reminders.removeWhere((item) => item.id == id);
    await _storage.saveReminders(reminders);
  }

  Future<void> resetDefaults() async {
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
