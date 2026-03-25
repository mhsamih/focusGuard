import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionState { idle, active, cooldown, focusMode, bedtimeLocked }

class SessionProvider extends ChangeNotifier {
  SessionState state         = SessionState.idle;
  int sessionSeconds         = 0;   // current session elapsed
  int cooldownSeconds        = 0;   // remaining cooldown
  int dailyTotalSeconds      = 0;   // total today
  int todayUnlockCount       = 0;
  int todayLimitHitCount     = 0;
  DateTime? cooldownEndTime;

  void startSession() {
    state          = SessionState.active;
    sessionSeconds = 0;
    todayUnlockCount++;
    notifyListeners();
  }

  void tickSession() {
    if (state != SessionState.active) return;
    sessionSeconds++;
    dailyTotalSeconds++;
    notifyListeners();
  }

  void startCooldown(int cooldownMinutes) {
    state             = SessionState.cooldown;
    cooldownSeconds   = cooldownMinutes * 60;
    cooldownEndTime   = DateTime.now().add(Duration(minutes: cooldownMinutes));
    todayLimitHitCount++;
    _persistCooldown();
    notifyListeners();
  }

  void tickCooldown() {
    if (state != SessionState.cooldown) return;
    if (cooldownSeconds > 0) {
      cooldownSeconds--;
      notifyListeners();
    } else {
      endCooldown();
    }
  }

  void endCooldown() {
    state           = SessionState.idle;
    sessionSeconds  = 0;
    cooldownEndTime = null;
    _clearCooldown();
    notifyListeners();
  }

  void startFocusMode(int minutes) {
    state           = SessionState.focusMode;
    cooldownSeconds = minutes * 60;
    notifyListeners();
  }

  void tickFocus() {
    if (state != SessionState.focusMode) return;
    if (cooldownSeconds > 0) {
      cooldownSeconds--;
      notifyListeners();
    } else {
      state = SessionState.idle;
      notifyListeners();
    }
  }

  void resetDailyStats() {
    dailyTotalSeconds  = 0;
    todayUnlockCount   = 0;
    todayLimitHitCount = 0;
    notifyListeners();
  }

  Future<void> _persistCooldown() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cooldownEnd', cooldownEndTime!.toIso8601String());
  }

  Future<void> _clearCooldown() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('cooldownEnd');
  }

  Future<void> restoreFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final end = p.getString('cooldownEnd');
    if (end != null) {
      final endTime = DateTime.parse(end);
      final remaining = endTime.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        state           = SessionState.cooldown;
        cooldownSeconds = remaining;
        cooldownEndTime = endTime;
        notifyListeners();
      } else {
        await _clearCooldown();
      }
    }
  }

  String get formattedSession {
    final m = sessionSeconds ~/ 60;
    final s = sessionSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  String get formattedCooldown {
    final m = cooldownSeconds ~/ 60;
    final s = cooldownSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  String get formattedDaily {
    final h = dailyTotalSeconds ~/ 3600;
    final m = (dailyTotalSeconds % 3600) ~/ 60;
    final s = dailyTotalSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }
}
