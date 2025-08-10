/// # OpenRouter Request Builder Package
/// 
/// A comprehensive Flutter package for building and executing OpenRouter API requests
/// with an intuitive UI interface and powerful programmatic API.
/// 
/// ## Features
/// 
/// - ✅ **Interactive Request Builder UI** - Build requests visually with tabs for models, messages, parameters, and code generation
/// - ✅ **Real-time Model Fetching** - Automatically fetch and cache available models from OpenRouter API
/// - ✅ **Streaming Support** - Handle both regular and streaming API responses
/// - ✅ **Code Generation** - Generate cURL, Python, and JavaScript code from your requests
/// - ✅ **Parameter Presets** - Predefined configurations for creative, balanced, precise, and deterministic responses
/// - ✅ **Message History Management** - Handle conversation contexts with automatic history trimming
/// - ✅ **Error Handling** - Comprehensive error handling with user-friendly messages
/// - ✅ **Offline Caching** - Cache models and API keys locally with SharedPreferences
/// - ✅ **Validation** - Built-in request validation and token estimation
/// 
/// ## Quick Start
/// 
/// ### 1. Basic Widget Usage
/// 
/// ```dart
/// import 'package:your_app/openrouter_package.dart';
/// 
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('OpenRouter Builder')),
///       body: OpenRouterRequestBuilder(
///         onRequestBuilt: (request) {
///           print('Built request for model: ${request.model}');
///         },
///         onResponse: (response) {
///           print('Response: ${response.choices.first.message.content}');
///         },
///         onError: (error) {
///           print('Error: $error');
///         },
///       ),
///     );
///   }
/// }
/// ```
/// 
/// ### 2. Direct Service Usage
/// 
/// ```dart
/// import 'package:your_app/openrouter_package.dart';
/// 
/// class ApiService {
///   final OpenRouterService _service = OpenRouterService();
///   
///   Future<void> sendMessage(String message) async {
///     // Initialize and set API key
///     await _service.initialize();
///     await _service.setApiKey('your-api-key-here');
///     
///     // Fetch available models
///     final models = await _service.fetchModels();
///     
///     // Create a request using configuration helpers
///     final request = OpenRouterConfig.createStandardRequest(
///       model: models.first.id,
///       userMessage: message,
///       systemMessage: OpenRouterConfig.systemMessageTemplates['assistant'],
///       preset: 'balanced',
///     );
///     
///     // Send the request
///     final response = await _service.sendChatRequest(request);
///     print(response.choices.first.message.content);
///   }
/// }
/// ```
/// 
/// ### 3. Streaming Responses
/// 
/// ```dart
/// import 'package:your_app/openrouter_package.dart';
/// 
/// class StreamingExample {
///   final OpenRouterService _service = OpenRouterService();
///   
///   Future<void> streamResponse(String message) async {
///     final request = OpenRouterConfig.createStandardRequest(
///       model: 'openai/gpt-4o-mini',
///       userMessage: message,
///       streaming: true,
///     );
///     
///     await for (final chunk in _service.sendStreamingChatRequest(request)) {
///       print(chunk); // Print each token as it arrives
///     }
///   }
/// }
/// ```
/// 
/// ## Configuration Options
/// 
/// ### Parameter Presets
/// 
/// Use predefined parameter configurations:
/// 
/// ```dart
/// // Creative responses (high temperature)
/// OpenRouterConfig.parameterPresets['creative']
/// 
/// // Balanced responses (default)
/// OpenRouterConfig.parameterPresets['balanced']
/// 
/// // Precise responses (low temperature)
/// OpenRouterConfig.parameterPresets['precise']
/// 
/// // Deterministic responses (temperature = 0)
/// OpenRouterConfig.parameterPresets['deterministic']
/// ```
/// 
/// ### System Message Templates
/// 
/// Predefined system messages for different use cases:
/// 
/// ```dart
/// OpenRouterConfig.systemMessageTemplates['assistant']     // General helper
/// OpenRouterConfig.systemMessageTemplates['creative']      // Creative tasks
/// OpenRouterConfig.systemMessageTemplates['analytical']    // Analysis tasks
/// OpenRouterConfig.systemMessageTemplates['professional']  // Business contexts
/// OpenRouterConfig.systemMessageTemplates['educational']   // Learning contexts
/// ```
/// 
/// ## Core Classes
/// 
/// ### OpenRouterService
/// 
/// The main service class for API interactions:
/// 
/// - `initialize()` - Initialize the service and load cached API key
/// - `setApiKey(String key)` - Set and persist API key
/// - `fetchModels()` - Fetch available models from OpenRouter
/// - `sendChatRequest(OpenRouterRequest)` - Send a single request
/// - `sendStreamingChatRequest(OpenRouterRequest)` - Send a streaming request
/// 
/// ### OpenRouterRequestBuilder
/// 
/// The main UI widget with these key features:
/// 
/// - **Model & Messages Tab** - Select models and compose messages
/// - **Parameters Tab** - Adjust temperature, top-p, max tokens, etc.
/// - **Code Generator Tab** - Generate implementation code in multiple languages
/// - **Real-time validation** - Immediate feedback on request validity
/// 
/// ### OpenRouterRequest
/// 
/// The main request object containing:
/// 
/// - `model` - Selected model ID
/// - `messages` - List of ChatMessage objects
/// - `parameters` - OpenRouterRequestParameters with all API parameters
/// - `providerPreferences` - Optional provider routing preferences
/// 
/// ### OpenRouterResponse
/// 
/// The response object containing:
/// 
/// - `choices` - List of response choices from the model
/// - `usage` - Token usage information
/// - `model` - The actual model that handled the request
/// 
/// ## Advanced Features
/// 
/// ### Custom Request Building
/// 
/// ```dart
/// final request = OpenRouterRequest(
///   model: 'anthropic/claude-3.5-sonnet',
///   messages: [
///     ChatMessage(role: 'system', content: 'You are an expert coder.'),
///     ChatMessage(role: 'user', content: 'Write a Python function to sort a list.'),
///   ],
///   parameters: OpenRouterRequestParameters(
///     temperature: 0.3,
///     maxTokens: 1000,
///     topP: 0.8,
///   ),
///   providerPreferences: ProviderPreferences(
///     allowFallbacks: true,
///     dataCollection: false,
///   ),
/// );
/// ```
/// 
/// ### Conversation Management
/// 
/// ```dart
/// // Maintain conversation history
/// List<ChatMessage> conversationHistory = [];
/// 
/// // Add messages to history
/// conversationHistory.add(ChatMessage(role: 'user', content: 'Hello!'));
/// conversationHistory.add(ChatMessage(role: 'assistant', content: 'Hi there!'));
/// 
/// // Create new request with history
/// final request = OpenRouterConfig.createConversationRequest(
///   model: 'openai/gpt-4o',
///   messageHistory: conversationHistory,
///   newMessage: 'How are you today?',
/// );
/// ```
/// 
/// ### Request Validation
/// 
/// ```dart
/// // Validate before sending
/// final error = OpenRouterConfig.validateRequest(request);
/// if (error != null) {
///   print('Invalid request: $error');
///   return;
/// }
/// 
/// // Estimate token usage
/// final tokenCount = OpenRouterConfig.estimateTokenCount('Your message here');
/// print('Estimated tokens: $tokenCount');
/// ```
/// 
/// ## Dependencies
/// 
/// Add these to your `pubspec.yaml`:
/// 
/// ```yaml
/// dependencies:
///   http: ^1.0.0
///   shared_preferences: ^2.0.0
///   flutter:
///     sdk: flutter
/// ```
/// 
/// ## Package Structure
/// 
/// ```
/// lib/
/// ├── models/
/// │   └── openrouter_models.dart      # Data models and request/response classes
/// ├── services/
/// │   └── openrouter_service.dart     # API service and business logic
/// ├── widgets/
/// │   └── openrouter_request_builder.dart  # Main UI widget
/// ├── utils/
/// │   └── openrouter_config.dart      # Configuration helpers and presets
/// ├── examples/
/// │   └── basic_usage_example.dart    # Usage examples
/// └── openrouter_package.dart         # Main package export file
/// ```
/// 
/// ## Best Practices
/// 
/// 1. **API Key Security** - Store API keys securely and never commit them to version control
/// 2. **Error Handling** - Always implement proper error handling for network requests
/// 3. **Token Management** - Monitor token usage to manage costs effectively
/// 4. **Model Selection** - Choose appropriate models based on your use case and budget
/// 5. **Caching** - Leverage the built-in model caching to reduce API calls
/// 
/// ## Contributing
/// 
/// This package is designed to be easily extensible. Key areas for customization:
/// 
/// - Add new parameter presets in `OpenRouterConfig`
/// - Extend the UI with additional tabs or features
/// - Add support for new OpenRouter API features
/// - Implement custom response processors
/// 
/// The architecture separates concerns cleanly:
/// - Models handle data structure
/// - Services handle API communication
/// - Widgets handle UI presentation
/// - Utils provide configuration and helpers

library package_documentation;