// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import './openrouter_models.dart';
import './openrouter_service.dart';

class OpenRouterRequestBuilder extends StatefulWidget {
  final String? initialApiKey;
  final future Function(OpenRouterRequest)? onRequestBuilt;
  final future Function(OpenRouterResponse)? onResponse;
  final future Function(String)? onError;

  const OpenRouterRequestBuilder({
    super.key,
    this.initialApiKey,
    this.onRequestBuilt,
    this.onResponse,
    this.onError,
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

  // Generated code
  String _generatedCode = '';
  String _selectedLanguage = 'cURL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _apiKeyController.dispose();
    _systemMessageController.dispose();
    _userMessageController.dispose();
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
    });

    try {
      final request = _buildRequest();
      widget.onRequestBuilt?.call(request);

      if (_enableStreaming) {
        // Handle streaming response
        await for (final chunk in _service.sendStreamingChatRequest(request)) {
          // You can handle streaming chunks here
          debugPrint('Streaming chunk: $chunk');
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
                      items: _models.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                model.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              if (model.description.isNotEmpty)
                                Text(
                                  model.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (model) {
                        setState(() {
                          _selectedModel = model;
                        });
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
              Text(
                'Request Parameters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Temperature
              Text('Temperature: ${_temperature.toStringAsFixed(2)}'),
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
              const SizedBox(height: 16),

              // Top P
              Text('Top P: ${_topP.toStringAsFixed(2)}'),
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
              const SizedBox(height: 16),

              // Max Tokens
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Tokens',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final tokens = int.tryParse(value) ?? 1000;
                  setState(() {
                    _maxTokens = tokens;
                  });
                },
                controller: TextEditingController(text: _maxTokens.toString()),
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
