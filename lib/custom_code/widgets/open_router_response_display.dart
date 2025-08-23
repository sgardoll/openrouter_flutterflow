// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';

/// Custom widget for displaying OpenRouter API responses with copy
/// functionality
class OpenRouterResponseDisplay extends StatefulWidget {
  const OpenRouterResponseDisplay({
    super.key,
    this.width,
    this.height,
    required this.responseText,
    this.title = 'Response',
    this.showCopyButton = true,
    this.isLoading = false,
    this.loadingText = 'Generating response...',
    this.errorText = '',
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  final double? width;
  final double? height;
  final String responseText;
  final String title;
  final bool showCopyButton;
  final bool isLoading;
  final String loadingText;
  final String errorText;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  State<OpenRouterResponseDisplay> createState() =>
      _OpenRouterResponseDisplayState();
}

class _OpenRouterResponseDisplayState extends State<OpenRouterResponseDisplay> {
  bool _showCopiedFeedback = false;

  Future<void> _copyToClipboard() async {
    if (widget.responseText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: widget.responseText));

      setState(() {
        _showCopiedFeedback = true;
      });

      // Hide feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCopiedFeedback = false;
          });
        }
      });
    }
  }

  Widget _buildContent() {
    if (widget.errorText.isNotEmpty) {
      return _buildErrorContent();
    } else if (widget.isLoading) {
      return _buildLoadingContent();
    } else if (widget.responseText.isEmpty) {
      return _buildEmptyContent();
    } else {
      return _buildResponseContent();
    }
  }

  Widget _buildErrorContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
        border: Border.all(
          color: FlutterFlowTheme.of(context).error.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: FlutterFlowTheme.of(context).error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.errorText,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    color: FlutterFlowTheme.of(context).error,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.loadingText,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No response yet',
            style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to get started',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and copy button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: FlutterFlowTheme.of(context).headlineSmall,
            ),
            if (widget.showCopyButton)
              IconButton(
                onPressed: _copyToClipboard,
                icon: Icon(
                  _showCopiedFeedback ? Icons.check : Icons.copy,
                  size: 20,
                ),
                color: _showCopiedFeedback
                    ? FlutterFlowTheme.of(context).success
                    : FlutterFlowTheme.of(context).secondaryText,
                tooltip: _showCopiedFeedback ? 'Copied!' : 'Copy response',
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Response text
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              widget.responseText,
              style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 400,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: _buildContent(),
    );
  }
}
