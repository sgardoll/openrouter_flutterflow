import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/openrouter_config.dart';
import 'package:flutter/material.dart';
import 'model_lookup_and_selection_model.dart';
export 'model_lookup_and_selection_model.dart';

class ModelLookupAndSelectionWidget extends StatefulWidget {
  const ModelLookupAndSelectionWidget({
    super.key,
    required this.getOpenRouterModelsList,
  });

  final List<String>? getOpenRouterModelsList;

  @override
  State<ModelLookupAndSelectionWidget> createState() =>
      _ModelLookupAndSelectionWidgetState();
}

class _ModelLookupAndSelectionWidgetState
    extends State<ModelLookupAndSelectionWidget> {
  late ModelLookupAndSelectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModelLookupAndSelectionModel());
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
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Model Selection',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Geist',
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                _model.updatePage(() {});
              },
              child: Icon(
                Icons.refresh_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
            ),
          ],
        ),
        FlutterFlowDropDown<String>(
          controller: _model.dropDownModelsAvailableValueController ??=
              FormFieldController<String>(
            _model.dropDownModelsAvailableValue ??=
                OpenRouterConfig.defaultModel,
          ),
          options: widget.getOpenRouterModelsList!,
          onChanged: (val) =>
              safeSetState(() => _model.dropDownModelsAvailableValue = val),
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 44.0,
          searchHintTextStyle:
              FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Geist',
                    letterSpacing: 0.0,
                  ),
          searchTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Geist',
                letterSpacing: 0.0,
              ),
          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Geist',
                letterSpacing: 0.0,
              ),
          hintText: 'Select OpenRouter Model...',
          searchHintText: 'Search...',
          searchCursorColor: FlutterFlowTheme.of(context).primary,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 2.0,
          borderColor: FlutterFlowTheme.of(context).alternate,
          borderWidth: 0.0,
          borderRadius: 8.0,
          margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: true,
          isMultiSelect: false,
        ),
      ].divide(SizedBox(height: 12.0)),
    );
  }
}
