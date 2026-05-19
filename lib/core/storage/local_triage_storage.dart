import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/triage_result_model.dart';

class LocalTriageStorage {
  static const String _resultsKey = 'as_new_inmotions_triage_results';

  Future<void> saveResult(TriageResultModel result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getAllResults();
    results.insert(0, result);

    await prefs.setString(
      _resultsKey,
      jsonEncode(results.map((item) => item.toMap()).toList()),
    );
  }

  Future<List<TriageResultModel>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final rawResults = prefs.getString(_resultsKey);
    if (rawResults == null) return [];

    try {
      final decoded = jsonDecode(rawResults) as List<dynamic>;
      return decoded
          .map((item) => TriageResultModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await prefs.remove(_resultsKey);
      return [];
    }
  }


  Future<TriageResultModel?> getLatestResult() async {
    final results = await getAllResults();
    if (results.isEmpty) return null;
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.first;
  }

  Future<List<TriageResultModel>> getResultsByUser(String userId) async {
    final results = await getAllResults();
    return results.where((result) => result.userId == userId).toList();
  }

  Future<TriageResultModel?> getLatestResultByUser(String userId) async {
    final results = await getResultsByUser(userId);
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resultsKey);
  }
}
