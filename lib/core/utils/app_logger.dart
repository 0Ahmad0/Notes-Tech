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

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final StringBuffer buffer = StringBuffer(message);
    if (error != null) {
      buffer.write(' | $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    _write('ERROR', buffer.toString());
  }

  void _write(String level, String message) {
    if (kDebugMode) {
      debugPrint('[$scope][$level] $message');
    }
  }
}
