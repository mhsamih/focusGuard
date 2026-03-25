import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

class StatsProvider extends ChangeNotifier {
  List<SessionRecord> records = [];
  int currentStreak  = 0;
  int longestStreak  = 0;
  String todayIntention = '';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('records') ?? [];
    records = raw.map((e) => SessionRecord.fromJson(jsonDecode(e))).toList();
    currentStreak  = p.getInt('currentStreak')  ?? 0;
    longestStreak  = p.getInt('longestStreak')  ?? 0;
    todayIntention = p.getString('intention')   ?? '';
    notifyListeners();
  }

  Future<void> addRecord(SessionRecord r) async {
    records.add(r);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('records',
        records.map((e) => jsonEncode(e.toJson())).toList());
    _updateStreaks(p);
    notifyListeners();
  }

  void _updateStreaks(SharedPreferences p) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final todayRecords = records.where((r) {
      final d = r.date;
      return '${d.year}-${d.month}-${d.day}' == todayStr;
    });
    final hitLimitToday = todayRecords.any((r) => r.hitLimit);
    if (!hitLimitToday) {
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
    } else {
      currentStreak = 0;
    }
    p.setInt('currentStreak', currentStreak);
    p.setInt('longestStreak', longestStreak);
  }

  // Returns seconds per day for the last 7 days
  List<Map<String, dynamic>> weeklyData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStr = '${day.year}-${day.month}-${day.day}';
      final total = records.where((r) {
        final d = r.date;
        return '${d.year}-${d.month}-${d.day}' == dayStr;
      }).fold(0, (sum, r) => sum + r.durationSeconds);
      return {'day': day, 'seconds': total};
    });
  }

  Future<void> setIntention(String intention) async {
    todayIntention = intention;
    final p = await SharedPreferences.getInstance();
    await p.setString('intention', intention);
    notifyListeners();
  }
}
