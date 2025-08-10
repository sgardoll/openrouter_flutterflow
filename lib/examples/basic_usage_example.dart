import 'package:flutter/material.dart';
import 'package:promptcraft/openrouter_package.dart';

/// Basic usage example of the OpenRouter Request Builder package
/// 
/// This example shows how to integrate the OpenRouterRequestBuilder
/// into your own Flutter app with minimal setup.
class BasicUsageExample extends StatefulWidget {
  const BasicUsageExample({super.key});

  @override
  State<BasicUsageExample> createState() => _BasicUsageExampleState();
}

class _BasicUsageExampleState extends State<BasicUsageExample> {
  String _lastResponseText = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenRouter API Builder Example'),
      ),
      body: Column(
        children: [
          // The main OpenRouter Request Builder widget
          Expanded(
            flex: 2,
            child: OpenRouterRequestBuilder(
              // Optional: Set initial API key if you have one
              // initialApiKey: 'your-api-key-here',
              
              // Callback when a request is built (before sending)
              onRequestBuilt: (OpenRouterRequest request) {
                debugPrint('Request built for model: ${request.model}');
                debugPrint('Messages: ${request.messages.length}');
                
                setState(() {
                  _isLoading = true;
                });
              },
              
              // Callback when a response is received
              onResponse: (OpenRouterResponse response) {
                setState(() {
                  _isLoading = false;
                  if (response.choices.isNotEmpty) {
                    _lastResponseText = response.choices.first.message.content;
                  }
                });
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Response received from ${response.model}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              
              // Callback when an error occurs
              onError: (String error) {
                setState(() {
                  _isLoading = false;
                  _lastResponseText = 'Error: $error';
                });
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
          
          // Response display area
          if (_lastResponseText.isNotEmpty) ...[
            const Divider(),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Last Response:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: SelectableText(
                            _lastResponseText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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

/// Advanced usage example showing how to use the service directly
class AdvancedUsageExample extends StatefulWidget {
  const AdvancedUsageExample({super.key});

  @override
  State<AdvancedUsageExample> createState() => _AdvancedUsageExampleState();
}

class _AdvancedUsageExampleState extends State<AdvancedUsageExample> {
  final OpenRouterService _service = OpenRouterService();
  List<OpenRouterModel> _models = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    if (_service.hasApiKey) {
      await _loadModels();
    }
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    
    try {
      final models = await _service.fetchModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading models: $e')),
      );
    }
  }

  Future<void> _sendExampleRequest() async {
    if (_models.isEmpty) return;

    final request = OpenRouterRequest(
      model: _models.first.id,
      messages: [
        const ChatMessage(role: 'user', content: 'Hello, how are you?'),
      ],
      parameters: OpenRouterRequestParameters(
        temperature: 0.7,
        maxTokens: 100,
      ),
    );

    try {
      setState(() => _isLoading = true);
      final response = await _service.sendChatRequest(request);
      setState(() => _isLoading = false);
      
      // Handle response
      if (response.choices.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Response'),
            content: Text(response.choices.first.message.content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Usage Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Direct Service Usage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API Key Set: ${_service.hasApiKey ? "Yes" : "No"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Models Loaded: ${_models.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _loadModels,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Load Models'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: (_isLoading || _models.isEmpty) ? null : _sendExampleRequest,
                          child: const Text('Send Test Request'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Models list
            if (_models.isNotEmpty) ...[
              Text(
                'Available Models (${_models.length}):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _models.length > 10 ? 10 : _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    return ListTile(
                      title: Text(model.name),
                      subtitle: Text(
                        model.description.isEmpty ? model.id : model.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('${model.contextLength}k'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}