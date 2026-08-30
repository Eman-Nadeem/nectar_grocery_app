import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Log a custom message to Crashlytics
  static Future<void> log(String message) async {
    debugPrint('[Crashlytics] $message');
    await _crashlytics.log(message);
  }

  /// Record a non-fatal error or exception with stack trace
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    debugPrint('[Crashlytics Error] $exception');
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      fatal: fatal,
    );
  }

  /// Set User Identifier for crash reports
  static Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  /// Set custom key-value pairs for debugging context
  static Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Force a test crash (Use only for verifying Crashlytics setup)
  static void forceCrash() {
    _crashlytics.crash();
  }
}
