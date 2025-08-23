import '/backend/schema/structs/index.dart';
import '/components/a_p_i_key_input_widget.dart';
import '/components/model_lookup_and_selection_widget.dart';
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

  List<OpenRouterModelNamesAndIdsStruct> modelList = [];
  void addToModelList(OpenRouterModelNamesAndIdsStruct item) =>
      modelList.add(item);
  void removeFromModelList(OpenRouterModelNamesAndIdsStruct item) =>
      modelList.remove(item);
  void removeAtIndexFromModelList(int index) => modelList.removeAt(index);
  void insertAtIndexInModelList(
          int index, OpenRouterModelNamesAndIdsStruct item) =>
      modelList.insert(index, item);
  void updateModelListAtIndex(
          int index, Function(OpenRouterModelNamesAndIdsStruct) updateFn) =>
      modelList[index] = updateFn(modelList[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - validateApiKey] action in HomePage widget.
  String? validateApiKey;
  // Stores action output result for [Custom Action - fetchOpenRouterModels] action in HomePage widget.
  List<OpenRouterModelNamesAndIdsStruct>? fetchModels;
  // Model for APIKeyInput component.
  late APIKeyInputModel aPIKeyInputModel;
  // Model for ModelLookupAndSelection component.
  late ModelLookupAndSelectionModel modelLookupAndSelectionModel;
  // Stores action output result for [Custom Action - fetchOpenRouterModels] action in ModelLookupAndSelection widget.
  List<OpenRouterModelNamesAndIdsStruct>? updateModelList;
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
  // Stores action output result for [Custom Action - sendChatRequest] action in Button widget.
  String? sendMessage;

  @override
  void initState(BuildContext context) {
    aPIKeyInputModel = createModel(context, () => APIKeyInputModel());
    modelLookupAndSelectionModel =
        createModel(context, () => ModelLookupAndSelectionModel());
  }

  @override
  void dispose() {
    aPIKeyInputModel.dispose();
    modelLookupAndSelectionModel.dispose();
    textFieldSystemFocusNode?.dispose();
    textFieldSystemTextController?.dispose();

    textFieldUserFocusNode?.dispose();
    textFieldUserTextController?.dispose();
  }
}
