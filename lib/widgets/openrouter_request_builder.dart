import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promptcraft/models/openrouter_models.dart';
import 'package:promptcraft/services/openrouter_service.dart';

class OpenRouterRequestBuilder extends StatefulWidget {
  final String? initialApiKey;
  final Function(OpenRouterRequest)? onRequestBuilt;
  final Function(OpenRouterResponse)? onResponse;
  final Function(String)? onError;
  final Function(String)? onStreamingChunk;

  const OpenRouterRequestBuilder({
    super.key,
    this.initialApiKey,
    this.onRequestBuilt,
    this.onResponse,
    this.onError,
    this.onStreamingChunk,
  });

  @override
  State<OpenRouterRequestBuilder> createState() =>
      _OpenRouterRequestBuilderState();
}

class _OpenRouterRequestBuilderState extends State<OpenRouterRequestBuilder>
    with TickerProviderStateMixin {
  final OpenRouterService _service = OpenRouterService();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _systemMessageController =
      TextEditingController();
  final TextEditingController _userMessageController = TextEditingController();
  final TextEditingController _maxTokensController = TextEditingController();

  TabController? _tabController;
  List<OpenRouterModel> _models = [];
  OpenRouterModel? _selectedModel;
  bool _isLoadingModels = false;
  bool _isSendingRequest = false;
  String? _error;

  // Parameters
  double _temperature = 0.7;
  double _topP = 1.0;
  int _maxTokens = 1000;
  bool _enableStreaming = false;
  
  // Streaming response
  String _streamingResponse = '';

  // Generated code
  String _generatedCode = '';
  String _selectedLanguage = 'cURL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _maxTokensController.text = _maxTokens.toString();
    _initializeService();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _apiKeyController.dispose();
    _systemMessageController.dispose();
    _userMessageController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    if (widget.initialApiKey != null) {
      await _service.setApiKey(widget.initialApiKey!);
    }
    if (_service.hasApiKey) {
      _apiKeyController.text = _service.apiKey!;
      await _loadModels();
    }
  }

  Future<void> _loadModels() async {
    if (!_service.hasApiKey) return;

    setState(() {
      _isLoadingModels = true;
      _error = null;
    });

    try {
      final models = await _service.fetchModels();
      final popularModels = _service.getPopularModels();

      setState(() {
        _models = popularModels;
        _selectedModel = _models.isNotEmpty ? _models.first : null;
        _isLoadingModels = false;
      });

      // Update parameters for the initially selected model
      if (_selectedModel != null) {
        _updateParametersForModel(_selectedModel);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingModels = false;
      });
      widget.onError?.call(_error!);
    }
  }

  void _updateApiKey() async {
    if (_apiKeyController.text.isNotEmpty) {
      await _service.setApiKey(_apiKeyController.text);
      await _loadModels();
    }
  }

  void _updateParametersForModel(OpenRouterModel? model) {
    if (model == null) return;

    setState(() {
      // Update max tokens based on model context length
      // Reserve ~20% for the response, use 80% for context
      final contextReserved = (model.contextLength * 0.8).floor();
      _maxTokens = contextReserved.clamp(100, 8000);

      // Adjust parameters based on model characteristics
      if (model.name.toLowerCase().contains('claude')) {
        // Claude models work well with moderate temperature and high top_p
        _temperature = 0.7;
        _topP = 0.9;
      } else if (model.name.toLowerCase().contains('gpt')) {
        // GPT models work well with balanced settings
        _temperature = 0.7;
        _topP = 0.8;
      } else if (model.name.toLowerCase().contains('gemma') || model.name.toLowerCase().contains('llama')) {
        // Open-source models often need higher temperature for creativity
        _temperature = 0.8;
        _topP = 0.85;
      } else if (model.name.toLowerCase().contains('gemini')) {
        // Google models work well with lower temperature
        _temperature = 0.6;
        _topP = 0.8;
      } else {
        // Default balanced settings for unknown models
        _temperature = 0.7;
        _topP = 0.8;
      }

      // Adjust max tokens for smaller models
      if (model.contextLength < 4000) {
        _maxTokens = (_maxTokens * 0.6).floor().clamp(100, 2000);
      } else if (model.contextLength > 100000) {
        // For very large context models, allow more tokens
        _maxTokens = _maxTokens.clamp(1000, 8000);
      }

      // Update the controller to reflect the new value
      _maxTokensController.text = _maxTokens.toString();
    });
  }

  OpenRouterRequest _buildRequest() {
    final messages = <ChatMessage>[];

    if (_systemMessageController.text.isNotEmpty) {
      messages.add(
          ChatMessage(role: 'system', content: _systemMessageController.text));
    }

    if (_userMessageController.text.isNotEmpty) {
      messages
          .add(ChatMessage(role: 'user', content: _userMessageController.text));
    }

    return OpenRouterRequest(
      model: _selectedModel?.id ?? '',
      messages: messages,
      parameters: OpenRouterRequestParameters(
        temperature: _temperature,
        topP: _topP,
        maxTokens: _maxTokens,
        stream: _enableStreaming,
      ),
    );
  }

  void _generateCode() {
    final request = _buildRequest();
    String code;

    switch (_selectedLanguage) {
      case 'Python':
        code = _service.generatePythonCode(request);
        break;
      case 'JavaScript':
        code = _service.generateJavaScriptCode(request);
        break;
      default:
        code = _service.generateCurlCommand(request);
    }

    setState(() {
      _generatedCode = code;
    });
  }

  Future<void> _sendRequest() async {
    if (_selectedModel == null || _userMessageController.text.isEmpty) {
      setState(() {
        _error = 'Please select a model and enter a user message';
      });
      return;
    }

    setState(() {
      _isSendingRequest = true;
      _error = null;
      _streamingResponse = '';
    });

    try {
      final request = _buildRequest();
      widget.onRequestBuilt?.call(request);

      if (_enableStreaming) {
        // Handle streaming response
        await for (final chunk in _service.sendStreamingChatRequest(request)) {
          setState(() {
            _streamingResponse += chunk;
          });
          widget.onStreamingChunk?.call(chunk);
        }
        
        // Create a complete response object for streaming
        if (_streamingResponse.isNotEmpty) {
          final streamingResponse = OpenRouterResponse(
            id: 'streaming-${DateTime.now().millisecondsSinceEpoch}',
            object: 'chat.completion',
            created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            model: _selectedModel?.id ?? '',
            choices: [
              Choice(
                index: 0,
                message: ChatMessage(
                  role: 'assistant',
                  content: _streamingResponse,
                ),
                finishReason: 'stop',
              ),
            ],
            usage: Usage(
              promptTokens: 0, // These would normally be provided by the API
              completionTokens: 0,
              totalTokens: 0,
            ),
          );
          widget.onResponse?.call(streamingResponse);
        }
      } else {
        final response = await _service.sendChatRequest(request);
        widget.onResponse?.call(response);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onError?.call(_error!);
    } finally {
      setState(() {
        _isSendingRequest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // API Key Section
        if (!_service.hasApiKey) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'OpenRouter API Key',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your OpenRouter API key',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _updateApiKey,
                    child: const Text('Set API Key'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Main Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildModelAndMessagesTab(),
              _buildParametersTab(),
              _buildCodeGeneratorTab(),
            ],
          ),
        ),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Model & Messages'),
              Tab(text: 'Parameters'),
              Tab(text: 'Code Generator'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelAndMessagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Model Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Model Selection',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (_isLoadingModels)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadModels,
                          tooltip: 'Refresh models',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_models.isNotEmpty)
                    DropdownButtonFormField<OpenRouterModel>(
                      value: _selectedModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: _models.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  model.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (model.description.isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      model.description,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (model) {
                        setState(() {
                          _selectedModel = model;
                        });
                        _updateParametersForModel(model);
                      },
                    )
                  else if (!_isLoadingModels)
                    const Text(
                        'No models available. Please check your API key.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Messages
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _systemMessageController,
                    decoration: const InputDecoration(
                      labelText: 'System Message (Optional)',
                      hintText: 'Enter system message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _userMessageController,
                    decoration: const InputDecoration(
                      labelText: 'User Message *',
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _enableStreaming,
                        onChanged: (value) {
                          setState(() {
                            _enableStreaming = value ?? false;
                            if (!_enableStreaming) {
                              _streamingResponse = '';
                            }
                          });
                        },
                      ),
                      const Text('Enable streaming'),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isSendingRequest ? null : _sendRequest,
                        child: _isSendingRequest
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send Request'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Streaming Response Display
          if (_enableStreaming && _streamingResponse.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Streaming Response',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_isSendingRequest)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _streamingResponse,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Error Display
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParametersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Request Parameters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_selectedModel != null)
                    Text(
                      'Optimized for ${_selectedModel!.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Model context info
              if (_selectedModel != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Context Length: ${_selectedModel!.contextLength.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} tokens',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Temperature
              Row(
                children: [
                  Text('Temperature: ${_temperature.toStringAsFixed(2)}'),
                  const Spacer(),
                  Text(
                    'Creativity',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Slider(
                value: _temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
              ),
              Text(
                'Lower = more focused, Higher = more creative',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Top P
              Row(
                children: [
                  Text('Top P: ${_topP.toStringAsFixed(2)}'),
                  const Spacer(),
                  Text(
                    'Diversity',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Slider(
                value: _topP,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _topP = value;
                  });
                },
              ),
              Text(
                'Controls response diversity and randomness',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Max Tokens
              TextField(
                decoration: InputDecoration(
                  labelText: 'Max Tokens',
                  border: const OutlineInputBorder(),
                  helperText: _selectedModel != null ? 
                    'Based on ${_selectedModel!.name} context length' : 
                    'Recommended: ${_maxTokens.toString()}',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final tokens = int.tryParse(value) ?? 1000;
                  setState(() {
                    _maxTokens = tokens;
                  });
                },
                controller: _maxTokensController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Generate Code',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        items: ['cURL', 'Python', 'JavaScript']
                            .map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          _generateCode();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _generateCode,
                    child: const Text('Generate Code'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_generatedCode.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Generated $_selectedLanguage Code',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _generatedCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Code copied to clipboard')),
                            );
                          },
                          tooltip: 'Copy to clipboard',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _generatedCode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
