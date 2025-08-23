import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'model_lookup_and_selection_model.dart';
export 'model_lookup_and_selection_model.dart';

class ModelLookupAndSelectionWidget extends StatefulWidget {
  const ModelLookupAndSelectionWidget({
    super.key,
    required this.getOpenRouterModels,
    required this.updateModelList,
  });

  final List<OpenRouterModelNamesAndIdsStruct>? getOpenRouterModels;
  final Future Function()? updateModelList;

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
            FlutterFlowIconButton(
              borderColor: FlutterFlowTheme.of(context).alternate,
              borderRadius: 8.0,
              buttonSize: 40.0,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              icon: Icon(
                Icons.refresh_sharp,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              showLoadingIndicator: true,
              onPressed: () async {
                await widget.updateModelList?.call();
              },
            ),
          ],
        ),
        FlutterFlowDropDown<String>(
          controller: _model.dropDownModelsAvailableValueController ??=
              FormFieldController<String>(
            _model.dropDownModelsAvailableValue ??= '',
          ),
          options: List<String>.from(
              widget.getOpenRouterModels!.map((e) => e.modelId).toList()),
          optionLabels:
              widget.getOpenRouterModels!.map((e) => e.modelName).toList(),
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
