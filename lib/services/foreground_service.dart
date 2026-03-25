import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// Top-level callback required by flutter_foreground_task
@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(FocusGuardTaskHandler());
}

class FocusGuardTaskHandler extends TaskHandler {
  int _elapsed = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _elapsed = 0;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _elapsed++;
    // Send elapsed seconds back to main isolate via sendData
    FlutterForegroundTask.sendDataToMain(_elapsed);
    FlutterForegroundTask.updateService(
      notificationTitle: 'FocusGuard Active',
      notificationText: 'Session: ${_elapsed ~/ 60}m ${_elapsed % 60}s',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class ForegroundTimerService {
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'focusguard_channel',
        channelName: 'FocusGuard Timer',
        channelDescription: 'Keeps your screen time timer running.',
        onlyAlertOnce: true,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // every 1 second
        autoRunOnBoot: true,
      ),
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: 'FocusGuard Active',
      notificationText: 'Monitoring screen time...',
      callback: startForegroundCallback,
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
