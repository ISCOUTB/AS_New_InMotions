import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_model.dart';

class LocalReminderStorage {
  static const String _remindersKey = 'as_new_inmotions_local_reminders';

  Future<List<ReminderModel>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);

    if (raw == null || raw.isEmpty) {
      await saveReminders(_defaultReminders);
      return _defaultReminders;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((reminder) => reminder.toJson()).toList());
    await prefs.setString(_remindersKey, encoded);
  }

  Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remindersKey);
  }

  List<ReminderModel> get _defaultReminders {
    final now = DateTime.now();
    return [
      ReminderModel(
        id: 'reminder_mood_daily',
        type: 'Registrar emoción',
        title: 'Registrar emoción',
        subtitle: 'Anotar cómo te sentiste hoy',
        hour: 20,
        minute: 0,
        days: const [1, 2, 3, 4, 5, 6, 7],
        enabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      ReminderModel(
        id: 'reminder_breathing_mwf',
        type: 'Pausa de respiración',
        title: 'Pausa de respiración',
        subtitle: 'Tomar una pausa breve de 3 minutos',
        hour: 7,
        minute: 30,
        days: const [1, 3, 5],
        enabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      ReminderModel(
        id: 'reminder_sleep_night',
        type: 'Higiene del sueño',
        title: 'Higiene del sueño',
        subtitle: 'Prepararte para descansar mejor',
        hour: 21,
        minute: 30,
        days: const [1, 2, 3, 4, 5],
        enabled: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
