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

/// Fetch available OpenRouter models Returns a list of model names, or empty
/// list on error
Future<List<OpenRouterModelNamesAndIdsStruct>> fetchOpenrouterModels(
    bool forceRefresh) async {
  try {
    final service = OpenRouterService();
    final models = await service.fetchModels(forceRefresh: forceRefresh);

    return models
        .map((model) => OpenRouterModelNamesAndIdsStruct(
              modelName: model.name,
              modelId: model.id,
            ))
        .toList();
  } catch (error) {
    // Handle all errors gracefully - return empty list so UI doesn't crash
    print('Error fetching models: $error');
    return [];
  }
}
