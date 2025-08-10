import 'package:promptcraft/models/openrouter_models.dart';

/// Configuration class for OpenRouter package
/// Provides default settings and commonly used model configurations
class OpenRouterConfig {
  // Popular model configurations
  static const List<String> popularModels = [
    'anthropic/claude-3.5-sonnet',
    'openai/gpt-4o',
    'openai/gpt-4o-mini',
    'google/gemini-pro-1.5',
    'meta-llama/llama-3.1-8b-instruct:free',
    'microsoft/wizardlm-2-8x22b',
    'anthropic/claude-3-haiku',
    'google/gemma-2-9b-it:free',
  ];

  // Default parameter presets
  static final Map<String, OpenRouterRequestParameters> parameterPresets = {
    'creative': OpenRouterRequestParameters(
      temperature: 0.9,
      topP: 0.9,
      maxTokens: 2000,
    ),
    'balanced': OpenRouterRequestParameters(
      temperature: 0.7,
      topP: 0.8,
      maxTokens: 1500,
    ),
    'precise': OpenRouterRequestParameters(
      temperature: 0.3,
      topP: 0.6,
      maxTokens: 1000,
    ),
    'deterministic': OpenRouterRequestParameters(
      temperature: 0.0,
      topP: 0.5,
      maxTokens: 1000,
    ),
  };

  // Common system message templates
  static const Map<String, String> systemMessageTemplates = {
    'assistant':
        'You are a helpful AI assistant. Provide clear, accurate, and concise responses.',
    'creative':
        'You are a creative AI assistant. Think outside the box and provide imaginative, innovative responses.',
    'analytical':
        'You are an analytical AI assistant. Provide detailed, logical, and well-reasoned responses with supporting evidence.',
    'conversational':
        'You are a friendly, conversational AI assistant. Engage in natural dialogue and be personable.',
    'professional':
        'You are a professional AI assistant. Provide formal, business-appropriate responses with technical accuracy.',
    'educational':
        'You are an educational AI assistant. Explain concepts clearly, provide examples, and encourage learning.',
  };

  // Default model fallback order for reliability
  static const List<String> defaultModelFallbacks = [
    'openai/gpt-4o-mini',
    'anthropic/claude-3-haiku',
    'google/gemma-2-9b-it:free',
    'meta-llama/llama-3.1-8b-instruct:free',
  ];

  // Rate limiting and safety defaults
  static const int defaultMaxTokens = 1000;
  static const double defaultTemperature = 0.7;
  static const int maxHistoryLength = 10;
  static const Duration cacheExpiration = Duration(hours: 1);

  /// Creates a request with commonly used settings
  static OpenRouterRequest createStandardRequest({
    required String model,
    required String userMessage,
    String? systemMessage,
    String preset = 'balanced',
    bool streaming = false,
  }) {
    final messages = <ChatMessage>[];

    if (systemMessage != null && systemMessage.isNotEmpty) {
      messages.add(ChatMessage(role: 'system', content: systemMessage));
    }

    messages.add(ChatMessage(role: 'user', content: userMessage));

    final parameters =
        parameterPresets[preset] ?? parameterPresets['balanced']!;

    return OpenRouterRequest(
      model: model,
      messages: messages,
      parameters: OpenRouterRequestParameters(
        temperature: parameters.temperature,
        topP: parameters.topP,
        maxTokens: parameters.maxTokens,
        stream: streaming,
      ),
    );
  }

  /// Creates a conversation request with message history
  static OpenRouterRequest createConversationRequest({
    required String model,
    required List<ChatMessage> messageHistory,
    required String newMessage,
    String preset = 'balanced',
    bool streaming = false,
  }) {
    final messages = List<ChatMessage>.from(messageHistory);

    // Limit history length to prevent token overflow
    if (messages.length > maxHistoryLength) {
      // Keep system message if present, then most recent messages
      final systemMessages = messages.where((m) => m.role == 'system').toList();
      final nonSystemMessages =
          messages.where((m) => m.role != 'system').toList();

      messages.clear();
      messages.addAll(systemMessages);

      if (nonSystemMessages.length > maxHistoryLength - systemMessages.length) {
        messages.addAll(nonSystemMessages.skip(nonSystemMessages.length -
            (maxHistoryLength - systemMessages.length)));
      } else {
        messages.addAll(nonSystemMessages);
      }
    }

    messages.add(ChatMessage(role: 'user', content: newMessage));

    final parameters =
        parameterPresets[preset] ?? parameterPresets['balanced']!;

    return OpenRouterRequest(
      model: model,
      messages: messages,
      parameters: OpenRouterRequestParameters(
        temperature: parameters.temperature,
        topP: parameters.topP,
        maxTokens: parameters.maxTokens,
        stream: streaming,
      ),
    );
  }

  /// Creates provider preferences for reliability
  static ProviderPreferences createReliableProviderPreferences({
    bool allowFallbacks = true,
    List<String>? preferredProviders,
  }) {
    return ProviderPreferences(
      allowFallbacks: allowFallbacks,
      order: preferredProviders,
      dataCollection: false, // Privacy-focused default
    );
  }

  /// Validates if a model ID is in the popular/recommended list
  static bool isPopularModel(String modelId) {
    return popularModels.contains(modelId);
  }

  /// Gets a safe default model ID
  static String get defaultModel => popularModels.first;

  /// Gets the free tier models
  static List<String> get freeModels =>
      popularModels.where((model) => model.contains(':free')).toList();

  /// Estimates token count (rough approximation)
  static int estimateTokenCount(String text) {
    // Rough estimation: ~1 token per 4 characters for English text
    return (text.length / 4).ceil();
  }

  /// Validates a request before sending
  static String? validateRequest(OpenRouterRequest request) {
    if (request.model.isEmpty) {
      return 'Model is required';
    }

    if (request.messages.isEmpty) {
      return 'At least one message is required';
    }

    final totalTokens = request.messages
        .map((m) => estimateTokenCount(m.content))
        .fold(0, (sum, tokens) => sum + tokens);

    if (totalTokens > 100000) {
      return 'Message content is too long (estimated ${totalTokens} tokens)';
    }

    if (request.parameters.maxTokens != null &&
        request.parameters.maxTokens! > 8000) {
      return 'Max tokens should not exceed 8000 for most models';
    }

    return null; // Valid request
  }
}
