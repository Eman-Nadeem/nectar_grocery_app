import 'package:firebase_auth/firebase_auth.dart';
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

  /// Set User Identifier and email for crash reports cleanly
  static Future<void> setUserIdentifier(dynamic userOrUid) async {
    if (userOrUid is User) {
      await _crashlytics.setUserIdentifier(userOrUid.uid);
      if (userOrUid.email != null && userOrUid.email!.isNotEmpty) {
        await _crashlytics.setCustomKey('email', userOrUid.email!);
      }
    } else if (userOrUid is String) {
      await _crashlytics.setUserIdentifier(userOrUid);
    } else {
      await _crashlytics.setUserIdentifier('');
    }
  }

  /// Set custom key-value pairs for debugging context
  static Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Force a test crash (Use only for verifying Crashlytics setup)
  static Future<void> forceCrash() async {
    await _crashlytics.log('Test crash button tapped by user');
    await _crashlytics.recordError(
      StateError('Manual Test Error triggered via CrashlyticsService'),
      StackTrace.current,
      reason: 'Testing Crashlytics setup',
      fatal: false,
    );
    _crashlytics.crash();
  }
}
