import 'dart:async';
import '../services/logger_service.dart';

class RetryHelper {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);

  /// Executes an async operation with retry logic
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
    Duration? delay,
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration currentDelay = delay ?? initialDelay;

    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (e is! Exception ||
            attempts >= maxAttempts ||
            shouldRetry?.call(e) == false) {
          LoggerService.error(
            'Operation failed after $attempts attempts',
            e,
            StackTrace.current,
          );
          rethrow;
        }

        LoggerService.warning(
          'Operation failed (Attempt $attempts/$maxAttempts). Retrying in ${currentDelay.inSeconds}s. Error: ${e.toString()}',
        );

        await Future.delayed(currentDelay);
        currentDelay *= 2; // Exponential backoff
      }
    }
  }

  /// Determines if an exception is retryable
  static bool isRetryableException(Exception e) {
    // Add specific exception types that should be retried
    return e.toString().toLowerCase().contains('network') ||
        e.toString().toLowerCase().contains('timeout') ||
        e.toString().toLowerCase().contains('connection') ||
        e.toString().toLowerCase().contains('unavailable');
  }
}
