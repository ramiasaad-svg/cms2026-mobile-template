import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics wrapper for crash reporting.
///
/// Call [CrashReporter.init] after Firebase.initializeApp() in main.dart.
/// Automatically captures Flutter errors, platform errors, and unhandled exceptions.
class CrashReporter {
  CrashReporter._();

  /// Initialize Crashlytics error handlers. Call once in main().
  static void init() {
    // Record all Flutter framework errors
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Record all platform-level errors (Dart isolate errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Manually record a non-fatal error with context.
  static Future<void> recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason ?? error.toString(),
      fatal: fatal,
    );
  }

  /// Log a message to Crashlytics (appears in crash reports as breadcrumbs).
  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }

  /// Set user identifier for crash reports.
  static Future<void> setUserId(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Set custom key-value pairs for crash context.
  static Future<void> setCustomKey(String key, Object value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Enable or disable crash reporting (e.g., for opt-out).
  static Future<void> setEnabled(bool enabled) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
  }
}
