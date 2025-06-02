import 'package:flutter/foundation.dart';

class AnalyticsService {
  // Mock analytics service - in production, you'd integrate with Firebase Analytics
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print(
        'Analytics Event: $eventName ${parameters != null ? 'with params: $parameters' : ''}',
      );
    }
    // In production, integrate with your analytics provider
  }

  static void logLogin(String method) {
    logEvent('login', parameters: {'method': method});
  }

  static void logSignup(String method) {
    logEvent('signup', parameters: {'method': method});
  }

  static void logSignout() {
    logEvent('signout');
  }

  static void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  static void logError(String errorType, String errorMessage) {
    logEvent(
      'error',
      parameters: {'error_type': errorType, 'error_message': errorMessage},
    );
  }

  static void setUserId(String userId) {
    if (kDebugMode) {
      print('Analytics: Set User ID: $userId');
    }
    // In production, set user ID in your analytics provider
  }

  static void setUserProperties(Map<String, dynamic> properties) {
    if (kDebugMode) {
      print('Analytics: Set User Properties: $properties');
    }
    // In production, set user properties in your analytics provider
  }
}
