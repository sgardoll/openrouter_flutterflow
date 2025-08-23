import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'openrouter_models.dart';
import 'openrouter_errors.dart';
import 'openrouter_config_helpers.dart';

class OpenRouterService {
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

  bool get hasApiKey => _apiKey?.isNotEmpty ?? false;

  Map<String, String> get _headers => OpenRouterApiConfig.getHeaders(_apiKey!);

  Future<List<OpenRouterModel>> fetchModels({bool forceRefresh = false}) async {
    if (!hasApiKey) {
      throw OpenRouterError.apiKeyMissing();
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
        Uri.parse(OpenRouterApiConfig.modelsEndpoint),
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
                // Skip malformed models but don't throw
                return null;
              }
            })
            .where((model) => model != null && model.id.isNotEmpty)
            .cast<OpenRouterModel>()
            .toList();

        // Sort using helper method
        _cachedModels = OpenRouterModelHelper.sortModels(_cachedModels);
        _lastModelsFetch = DateTime.now();

        return _cachedModels;
      } else {
        throw OpenRouterErrorHandler.fromHttpStatus(
          response.statusCode,
          'Failed to fetch models: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is OpenRouterError) rethrow;
      throw OpenRouterErrorHandler.fromException(e, null);
    }
  }

  Future<OpenRouterResponse> sendChatRequest(OpenRouterRequest request) async {
    if (!hasApiKey) {
      throw OpenRouterError.apiKeyMissing();
    }

    try {
      final response = await http.post(
        Uri.parse(OpenRouterApiConfig.chatEndpoint),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OpenRouterResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw OpenRouterError.apiError(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OpenRouterError) rethrow;
      throw OpenRouterErrorHandler.fromException(e, null);
    }
  }

  Stream<String> sendStreamingChatRequest(OpenRouterRequest request) async* {
    if (!hasApiKey) {
      throw OpenRouterError.apiKeyMissing();
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
      final httpRequest =
          http.Request('POST', Uri.parse(OpenRouterApiConfig.chatEndpoint));
      httpRequest.headers.addAll(_headers);
      httpRequest.body = json.encode(streamingRequest.toJson());

      final streamedResponse = await httpRequest.send();

      if (streamedResponse.statusCode == 200) {
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
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
        throw OpenRouterError.streamingError(
          message: 'Request failed with status ${streamedResponse.statusCode}',
          statusCode: streamedResponse.statusCode,
        );
      }
    } catch (e) {
      if (e is OpenRouterError) rethrow;
      throw OpenRouterError.streamingError(
        message: 'Streaming connection error',
        originalError: e.toString(),
      );
    }
  }

  List<OpenRouterModel> getPopularModels() {
    return OpenRouterModelHelper.sortModels(_cachedModels);
  }

  String generateCurlCommand(OpenRouterRequest request) {
    return OpenRouterCodeGenerator.generateCurlCommand(
        request, _apiKey ?? 'YOUR_API_KEY');
  }

  String generatePythonCode(OpenRouterRequest request) {
    return OpenRouterCodeGenerator.generatePythonCode(request);
  }

  String generateJavaScriptCode(OpenRouterRequest request) {
    return OpenRouterCodeGenerator.generateJavaScriptCode(request);
  }
}
