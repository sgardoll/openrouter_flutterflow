/// A comprehensive Flutter package for building OpenRouter API requests
/// 
/// This package provides:
/// - Model fetching and caching from OpenRouter API
/// - Interactive request builder UI
/// - Support for streaming and non-streaming requests
/// - Code generation for multiple languages (cURL, Python, JavaScript)
/// - Complete request/response handling
/// 
/// Usage:
/// ```dart
/// import 'package:your_app/openrouter_package.dart';
/// 
/// // In your widget:
/// OpenRouterRequestBuilder(
///   onRequestBuilt: (request) => print('Request: ${request.model}'),
///   onResponse: (response) => print('Response: ${response.choices.first.message.content}'),
///   onError: (error) => print('Error: $error'),
/// )
/// ```

library openrouter_package;

// Export all public classes and widgets
export 'models/openrouter_models.dart';
export 'services/openrouter_service.dart';
export 'widgets/openrouter_request_builder.dart';
export 'utils/openrouter_config.dart';

// Additional utility exports for convenience
export 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
export 'package:http/http.dart' show Response;