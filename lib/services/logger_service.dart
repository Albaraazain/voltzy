import 'package:flutter/foundation.dart';

class LoggerService {
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }
}
