import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'a_p_i_key_input_model.dart';
export 'a_p_i_key_input_model.dart';

class APIKeyInputWidget extends StatefulWidget {
  const APIKeyInputWidget({
    super.key,
    required this.onKeySet,
  });

  final Future Function(String apiKey)? onKeySet;

  @override
  State<APIKeyInputWidget> createState() => _APIKeyInputWidgetState();
}

class _APIKeyInputWidgetState extends State<APIKeyInputWidget> {
  late APIKeyInputModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => APIKeyInputModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OpenRouter API Key',
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Geist',
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        Container(
          width: double.infinity,
          child: TextFormField(
            controller: _model.textController,
            focusNode: _model.textFieldFocusNode,
            onChanged: (_) => EasyDebounce.debounce(
              '_model.textController',
              Duration(milliseconds: 2000),
              () => safeSetState(() {}),
            ),
            autofocus: true,
            obscureText: !_model.passwordVisibility,
            decoration: InputDecoration(
              hintText: 'Enter your OpenRouter API key',
              hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Geist',
                    letterSpacing: 0.0,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  width: 1.0,
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
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
              suffixIcon: InkWell(
                onTap: () => safeSetState(
                  () => _model.passwordVisibility = !_model.passwordVisibility,
                ),
                focusNode: FocusNode(skipTraversal: true),
                child: Icon(
                  _model.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 22.0,
                ),
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Geist',
                  letterSpacing: 0.0,
                ),
            cursorColor: FlutterFlowTheme.of(context).primary,
            validator: _model.textControllerValidator.asValidator(context),
          ),
        ),
        FFButtonWidget(
          onPressed: () async {
            await widget.onKeySet?.call(
              _model.textController.text,
            );
          },
          text: 'Set API Key',
          options: FFButtonOptions(
            width: double.infinity,
            height: 44.0,
            padding: EdgeInsets.all(8.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: FlutterFlowTheme.of(context).secondaryBackground,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Geist',
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            hoverColor: FlutterFlowTheme.of(context).primary,
            hoverTextColor: FlutterFlowTheme.of(context).info,
          ),
        ),
      ].divide(SizedBox(height: 16.0)),
    );
  }
}
