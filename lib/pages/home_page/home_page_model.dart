import '/components/parameters_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/openrouter_config.dart';
import '/custom_code/openrouter_models.dart';
import '/custom_code/openrouter_service.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  OpenRouterService? openrouterService;

  OpenRouterConfig? openrouterConfig;

  ChatMessage? openRouterModel;

  List<ChatMessage> chatMessages = [];
  void addToChatMessages(ChatMessage item) => chatMessages.add(item);
  void removeFromChatMessages(ChatMessage item) => chatMessages.remove(item);
  void removeAtIndexFromChatMessages(int index) => chatMessages.removeAt(index);
  void insertAtIndexInChatMessages(int index, ChatMessage item) =>
      chatMessages.insert(index, item);
  void updateChatMessagesAtIndex(int index, Function(ChatMessage) updateFn) =>
      chatMessages[index] = updateFn(chatMessages[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Class Method - OpenRouterService.fetchModels] action in HomePage widget.
  List<OpenRouterModel>? getModelsOnPageLaunch;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for TextFieldSystem widget.
  FocusNode? textFieldSystemFocusNode;
  TextEditingController? textFieldSystemTextController;
  String? Function(BuildContext, String?)?
      textFieldSystemTextControllerValidator;
  // State field(s) for TextFieldUser widget.
  FocusNode? textFieldUserFocusNode;
  TextEditingController? textFieldUserTextController;
  String? Function(BuildContext, String?)? textFieldUserTextControllerValidator;
  // State field(s) for CheckboxStreaming widget.
  bool? checkboxStreamingValue;
  // Stores action output result for [Custom Class Method - OpenRouterConfig.createStandardRequest] action in Button widget.
  OpenRouterRequest? createStandardRequest;
  // Stores action output result for [Custom Class Method - OpenRouterService.sendChatRequest] action in Button widget.
  OpenRouterResponse? sendChatRequest;
  // Model for Parameters component.
  late ParametersModel parametersModel;

  @override
  void initState(BuildContext context) {
    parametersModel = createModel(context, () => ParametersModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    textFieldFocusNode?.dispose();
    textController1?.dispose();

    textFieldSystemFocusNode?.dispose();
    textFieldSystemTextController?.dispose();

    textFieldUserFocusNode?.dispose();
    textFieldUserTextController?.dispose();

    parametersModel.dispose();
  }
}
