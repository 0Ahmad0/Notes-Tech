import 'package:flutter/foundation.dart';

final class AppLogger {
  const AppLogger(this.scope);

  final String scope;

  void info(String message) {
    _write('INFO', message);
  }

  void warning(String message) {
    _write('WARN', message);
  }

  void error(String message, [Object? error]) {
    _write(
      'ERROR',
      error == null ? message : '$message | ${error.runtimeType}',
    );
  }

  void _write(String level, String message) {
    if (kDebugMode) {
      debugPrint('[$scope][$level] $message');
    }
  }
}
