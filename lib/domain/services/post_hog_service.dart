import 'package:posthog_flutter/posthog_flutter.dart';
import 'dart:async';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

/// A service class to handle event tracking and user identification via PostHog.
class PostHogService {
  /// The PostHog project API token.
  static const _projectToken =
      'phc_wQyg3xoFzmk8NQYTCuTtSkWPKLdBK9h2FftP2j4UzjCv';

  /// Default US region host
  static const _host = 'https://us.i.posthog.com';

  /// Initializes the PostHog service with default configuration settings.
  Future<void> initialize() async {
    final config = PostHogConfig(_projectToken);

    config.errorTrackingConfig.captureFlutterErrors = true;
    config.errorTrackingConfig.capturePlatformDispatcherErrors = true;
    config.errorTrackingConfig.captureIsolateErrors = true;
    config.errorTrackingConfig.captureNativeExceptions = true;
    config.errorTrackingConfig.captureSilentFlutterErrors = false;

    return Posthog().setup(
      config
        // Whether the SDK emits verbose debug logs.
        ..debug = true
        // The PostHog ingestion host.
        ..host = _host
        // Whether the SDK captures application lifecycle events automatically.
        ..captureApplicationLifecycleEvents = false,
    );
  }

  /// Accessor for capturing application and system errors.
  final errors = _Errors();

  /// Accessor for identifying user sessions and properties.
  final identifies = _Identifies();

  /// Accessor for capturing custom user analytics events.
  final events = _Events();
}

/// Helper class for managing and reporting errors to PostHog.
class _Errors {
  /// Captures a Flutter/Dart exception or error along with its stack trace and custom properties.
  Future<void> error(
    Object error,
    StackTrace? stackTrace,
    Map<String, Object>? properties,
  ) {
    return Posthog().captureException(
      error: error,
      stackTrace: stackTrace,
      properties: properties,
    );
  }
}

/// Helper class for managing user identification and user-specific properties in PostHog.
class _Identifies {
  /// Identifies the user inside PostHog upon login.
  /// Sets or updates user properties and records the initial login timestamp if not already set.
  Future<void> userLoggedIn({required clerk.User user}) => Posthog().identify(
    userId: user.id,
    userProperties: {
      'username': user.username ?? 'Unknown',
      "email": user.email ?? "Unknown",
    },
    userPropertiesSetOnce: {
      "date_of_first_log_in": DateTime.now().toIso8601String(),
    },
  );
}

/// Helper class for capturing custom user interactions and gameplay events.
class _Events {
  /// Captures a user logout event and resets the PostHog session.
  Future<void> userLoggedOut() async {
    await Posthog().capture(eventName: _PostHogEvent.USER_LOGGED_OUT.title);
    await Posthog().reset();
  }

  /// Captures a gameplay completion event containing the player's score.
  Future<void> userPlayedGame({required int score}) async =>
      await Posthog().capture(
        eventName: _PostHogEvent.USER_PLAYED_GAME.title,
        properties: {'score': score},
      );
}

/// Enumeration of all analytics events captured by PostHog.
enum _PostHogEvent {
  /// Event triggered when a user completes playing a game.
  USER_PLAYED_GAME("User Played Game"),

  /// Event triggered when a user logs out.
  USER_LOGGED_OUT("User Logged Out");

  const _PostHogEvent(this.title);

  /// Human-readable title of the event sent to PostHog.
  final String title;
}
