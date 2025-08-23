import '/flutter_flow/flutter_flow_util.dart';
import 'parameters_widget.dart' show ParametersWidget;
import 'package:flutter/material.dart';

class ParametersModel extends FlutterFlowModel<ParametersWidget> {
  ///  Local state fields for this component.

  double temperatureUserSet = 0.7;

  int maxTokensUserInput = 1000;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Slider widget.
  double? sliderValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
