import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics Event: $name, Params: $parameters');
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  static Future<void> logAdImpression({
    required String adUnitId,
    required String adType,
  }) async {
    await logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_unit_id': adUnitId,
        'ad_type': adType,
      },
    );
  }

  static Future<void> logAdFailed({
    required String adUnitId,
    required String error,
  }) async {
    await logEvent(
      name: 'ad_failed_to_load',
      parameters: {
        'ad_unit_id': adUnitId,
        'error': error,
      },
    );
  }

  static Future<void> logResumeCreated({
    required String targetRole,
    required String theme,
  }) async {
    await logEvent(
      name: 'resume_created',
      parameters: {
        'target_role': targetRole,
        'theme': theme,
      },
    );
  }

  static Future<void> logScreenView({
    required String screenName,
  }) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  static Future<void> logExportUnlocked() async {
    await logEvent(name: 'export_unlocked');
  }
}
