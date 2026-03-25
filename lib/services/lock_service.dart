import 'package:device_policy_manager/device_policy_manager.dart';
import 'package:flutter/services.dart';

class LockService {
  static const _channel = MethodChannel('focusguard/lock');

  static Future<bool> requestAdminPermission() async {
    try {
      final result = await DevicePolicyManager.requestPermession(
        "FocusGuard needs Device Admin access to lock your screen when time is up."
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isAdminActive() async {
    return await DevicePolicyManager.isAdminActive() ?? false;
  }

  static Future<void> lockScreen() async {
    try {
      await DevicePolicyManager.lockScreen();
    } catch (_) {
      // Fallback: call native channel
      await _channel.invokeMethod('lockNow');
    }
  }
}
