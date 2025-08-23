// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OpenRouterModelNamesAndIdsStruct extends BaseStruct {
  OpenRouterModelNamesAndIdsStruct({
    String? modelName,
    String? modelId,
  })  : _modelName = modelName,
        _modelId = modelId;

  // "modelName" field.
  String? _modelName;
  String get modelName => _modelName ?? '';
  set modelName(String? val) => _modelName = val;

  bool hasModelName() => _modelName != null;

  // "modelId" field.
  String? _modelId;
  String get modelId => _modelId ?? '';
  set modelId(String? val) => _modelId = val;

  bool hasModelId() => _modelId != null;

  static OpenRouterModelNamesAndIdsStruct fromMap(Map<String, dynamic> data) =>
      OpenRouterModelNamesAndIdsStruct(
        modelName: data['modelName'] as String?,
        modelId: data['modelId'] as String?,
      );

  static OpenRouterModelNamesAndIdsStruct? maybeFromMap(dynamic data) => data
          is Map
      ? OpenRouterModelNamesAndIdsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'modelName': _modelName,
        'modelId': _modelId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'modelName': serializeParam(
          _modelName,
          ParamType.String,
        ),
        'modelId': serializeParam(
          _modelId,
          ParamType.String,
        ),
      }.withoutNulls;

  static OpenRouterModelNamesAndIdsStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      OpenRouterModelNamesAndIdsStruct(
        modelName: deserializeParam(
          data['modelName'],
          ParamType.String,
          false,
        ),
        modelId: deserializeParam(
          data['modelId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'OpenRouterModelNamesAndIdsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OpenRouterModelNamesAndIdsStruct &&
        modelName == other.modelName &&
        modelId == other.modelId;
  }

  @override
  int get hashCode => const ListEquality().hash([modelName, modelId]);
}

OpenRouterModelNamesAndIdsStruct createOpenRouterModelNamesAndIdsStruct({
  String? modelName,
  String? modelId,
}) =>
    OpenRouterModelNamesAndIdsStruct(
      modelName: modelName,
      modelId: modelId,
    );
