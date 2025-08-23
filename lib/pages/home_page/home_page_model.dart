import '/components/a_p_i_key_input_widget.dart';
import '/components/model_lookup_and_selection_widget.dart';
import '/components/parameters_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  List<String> modelList = [];
  void addToModelList(String item) => modelList.add(item);
  void removeFromModelList(String item) => modelList.remove(item);
  void removeAtIndexFromModelList(int index) => modelList.removeAt(index);
  void insertAtIndexInModelList(int index, String item) =>
      modelList.insert(index, item);
  void updateModelListAtIndex(int index, Function(String) updateFn) =>
      modelList[index] = updateFn(modelList[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Class Method - OpenRouterService.fetchModels] action in HomePage widget.
  List<OpenRouterModel>? getAlModelsOnLaunch;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for APIKeyInput component.
  late APIKeyInputModel aPIKeyInputModel;
  // Model for ModelLookupAndSelection component.
  late ModelLookupAndSelectionModel modelLookupAndSelectionModel;
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
    aPIKeyInputModel = createModel(context, () => APIKeyInputModel());
    modelLookupAndSelectionModel =
        createModel(context, () => ModelLookupAndSelectionModel());
    parametersModel = createModel(context, () => ParametersModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    aPIKeyInputModel.dispose();
    modelLookupAndSelectionModel.dispose();
    textFieldSystemFocusNode?.dispose();
    textFieldSystemTextController?.dispose();

    textFieldUserFocusNode?.dispose();
    textFieldUserTextController?.dispose();

    parametersModel.dispose();
  }
}
