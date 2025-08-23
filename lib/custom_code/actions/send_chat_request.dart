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
import '/custom_code/openrouter_models.dart';

Future<String> sendChatRequest(
  String model,
  String userMessage,
  String? systemMessage,
  String preset,
) async {
  try {
    final service = OpenRouterService();

    // Build messages list
    final messages = <ChatMessage>[];

    // Add system message if provided
    if (systemMessage != null && systemMessage.trim().isNotEmpty) {
      messages.add(ChatMessage(
        role: 'system',
        content: systemMessage.trim(),
      ));
    }

    // Add user message
    messages.add(ChatMessage(
      role: 'user',
      content: userMessage.trim(),
    ));

    // Create parameters based on preset
    final parameters = _getPresetParameters(preset);

    // Build request
    final request = OpenRouterRequest(
      model: model,
      messages: messages,
      parameters: parameters,
    );

    final response = await service.sendChatRequest(request);

    // Extract content from response
    if (response.choices.isEmpty) {
      return 'Error: No response received from the API';
    }

    return response.choices.first.message.content;
  } catch (error) {
    // Handle all errors with user-friendly message
    return 'Error: ${error.toString()}';
  }
}

/// Get preset parameters for different conversation styles
OpenRouterRequestParameters _getPresetParameters(String preset) {
  switch (preset.toLowerCase()) {
    case 'creative':
      return OpenRouterRequestParameters(
        temperature: 1.2,
        topP: 0.9,
        frequencyPenalty: 0.1,
        presencePenalty: 0.1,
      );
    case 'balanced':
      return OpenRouterRequestParameters(
        temperature: 0.7,
        topP: 0.95,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
      );
    case 'precise':
      return OpenRouterRequestParameters(
        temperature: 0.1,
        topP: 0.1,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
      );
    default:
      return OpenRouterRequestParameters();
  }
}
