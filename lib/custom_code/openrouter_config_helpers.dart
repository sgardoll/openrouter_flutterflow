// OpenRouter Configuration Helpers
// Note: This should be added as Custom Code File through FlutterFlow UI
// Go to Custom Code > Add Code File > Copy this content

import 'openrouter_models.dart';

/// Configuration helper for OpenRouter API settings
class OpenRouterApiConfig {
  static const String baseUrl = 'https://openrouter.ai/api/v1';
  static const String modelsEndpoint = '$baseUrl/models';
  static const String chatEndpoint = '$baseUrl/chat/completions';

  /// Model cache duration in hours
  static const int modelCacheDurationHours = 1;

  /// Default headers for API requests
  static Map<String, String> getHeaders(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://promptcraft.app',
      'X-Title': 'PromptCraft',
    };
  }
}

/// Parameter validation helper
class OpenRouterParameterValidator {
  /// Validate temperature parameter
  static bool isValidTemperature(double temperature) {
    return temperature >= 0.0 && temperature <= 2.0;
  }

  /// Validate top_p parameter
  static bool isValidTopP(double topP) {
    return topP >= 0.0 && topP <= 1.0;
  }

  /// Validate max_tokens parameter
  static bool isValidMaxTokens(int maxTokens) {
    return maxTokens > 0 && maxTokens <= 100000;
  }

  /// Validate frequency_penalty parameter
  static bool isValidFrequencyPenalty(double penalty) {
    return penalty >= -2.0 && penalty <= 2.0;
  }

  /// Validate presence_penalty parameter
  static bool isValidPresencePenalty(double penalty) {
    return penalty >= -2.0 && penalty <= 2.0;
  }

  /// Validate repetition_penalty parameter
  static bool isValidRepetitionPenalty(double penalty) {
    return penalty >= 0.0 && penalty <= 2.0;
  }

  /// Validate all parameters in a request
  static List<String> validateParameters(OpenRouterRequestParameters params) {
    final errors = <String>[];

    if (params.temperature != null &&
        !isValidTemperature(params.temperature!)) {
      errors.add('Temperature must be between 0.0 and 2.0');
    }

    if (params.topP != null && !isValidTopP(params.topP!)) {
      errors.add('Top P must be between 0.0 and 1.0');
    }

    if (params.maxTokens != null && !isValidMaxTokens(params.maxTokens!)) {
      errors.add('Max tokens must be between 1 and 100,000');
    }

    if (params.frequencyPenalty != null &&
        !isValidFrequencyPenalty(params.frequencyPenalty!)) {
      errors.add('Frequency penalty must be between -2.0 and 2.0');
    }

    if (params.presencePenalty != null &&
        !isValidPresencePenalty(params.presencePenalty!)) {
      errors.add('Presence penalty must be between -2.0 and 2.0');
    }

    if (params.repetitionPenalty != null &&
        !isValidRepetitionPenalty(params.repetitionPenalty!)) {
      errors.add('Repetition penalty must be between 0.0 and 2.0');
    }

    return errors;
  }
}

/// Request builder helper
class OpenRouterRequestBuilder {
  /// Build a standard chat request
  static OpenRouterRequest buildChatRequest({
    required String model,
    required String userMessage,
    String? systemMessage,
    OpenRouterRequestParameters? parameters,
    ProviderPreferences? providerPreferences,
  }) {
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

    return OpenRouterRequest(
      model: model,
      messages: messages,
      parameters: parameters ?? OpenRouterRequestParameters(),
      providerPreferences: providerPreferences,
    );
  }

  /// Create default parameters for different presets
  static OpenRouterRequestParameters getPresetParameters(String preset) {
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
}

/// Response helper utilities
class OpenRouterResponseHelper {
  /// Extract content from response safely
  static String extractContent(OpenRouterResponse response) {
    if (response.choices.isEmpty) {
      return '';
    }

    return response.choices.first.message?.content ?? '';
  }

  /// Check if response indicates an error
  static bool hasError(OpenRouterResponse response) {
    return response.choices.isEmpty ||
        response.choices.first.finishReason == 'error';
  }

