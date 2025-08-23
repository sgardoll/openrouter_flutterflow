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

/// Custom widget for OpenRouter message input with validation
class OpenRouterMessageInput extends StatefulWidget {
  const OpenRouterMessageInput({
    super.key,
    this.width,
    this.height,
    required this.onMessageChanged,
    this.placeholder = 'Enter your message...',
    this.initialValue = '',
    this.minLines = 3,
    this.maxLines = 6,
    this.maxCharacters = 50000,
    this.showCharacterCount = true,
  });

  final double? width;
  final double? height;
  final Future Function(String message) onMessageChanged;
  final String placeholder;
  final String initialValue;
  final int minLines;
  final int maxLines;
  final int maxCharacters;
  final bool showCharacterCount;

  @override
  State<OpenRouterMessageInput> createState() => _OpenRouterMessageInputState();
}

class _OpenRouterMessageInputState extends State<OpenRouterMessageInput> {
  late TextEditingController _controller;
  String _errorMessage = '';
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _characterCount = widget.initialValue.length;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final text = _controller.text;
    final newCharacterCount = text.length;

    setState(() {
      _characterCount = newCharacterCount;

      // Validate character count
      if (newCharacterCount > widget.maxCharacters) {
        _errorMessage =
            'Message too long (${newCharacterCount}/${widget.maxCharacters} characters)';
      } else {
        _errorMessage = '';
      }
    });

    // Call the callback with the current text
    await widget.onMessageChanged(text);
  }

  Color get _borderColor {
    if (_errorMessage.isNotEmpty) {
      return FlutterFlowTheme.of(context).error;
    }
    return FlutterFlowTheme.of(context).alternate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text input field
          Flexible(
            child: TextFormField(
              controller: _controller,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              style: FlutterFlowTheme.of(context).bodyLarge,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _borderColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(16.0),
              ),
            ),
          ),

          const SizedBox(height: 8.0),

          // Bottom row with character count and error message
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Error message
              if (_errorMessage.isNotEmpty)
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).error,
                        ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),

              // Character count
              if (widget.showCharacterCount)
                Text(
                  '$_characterCount/${widget.maxCharacters}',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: _characterCount > widget.maxCharacters
                            ? FlutterFlowTheme.of(context).error
                            : FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
