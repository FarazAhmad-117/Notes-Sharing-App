import 'package:flutter/foundation.dart';

/// Logger utility for consistent logging throughout the app
class AppLogger {
  static const String _tag = '[NotesApp]';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      if (error != null) {
        debugPrint('$_tag [DEBUG] $message');
        debugPrint('$_tag [ERROR] $error');
        if (stackTrace != null) {
          debugPrint('$_tag [STACK] $stackTrace');
        }
      } else {
        debugPrint('$_tag [DEBUG] $message');
      }
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [INFO] $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_tag [WARNING] $message');
      if (error != null) {
        debugPrint('$_tag [ERROR] $error');
      }
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag [ERROR] $message');
      if (error != null) {
        debugPrint('$_tag [ERROR DETAILS] $error');
      }
      if (stackTrace != null) {
        debugPrint('$_tag [STACK TRACE] $stackTrace');
      }
    }
  }

  /// Log authentication related messages
  static void auth(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_tag [AUTH] $message');
      if (error != null) {
        debugPrint('$_tag [AUTH ERROR] $error');
      }
    }
  }

  /// Log network related messages
  static void network(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_tag [NETWORK] $message');
      if (error != null) {
        debugPrint('$_tag [NETWORK ERROR] $error');
      }
    }
  }
}