  /// Get error message from response if available
  static String? getErrorMessage(OpenRouterResponse response) {
    if (!hasError(response)) {
      return null;
    }

    return 'API returned empty response or error';
  }

  /// Calculate estimated tokens used (rough estimation)
  static int estimateTokensUsed(String text) {
    // Rough estimation: 1 token ≈ 4 characters for English text
    return (text.length / 4).ceil();
  }

  /// Format usage information for display
  static String formatUsageInfo(Usage usage) {
    final prompt = usage.promptTokens;
    final completion = usage.completionTokens;
    final total = usage.totalTokens;

    return 'Tokens used: $prompt (prompt) + $completion (completion) = $total (total)';
  }
}

/// Model management helper
class OpenRouterModelHelper {
  /// Popular model IDs for quick access
  static const List<String> popularModelIds = [
    'anthropic/claude-3.5-sonnet',
    'openai/gpt-4o',
    'openai/gpt-4o-mini',
    'google/gemini-pro-1.5',
    'meta-llama/llama-3.1-8b-instruct:free',
    'microsoft/wizardlm-2-8x22b',
    'anthropic/claude-3-haiku',
    'google/gemma-2-9b-it:free',
  ];

  /// Check if a model is free to use
  static bool isFreeModel(OpenRouterModel model) {
    return model.id.contains(':free') || model.pricing == 0.0;
  }

  /// Get model category based on provider
  static String getModelCategory(OpenRouterModel model) {
    final id = model.id.toLowerCase();

    if (id.contains('anthropic')) return 'Anthropic';
    if (id.contains('openai')) return 'OpenAI';
    if (id.contains('google')) return 'Google';
    if (id.contains('meta')) return 'Meta';
    if (id.contains('microsoft')) return 'Microsoft';
    if (id.contains('mistral')) return 'Mistral';

    return 'Other';
  }

  /// Sort models by preference (popular first, then alphabetical)
  static List<OpenRouterModel> sortModels(List<OpenRouterModel> models) {
    final popular = <OpenRouterModel>[];
    final others = <OpenRouterModel>[];

    for (final model in models) {
      if (popularModelIds.contains(model.id)) {
        popular.add(model);
      } else {
        others.add(model);
      }
    }

    // Sort popular by predefined order
    popular.sort((a, b) {
      final aIndex = popularModelIds.indexOf(a.id);
      final bIndex = popularModelIds.indexOf(b.id);
      return aIndex.compareTo(bIndex);
    });

    // Sort others alphabetically
    others.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return [...popular, ...others];
  }
}

/// Code generation helper for API examples
class OpenRouterCodeGenerator {
  /// Generate cURL command for a request
  static String generateCurlCommand(OpenRouterRequest request, String apiKey) {
    final requestBody = request.toJson();
    final bodyJson = requestBody.toString().replaceAll("'", '"');

    return '''curl https://openrouter.ai/api/v1/chat/completions \\
  -H "Authorization: Bearer $apiKey" \\
  -H "Content-Type: application/json" \\
  -d '$bodyJson' ''';
  }

  /// Generate Python code for a request
  static String generatePythonCode(OpenRouterRequest request) {
    final requestBody = request.toJson();
    final bodyJson = requestBody.toString().replaceAll("'", '"');

    return '''import requests
import json
import os

response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
    headers={
        "Authorization": "Bearer " + os.environ["OPENROUTER_API_KEY"],
        "Content-Type": "application/json"
    },
    data=json.dumps($bodyJson)
)

print(response.json())''';
  }

  /// Generate JavaScript code for a request
  static String generateJavaScriptCode(OpenRouterRequest request) {
    final requestBody = request.toJson();
    final bodyJson = requestBody.toString().replaceAll("'", '"');

    return '''fetch("https://openrouter.ai/api/v1/chat/completions", {
  method: "POST",
  headers: {
    "Authorization": "Bearer " + process.env.OPENROUTER_API_KEY,
    "Content-Type": "application/json"
  },
  body: JSON.stringify($bodyJson)
})
.then(response => response.json())
.then(data => console.log(data));''';
  }
}
