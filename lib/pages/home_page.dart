import 'package:flutter/material.dart';
import 'package:promptcraft/widgets/openrouter_request_builder.dart';
import 'package:promptcraft/models/openrouter_models.dart';
import 'package:promptcraft/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OpenRouterResponse? _lastResponse;
  String? _lastError;

  void _onRequestBuilt(OpenRouterRequest request) {
    debugPrint('Request built: ${request.model}');
  }

  void _onResponse(OpenRouterResponse response) {
    setState(() {
      _lastResponse = response;
      _lastError = null;
    });

    // Show response in a dialog
    _showResponseDialog(response);
  }

  void _onError(String error) {
    setState(() {
      _lastError = error;
      _lastResponse = null;
    });

    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showResponseDialog(OpenRouterResponse response) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Response',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Model and Usage Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Model: ${response.model}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tokens: ${response.usage.promptTokens} + ${response.usage.completionTokens} = ${response.usage.totalTokens}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Response Content
                      if (response.choices.isNotEmpty) ...[
                        Text(
                          'Response:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              response.choices.first.message.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OpenRouter Demo",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: LightModeColors.lightInversePrimary,
      ),
      body: SafeArea(
        child: OpenRouterRequestBuilder(
          onRequestBuilt: _onRequestBuilt,
          onResponse: _onResponse,
          onError: _onError,
        ),
      ),
    );
  }
}
