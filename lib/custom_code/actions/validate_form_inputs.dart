// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

/// Validate form inputs for chat request
/// Returns list of error messages, or empty list if valid
Future<List<String>> validateFormInputs(
  String model,
  String userMessage,
  double? temperature,
  double? topP,
  int? maxTokens,
  double? frequencyPenalty,
  double? presencePenalty,
  double? repetitionPenalty,
) async {
  final errors = <String>[];

  // Validate model selection
  if (model.trim().isEmpty) {
    errors.add('Please select a model');
  }

  // Validate user message
  if (userMessage.trim().isEmpty) {
    errors.add('User message cannot be empty');
  } else if (userMessage.trim().length > 50000) {
    errors.add('User message is too long (max 50,000 characters)');
  }

  // Validate temperature parameter
  if (temperature != null && !_isValidTemperature(temperature)) {
    errors.add('Temperature must be between 0.0 and 2.0');
  }

  // Validate top_p parameter
  if (topP != null && !_isValidTopP(topP)) {
    errors.add('Top P must be between 0.0 and 1.0');
  }

  // Validate max_tokens parameter
  if (maxTokens != null && !_isValidMaxTokens(maxTokens)) {
    errors.add('Max tokens must be between 1 and 100,000');
  }

  // Validate frequency_penalty parameter
  if (frequencyPenalty != null && !_isValidFrequencyPenalty(frequencyPenalty)) {
    errors.add('Frequency penalty must be between -2.0 and 2.0');
  }

  // Validate presence_penalty parameter
  if (presencePenalty != null && !_isValidPresencePenalty(presencePenalty)) {
    errors.add('Presence penalty must be between -2.0 and 2.0');
  }

  // Validate repetition_penalty parameter
  if (repetitionPenalty != null &&
      !_isValidRepetitionPenalty(repetitionPenalty)) {
    errors.add('Repetition penalty must be between 0.0 and 2.0');
  }

  return errors;
}

/// Validate temperature parameter
bool _isValidTemperature(double temperature) {
  return temperature >= 0.0 && temperature <= 2.0;
}

/// Validate top_p parameter
bool _isValidTopP(double topP) {
  return topP >= 0.0 && topP <= 1.0;
}

/// Validate max_tokens parameter
bool _isValidMaxTokens(int maxTokens) {
  return maxTokens > 0 && maxTokens <= 100000;
}

/// Validate frequency_penalty parameter
bool _isValidFrequencyPenalty(double penalty) {
  return penalty >= -2.0 && penalty <= 2.0;
}

/// Validate presence_penalty parameter
bool _isValidPresencePenalty(double penalty) {
  return penalty >= -2.0 && penalty <= 2.0;
}

/// Validate repetition_penalty parameter
bool _isValidRepetitionPenalty(double penalty) {
  return penalty >= 0.0 && penalty <= 2.0;
}
