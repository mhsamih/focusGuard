import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  int sessionLimitMinutes = 10;
  int cooldownMinutes     = 30;
  int dailyLimitMinutes  = 60;
  bool hardMode          = false;
  bool bedtimeEnabled    = false;
  TimeOfDay bedtimeStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay bedtimeEnd   = const TimeOfDay(hour: 7,  minute: 0);
  bool unlockPauseEnabled = true;
  int unlockPauseSeconds = 5;
  String protectedPin    = '';
  List<String> excludedApps = [];
  int emergencyUsedToday = 0;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    sessionLimitMinutes  = p.getInt('sessionLimit')    ?? 10;
    cooldownMinutes      = p.getInt('cooldown')        ?? 30;
    dailyLimitMinutes    = p.getInt('dailyLimit')      ?? 60;
    hardMode             = p.getBool('hardMode')       ?? false;
    bedtimeEnabled       = p.getBool('bedtimeEnabled') ?? false;
    unlockPauseEnabled   = p.getBool('unlockPause')    ?? true;
    unlockPauseSeconds   = p.getInt('unlockPauseSec')  ?? 5;
    protectedPin         = p.getString('pin')          ?? '';
    emergencyUsedToday   = p.getInt('emergencyUsed')   ?? 0;
    final bedStartH      = p.getInt('bedStartH')       ?? 22;
    final bedStartM      = p.getInt('bedStartM')       ?? 0;
    final bedEndH        = p.getInt('bedEndH')         ?? 7;
    final bedEndM        = p.getInt('bedEndM')         ?? 0;
    bedtimeStart = TimeOfDay(hour: bedStartH, minute: bedStartM);
    bedtimeEnd   = TimeOfDay(hour: bedEndH,   minute: bedEndM);
    notifyListeners();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('sessionLimit',   sessionLimitMinutes);
    await p.setInt('cooldown',       cooldownMinutes);
    await p.setInt('dailyLimit',     dailyLimitMinutes);
    await p.setBool('hardMode',      hardMode);
    await p.setBool('bedtimeEnabled',bedtimeEnabled);
    await p.setBool('unlockPause',   unlockPauseEnabled);
    await p.setInt('unlockPauseSec', unlockPauseSeconds);
    await p.setString('pin',         protectedPin);
    await p.setInt('emergencyUsed',  emergencyUsedToday);
    await p.setInt('bedStartH',      bedtimeStart.hour);
    await p.setInt('bedStartM',      bedtimeStart.minute);
    await p.setInt('bedEndH',        bedtimeEnd.hour);
    await p.setInt('bedEndM',        bedtimeEnd.minute);
    notifyListeners();
  }

  void update({
    int? sessionLimit,
    int? cooldown,
    int? dailyLimit,
    bool? hard,
    bool? bedtime,
    TimeOfDay? bedStart,
    TimeOfDay? bedEnd,
    bool? unlockPause,
    int? unlockPauseSec,
    String? pin,
  }) {
    if (sessionLimit  != null) sessionLimitMinutes  = sessionLimit;
    if (cooldown      != null) cooldownMinutes      = cooldown;
    if (dailyLimit    != null) dailyLimitMinutes    = dailyLimit;
    if (hard          != null) hardMode             = hard;
    if (bedtime       != null) bedtimeEnabled       = bedtime;
    if (bedStart      != null) bedtimeStart         = bedStart;
    if (bedEnd        != null) bedtimeEnd           = bedEnd;
    if (unlockPause   != null) unlockPauseEnabled   = unlockPause;
    if (unlockPauseSec != null) unlockPauseSeconds  = unlockPauseSec;
    if (pin           != null) protectedPin         = pin;
    save();
  }
}
