import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promptcraft/models/openrouter_models.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _modelsEndpoint = '$_baseUrl/models';
  static const String _chatEndpoint = '$_baseUrl/chat/completions';
  static const String _apiKeyKey = 'openrouter_api_key';

  String? _apiKey;
  List<OpenRouterModel> _cachedModels = [];
  DateTime? _lastModelsFetch;

  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  String? get apiKey => _apiKey;
  List<OpenRouterModel> get cachedModels => _cachedModels;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<void> clearApiKey() async {
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://promptcraft.app',
    'X-Title': 'PromptCraft',
  };

  Future<List<OpenRouterModel>> fetchModels({bool forceRefresh = false}) async {
    if (!hasApiKey) {
      throw Exception('API key not set. Please configure your OpenRouter API key.');
    }

    // Return cached models if available and not expired (cache for 1 hour)
    if (!forceRefresh && 
        _cachedModels.isNotEmpty && 
        _lastModelsFetch != null &&
        DateTime.now().difference(_lastModelsFetch!).inHours < 1) {
      return _cachedModels;
    }

    try {
      final response = await http.get(
        Uri.parse(_modelsEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> modelsJson = data['data'] ?? [];
        
        _cachedModels = modelsJson
            .map((json) {
              try {
                return OpenRouterModel.fromJson(json);
              } catch (e) {
                print('Error parsing model: $json - $e');
                return null;
              }
            })
            .where((model) => model != null && model.id.isNotEmpty)
            .cast<OpenRouterModel>()
            .toList();
        
        // Sort by name for better UX
        _cachedModels.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _lastModelsFetch = DateTime.now();
        
        return _cachedModels;
      } else {
        final errorMessage = response.statusCode == 401 
          ? 'Invalid API key. Please check your OpenRouter API key.'
          : 'Failed to fetch models: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error fetching models: $e');
    }
  }

  Future<OpenRouterResponse> sendChatRequest(OpenRouterRequest request) async {
    if (!hasApiKey) {
      throw Exception('API key not set. Please configure your OpenRouter API key.');
    }

    try {
      final response = await http.post(
        Uri.parse(_chatEndpoint),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OpenRouterResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('API request failed: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error sending chat request: $e');
    }
  }

  Stream<String> sendStreamingChatRequest(OpenRouterRequest request) async* {
    if (!hasApiKey) {
      throw Exception('API key not set. Please configure your OpenRouter API key.');
    }

    final streamingRequest = OpenRouterRequest(
      model: request.model,
      messages: request.messages,
      parameters: OpenRouterRequestParameters(
        temperature: request.parameters.temperature,
        topP: request.parameters.topP,
        topK: request.parameters.topK,
        frequencyPenalty: request.parameters.frequencyPenalty,
        presencePenalty: request.parameters.presencePenalty,
        repetitionPenalty: request.parameters.repetitionPenalty,
        maxTokens: request.parameters.maxTokens,
        stop: request.parameters.stop,
        seed: request.parameters.seed,
        stream: true,
      ),
      providerPreferences: request.providerPreferences,
    );

    try {
      final httpRequest = http.Request('POST', Uri.parse(_chatEndpoint));
      httpRequest.headers.addAll(_headers);
      httpRequest.body = json.encode(streamingRequest.toJson());

      final streamedResponse = await httpRequest.send();

      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ') && line != 'data: [DONE]') {
              try {
                final data = json.decode(line.substring(6));
                final content = data['choices']?[0]?['delta']?['content'];
                if (content != null) {
                  yield content;
                }
              } catch (e) {
                // Ignore malformed chunks
              }
            }
          }
        }
      } else {
        throw Exception('Streaming request failed: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in streaming request: $e');
    }
  }

  List<OpenRouterModel> getPopularModels() {
    final popularModelIds = [
      'anthropic/claude-3.5-sonnet',
      'openai/gpt-4o',
      'openai/gpt-4o-mini',
      'google/gemini-pro-1.5',
      'meta-llama/llama-3.1-8b-instruct:free',
      'microsoft/wizardlm-2-8x22b',
      'anthropic/claude-3-haiku',
      'google/gemma-2-9b-it:free',
    ];

    final popular = <OpenRouterModel>[];
    final remaining = <OpenRouterModel>[];

    for (final model in _cachedModels) {
      if (popularModelIds.contains(model.id)) {
        popular.add(model);
      } else {
        remaining.add(model);
      }
    }

    // Sort popular models by the order in popularModelIds
    popular.sort((a, b) {
      final aIndex = popularModelIds.indexOf(a.id);
      final bIndex = popularModelIds.indexOf(b.id);
      return aIndex.compareTo(bIndex);
    });

    return [...popular, ...remaining];
  }

  String generateCurlCommand(OpenRouterRequest request) {
    final requestBody = json.encode(request.toJson());
    
    return '''curl https://openrouter.ai/api/v1/chat/completions \\
  -H "Authorization: Bearer \$OPENROUTER_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '$requestBody' ''';
  }

  String generatePythonCode(OpenRouterRequest request) {
    final requestBody = json.encode(request.toJson());
    
    return '''import requests
import json

response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
    headers={
        "Authorization": "Bearer " + os.environ["OPENROUTER_API_KEY"],
        "Content-Type": "application/json"
    },
    data=json.dumps($requestBody)
)

print(response.json())''';
  }

  String generateJavaScriptCode(OpenRouterRequest request) {
    final requestBody = json.encode(request.toJson());
    
    return '''fetch("https://openrouter.ai/api/v1/chat/completions", {
  method: "POST",
  headers: {
    "Authorization": "Bearer " + process.env.OPENROUTER_API_KEY,
    "Content-Type": "application/json"
  },
  body: JSON.stringify($requestBody)
})
.then(response => response.json())
.then(data => console.log(data));''';
  }
}