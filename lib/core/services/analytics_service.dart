import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics wrapper — tracks screen views, content opens, searches, and custom events.
///
/// Usage:
///   AnalyticsService.logScreenView('NewsList');
///   AnalyticsService.logContentOpen(type: 'news', id: 42, title: 'Breaking News');
///   AnalyticsService.logSearch(query: 'investment', results: 5);
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for GoRouter / Navigator.
  static FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a screen view.
  static Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log when user opens a content item (news, page, blog, etc).
  static Future<void> logContentOpen({
    required String type,
    required int id,
    String? title,
  }) async {
    await _analytics.logEvent(
      name: 'content_open',
      parameters: {
        'content_type': type,
        'content_id': id.toString(),
        if (title != null) 'content_title': title,
      },
    );
  }

  /// Log a search event.
  static Future<void> logSearch({
    required String query,
    int? results,
  }) async {
    await _analytics.logSearch(
      searchTerm: query,
      numberOfResults: results,
    );
  }

  /// Log contact form submission.
  static Future<void> logContactSubmit() async {
    await _analytics.logEvent(name: 'contact_form_submit');
  }

  /// Log successful login.
  static Future<void> logLogin({String method = 'cms_jwt'}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log language change.
  static Future<void> logLanguageChange(String lang) async {
    await _analytics.logEvent(
      name: 'language_change',
      parameters: {'language': lang},
    );
  }

  /// Log push notification received.
  static Future<void> logPushReceived({String? title}) async {
    await _analytics.logEvent(
      name: 'push_notification_received',
      parameters: {if (title != null) 'title': title},
    );
  }

  /// Log a generic custom event.
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set user ID for analytics.
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user property.
  static Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
