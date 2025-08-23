// This file contains OpenRouter error handling classes
// Note: This should be added as Custom Code File through FlutterFlow UI
// Go to Custom Code > Add Code File > Copy this content

/// Enum for different types of OpenRouter errors
enum OpenRouterErrorType {
  apiKeyMissing,
  apiKeyInvalid,
  networkError,
  apiError,
  parsingError,
  streamingError,
  unknown,
}

/// Base class for all OpenRouter-related errors
class OpenRouterError implements Exception {
  final OpenRouterErrorType type;
  final String message;
  final String? originalError;
  final int? statusCode;

  const OpenRouterError({
    required this.type,
    required this.message,
    this.originalError,
    this.statusCode,
  });

  @override
  String toString() {
    return 'OpenRouterError(${type.name}): $message${originalError != null ? ' (Original: $originalError)' : ''}';
  }

  /// User-friendly error message for display in UI
  String get userMessage {
    switch (type) {
      case OpenRouterErrorType.apiKeyMissing:
        return 'API key not configured. Please set your OpenRouter API key.';
      case OpenRouterErrorType.apiKeyInvalid:
        return 'Invalid API key. Please check your OpenRouter API key.';
      case OpenRouterErrorType.networkError:
        return 'Network connection error. Please check your internet connection.';
      case OpenRouterErrorType.apiError:
        return 'API request failed. Please try again.';
      case OpenRouterErrorType.parsingError:
        return 'Error processing server response. Please try again.';
      case OpenRouterErrorType.streamingError:
        return 'Streaming connection failed. Please try again.';
      case OpenRouterErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Factory constructors for different error types
  static OpenRouterError apiKeyMissing() => const OpenRouterError(
        type: OpenRouterErrorType.apiKeyMissing,
        message: 'API key not set. Please configure your OpenRouter API key.',
      );

  static OpenRouterError apiKeyInvalid() => const OpenRouterError(
        type: OpenRouterErrorType.apiKeyInvalid,
        message: 'Invalid API key. Please check your OpenRouter API key.',
        statusCode: 401,
      );

  static OpenRouterError networkError(String originalError) => OpenRouterError(
        type: OpenRouterErrorType.networkError,
        message: 'Network error occurred',
        originalError: originalError,
      );

  static OpenRouterError apiError({
    required String message,
    String? originalError,
    int? statusCode,
  }) =>
      OpenRouterError(
        type: OpenRouterErrorType.apiError,
        message: 'API request failed: $message',
        originalError: originalError,
        statusCode: statusCode,
      );

  static OpenRouterError parsingError(String originalError) => OpenRouterError(
        type: OpenRouterErrorType.parsingError,
        message: 'Error parsing server response',
        originalError: originalError,
      );

  static OpenRouterError streamingError({
    required String message,
    String? originalError,
    int? statusCode,
  }) =>
      OpenRouterError(
        type: OpenRouterErrorType.streamingError,
        message: 'Streaming request failed: $message',
        originalError: originalError,
        statusCode: statusCode,
      );

  static OpenRouterError unknown(String originalError) => OpenRouterError(
        type: OpenRouterErrorType.unknown,
        message: 'An unexpected error occurred',
        originalError: originalError,
      );
}

/// Helper class for error handling utilities
class OpenRouterErrorHandler {
  /// Convert HTTP status codes to appropriate error types
  static OpenRouterError fromHttpStatus(int statusCode, String message) {
    switch (statusCode) {
      case 401:
        return OpenRouterError.apiKeyInvalid();
      case 400:
      case 403:
      case 404:
      case 422:
        return OpenRouterError.apiError(
          message: message,
          statusCode: statusCode,
        );
      case 429:
        return OpenRouterError.apiError(
          message: 'Rate limit exceeded. Please wait before retrying.',
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return OpenRouterError.apiError(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return OpenRouterError.apiError(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// Handle generic exceptions and convert to OpenRouterError
  static OpenRouterError fromException(Object error, StackTrace? stackTrace) {
    if (error is OpenRouterError) {
      return error;
    }

    final errorString = error.toString();

    // Check for network-related errors
    if (errorString.contains('SocketException') ||
        errorString.contains('TimeoutException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('No address associated with hostname')) {
      return OpenRouterError.networkError(errorString);
    }

    // Check for JSON parsing errors
    if (errorString.contains('FormatException') ||
        errorString.contains('JSON') ||
        errorString.contains('parsing')) {
      return OpenRouterError.parsingError(errorString);
    }

    return OpenRouterError.unknown(errorString);
  }

  /// Check if error is retryable
  static bool isRetryable(OpenRouterError error) {
    switch (error.type) {
      case OpenRouterErrorType.networkError:
      case OpenRouterErrorType.streamingError:
        return true;
      case OpenRouterErrorType.apiError:
        // Retry on 5xx errors or rate limiting
        return error.statusCode != null &&
            (error.statusCode! >= 500 || error.statusCode == 429);
      default:
        return false;
    }
  }

  /// Get recommended retry delay in seconds
  static int getRetryDelay(OpenRouterError error, int attemptCount) {
    if (!isRetryable(error)) return 0;

    // Exponential backoff: 2^attempt seconds, max 60 seconds
    final baseDelay = error.statusCode == 429 ? 5 : 2;
    final delay = baseDelay * (1 << attemptCount);
    return delay > 60 ? 60 : delay;
  }
}
