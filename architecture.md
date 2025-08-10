# OpenRouter Request Builder Package Architecture

## Overview

This Flutter package provides a comprehensive, reusable solution for building OpenRouter API requests with an intuitive UI interface and powerful programmatic API. The package is designed to be easily integrated into any Flutter project with minimal setup while providing extensive customization options.

## Key Features

- **Interactive Request Builder UI** with tabbed interface
- **Real-time model fetching** from OpenRouter API with caching
- **Streaming and non-streaming** API request support  
- **Code generation** for cURL, Python, and JavaScript
- **Parameter presets** for different use cases
- **Message history management** with automatic trimming
- **Comprehensive error handling** and validation
- **Offline caching** with SharedPreferences
- **Reusable across projects** with minimal integration effort

## Package Structure

```
lib/
├── models/
│   └── openrouter_models.dart           # Data models and DTOs
├── services/
│   └── openrouter_service.dart          # API service layer
├── widgets/
│   └── openrouter_request_builder.dart  # Main UI component
├── utils/
│   └── openrouter_config.dart           # Configuration helpers
├── examples/
│   └── basic_usage_example.dart         # Usage examples
├── pages/
│   └── home_page.dart                   # Demo implementation
├── openrouter_package.dart              # Main package export
└── package_documentation.dart           # Comprehensive docs
```

## Core Components

### 1. Data Models (`models/openrouter_models.dart`)

**OpenRouterModel**
- Represents available AI models from OpenRouter
- Includes pricing, context length, and capability information

**ChatMessage**
- Represents individual messages in a conversation
- Supports system, user, and assistant roles

**OpenRouterRequest**
- Complete request payload for OpenRouter API
- Includes model selection, messages, parameters, and provider preferences

**OpenRouterResponse**
- Structured response from OpenRouter API
- Includes choices, usage statistics, and metadata

**OpenRouterRequestParameters**
- Configurable request parameters (temperature, top-p, max tokens, etc.)
- Supports streaming and advanced sampling options

### 2. Service Layer (`services/openrouter_service.dart`)

**OpenRouterService** (Singleton)
- Handles all API communication with OpenRouter
- Manages API key storage and retrieval
- Provides model caching with 1-hour expiration
- Supports both streaming and non-streaming requests
- Generates code snippets in multiple languages
- Includes comprehensive error handling

Key Methods:
- `initialize()` - Load cached configuration
- `setApiKey(String)` - Store API key securely
- `fetchModels()` - Get available models with caching
- `sendChatRequest()` - Send non-streaming request
- `sendStreamingChatRequest()` - Send streaming request
- `generateCurlCommand()` - Generate cURL code
- `generatePythonCode()` - Generate Python code
- `generateJavaScriptCode()` - Generate JavaScript code

### 3. UI Components (`widgets/openrouter_request_builder.dart`)

**OpenRouterRequestBuilder**
- Main widget for building requests interactively
- Tabbed interface with three main sections:
  1. **Model & Messages** - Model selection and message composition
  2. **Parameters** - Request parameter configuration
  3. **Code Generator** - Multi-language code generation

Features:
- Real-time model loading with refresh capability
- System and user message input fields
- Parameter sliders and input fields
- Streaming toggle option
- Request validation and error display
- Responsive design for different screen sizes

### 4. Configuration Utilities (`utils/openrouter_config.dart`)

**OpenRouterConfig**
- Provides predefined configurations and helpers
- Parameter presets: creative, balanced, precise, deterministic
- System message templates for different use cases
- Popular model recommendations
- Request validation and token estimation
- Conversation history management

Key Features:
- `createStandardRequest()` - Quick request creation
- `createConversationRequest()` - Multi-turn conversations
- `validateRequest()` - Pre-send validation
- `estimateTokenCount()` - Token usage estimation

## Integration Guide

### Simple Integration (Widget-based)

```dart
import 'package:your_app/openrouter_package.dart';

// Add to your widget tree
OpenRouterRequestBuilder(
  onRequestBuilt: (request) => handleRequest(request),
  onResponse: (response) => handleResponse(response),
  onError: (error) => handleError(error),
)
```

### Advanced Integration (Service-based)

```dart
import 'package:your_app/openrouter_package.dart';

class MyApiService {
  final OpenRouterService _service = OpenRouterService();
  
  Future<void> setup() async {
    await _service.initialize();
    await _service.setApiKey('your-key');
  }
  
  Future<String> askQuestion(String question) async {
    final request = OpenRouterConfig.createStandardRequest(
      model: 'openai/gpt-4o-mini',
      userMessage: question,
      preset: 'balanced',
    );
    
    final response = await _service.sendChatRequest(request);
    return response.choices.first.message.content;
  }
}
```

## Technical Decisions

### Architecture Patterns
- **Singleton Service** - Ensures consistent API key and model caching
- **Widget Composition** - Separates UI concerns for maintainability
- **Configuration Objects** - Type-safe parameter management
- **Stream Support** - Handles real-time response streaming

### State Management
- Local widget state for UI interactions
- SharedPreferences for persistent data (API keys, cached models)
- Service layer manages API state and caching

### Error Handling
- Comprehensive try-catch blocks throughout
- User-friendly error messages
- Graceful degradation when API is unavailable
- Request validation before sending

### Performance Optimizations
- Model caching reduces API calls
- Debounced parameter updates
- Efficient widget rebuilding
- Memory-conscious message history management

## Security Considerations

- API keys stored securely in SharedPreferences
- No API keys in source code or logs
- Privacy-focused provider preferences by default
- Request validation prevents malformed payloads

## Extensibility

The package is designed for easy extension:

### Adding New Parameter Presets
```dart
OpenRouterConfig.parameterPresets['custom'] = OpenRouterRequestParameters(
  temperature: 0.5,
  maxTokens: 2000,
);
```

### Custom System Messages
```dart
OpenRouterConfig.systemMessageTemplates['myUseCase'] = 'Custom system prompt';
```

### Additional UI Components
The widget architecture allows easy addition of new tabs or sections.

## Dependencies

- `http: ^1.0.0` - HTTP client for API requests
- `shared_preferences: ^2.0.0` - Local data persistence
- `flutter/material.dart` - UI framework
- `google_fonts` (optional) - Typography

## Testing Strategy

The architecture supports easy testing:
- Service layer can be mocked for unit tests
- UI components can be tested with widget tests
- Configuration utilities have pure functions for easy testing

## Future Enhancements

Potential areas for expansion:
- Additional language code generators
- Custom model fine-tuning support
- Advanced conversation management
- Plugin system for custom processors
- Integration with other AI providers

## Conclusion

This package provides a production-ready, reusable solution for OpenRouter API integration in Flutter applications. The clean architecture, comprehensive feature set, and extensive documentation make it suitable for both simple integrations and complex AI-powered applications.