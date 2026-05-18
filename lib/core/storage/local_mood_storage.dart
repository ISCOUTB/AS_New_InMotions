import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_record_model.dart';

class LocalMoodStorage {
  static const String _recordsKey = 'as_new_inmotions_mood_records';

  Future<List<MoodRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final rawRecords = prefs.getStringList(_recordsKey) ?? <String>[];

    return rawRecords
        .map((raw) => MoodRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAllRecords(List<MoodRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final rawRecords = records.map((record) => jsonEncode(record.toJson())).toList();
    await prefs.setStringList(_recordsKey, rawRecords);
  }

  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }
}
