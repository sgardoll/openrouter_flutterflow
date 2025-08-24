// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/openrouter_service.dart';
import '/custom_code/openrouter_errors.dart';

/// Validate OpenRouter API key Returns error message if invalid, or empty
/// string if valid
Future<String> validateApiKey(String apiKey) async {
  if (apiKey.trim().isEmpty) {
    return 'API key cannot be empty';
  }

  if (!apiKey.startsWith('sk-or-')) {
    return 'Invalid API key format. OpenRouter keys start with "sk-or-"';
  }

  try {
    final service = OpenRouterService();
    await service.setApiKey(apiKey);

    // Test the key by fetching models (with cache disabled)
    await service.fetchModels(forceRefresh: true);

    return ''; // Empty string means valid
  } on OpenRouterError catch (error) {
    if (error.type == OpenRouterErrorType.apiKeyInvalid) {
      return 'Invalid API key. Please check your OpenRouter API key.';
    } else {
      return error.userMessage;
    }
  } catch (error) {
    return 'Unable to validate API key. Please check your internet connection.';
  }
}
