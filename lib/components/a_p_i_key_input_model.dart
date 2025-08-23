import '/flutter_flow/flutter_flow_util.dart';
import 'a_p_i_key_input_widget.dart' show APIKeyInputWidget;
import 'package:flutter/material.dart';

class APIKeyInputModel extends FlutterFlowModel<APIKeyInputWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
