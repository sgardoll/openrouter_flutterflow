class OpenRouterModel {
  final String id;
  final String name;
  final String description;
  final int contextLength;
  final String architecture;
  final double pricing;
  final bool isDefault;

  const OpenRouterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.contextLength,
    required this.architecture,
    required this.pricing,
    this.isDefault = false,
  });

  factory OpenRouterModel.fromJson(Map<String, dynamic> json) =>
      OpenRouterModel(
        id: json['id'] ?? '',
        name: json['name'] ?? json['id'] ?? '',
        description: json['description'] ?? '',
        contextLength: json['context_length'] ?? 0,
        architecture: json['architecture']?['tokenizer'] ?? 'Unknown',
        pricing: (json['pricing']?['prompt']?.toDouble() ?? 0.0) * 1000000,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'context_length': contextLength,
        'architecture': architecture,
        'pricing': pricing,
        'is_default': isDefault,
      };
}

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] ?? '',
        content: json['content'] ?? '',
      );
}

class OpenRouterRequestParameters {
  double? temperature;
  double? topP;
  double? topK;
  double? frequencyPenalty;
  double? presencePenalty;
  double? repetitionPenalty;
  int? maxTokens;
  List<String>? stop;
  int? seed;
  bool stream;

  OpenRouterRequestParameters({
    this.temperature,
    this.topP,
    this.topK,
    this.frequencyPenalty,
    this.presencePenalty,
    this.repetitionPenalty,
    this.maxTokens,
    this.stop,
    this.seed,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (temperature != null) json['temperature'] = temperature;
    if (topP != null) json['top_p'] = topP;
    if (topK != null) json['top_k'] = topK;
    if (frequencyPenalty != null) json['frequency_penalty'] = frequencyPenalty;
    if (presencePenalty != null) json['presence_penalty'] = presencePenalty;
    if (repetitionPenalty != null)
      json['repetition_penalty'] = repetitionPenalty;
    if (maxTokens != null) json['max_tokens'] = maxTokens;
    if (stop != null && stop!.isNotEmpty) json['stop'] = stop;
    if (seed != null) json['seed'] = seed;
    json['stream'] = stream;
    return json;
  }
}

class ProviderPreferences {
  bool allowFallbacks;
  List<String>? order;
  List<String>? require;
  bool dataCollection;

  ProviderPreferences({
    this.allowFallbacks = true,
    this.order,
    this.require,
    this.dataCollection = true,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'allow_fallbacks': allowFallbacks,
      'data_collection': dataCollection ? 'allow' : 'deny',
    };
    if (order != null && order!.isNotEmpty) json['order'] = order;
    if (require != null && require!.isNotEmpty) json['require'] = require;
    return json;
  }
}

class OpenRouterRequest {
  String model;
  List<ChatMessage> messages;
  OpenRouterRequestParameters parameters;
  ProviderPreferences? providerPreferences;

  OpenRouterRequest({
    required this.model,
    required this.messages,
    required this.parameters,
    this.providerPreferences,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      ...parameters.toJson(),
    };

    if (providerPreferences != null) {
      json['provider'] = providerPreferences!.toJson();
    }

    return json;
  }
}

class OpenRouterResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;
  final Usage usage;

  const OpenRouterResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) =>
      OpenRouterResponse(
        id: json['id'] ?? '',
        object: json['object'] ?? '',
        created: json['created'] ?? 0,
        model: json['model'] ?? '',
        choices: (json['choices'] as List?)
                ?.map((c) => Choice.fromJson(c))
                .toList() ??
            [],
        usage: Usage.fromJson(json['usage'] ?? {}),
      );
}

class Choice {
  final int index;
  final ChatMessage message;
  final String finishReason;

  const Choice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        index: json['index'] ?? 0,
        message: ChatMessage.fromJson(json['message'] ?? {}),
        finishReason: json['finish_reason'] ?? '',
      );
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        promptTokens: json['prompt_tokens'] ?? 0,
        completionTokens: json['completion_tokens'] ?? 0,
        totalTokens: json['total_tokens'] ?? 0,
      );
}
