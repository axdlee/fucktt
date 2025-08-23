// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromptTemplateModelAdapter extends TypeAdapter<PromptTemplateModel> {
  @override
  final int typeId = 6;

  @override
  PromptTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromptTemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      template: fields[4] as String,
      variables: (fields[5] as List).cast<String>(),
      function: fields[6] as PromptFunction,
      enabled: fields[7] as bool,
      isCustom: fields[8] as bool,
      aiProviderId: fields[9] as String?,
      modelId: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      version: fields[13] as int,
      metadata: (fields[14] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PromptTemplateModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.template)
      ..writeByte(5)
      ..write(obj.variables)
      ..writeByte(6)
      ..write(obj.function)
      ..writeByte(7)
      ..write(obj.enabled)
      ..writeByte(8)
      ..write(obj.isCustom)
      ..writeByte(9)
      ..write(obj.aiProviderId)
      ..writeByte(10)
      ..write(obj.modelId)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.version)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PromptExecutionAdapter extends TypeAdapter<PromptExecution> {
  @override
  final int typeId = 8;

  @override
  PromptExecution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromptExecution(
      id: fields[0] as String,
      templateId: fields[1] as String,
      prompt: fields[2] as String,
      aiProviderId: fields[3] as String,
      modelId: fields[4] as String,
      inputVariables: (fields[5] as Map).cast<String, String>(),
      response: fields[6] as String?,
      executedAt: fields[7] as DateTime,
      duration: fields[8] as Duration?,
      success: fields[9] as bool,
      errorMessage: fields[10] as String?,
      metadata: (fields[11] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PromptExecution obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.templateId)
      ..writeByte(2)
      ..write(obj.prompt)
      ..writeByte(3)
      ..write(obj.aiProviderId)
      ..writeByte(4)
      ..write(obj.modelId)
      ..writeByte(5)
      ..write(obj.inputVariables)
      ..writeByte(6)
      ..write(obj.response)
      ..writeByte(7)
      ..write(obj.executedAt)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.success)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptExecutionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PromptFunctionAdapter extends TypeAdapter<PromptFunction> {
  @override
  final int typeId = 7;

  @override
  PromptFunction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PromptFunction.contentAnalysis;
      case 1:
        return PromptFunction.valueEvaluation;
      case 2:
        return PromptFunction.behaviorAnalysis;
      case 3:
        return PromptFunction.userProfiling;
      case 4:
        return PromptFunction.contentClassification;
      case 5:
        return PromptFunction.riskAssessment;
      case 6:
        return PromptFunction.customAnalysis;
      default:
        return PromptFunction.contentAnalysis;
    }
  }

  @override
  void write(BinaryWriter writer, PromptFunction obj) {
    switch (obj) {
      case PromptFunction.contentAnalysis:
        writer.writeByte(0);
        break;
      case PromptFunction.valueEvaluation:
        writer.writeByte(1);
        break;
      case PromptFunction.behaviorAnalysis:
        writer.writeByte(2);
        break;
      case PromptFunction.userProfiling:
        writer.writeByte(3);
        break;
      case PromptFunction.contentClassification:
        writer.writeByte(4);
        break;
      case PromptFunction.riskAssessment:
        writer.writeByte(5);
        break;
      case PromptFunction.customAnalysis:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptTemplateModel _$PromptTemplateModelFromJson(Map<String, dynamic> json) =>
    PromptTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      template: json['template'] as String,
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      function: $enumDecode(_$PromptFunctionEnumMap, json['function']),
      enabled: json['enabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
      aiProviderId: json['aiProviderId'] as String?,
      modelId: json['modelId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PromptTemplateModelToJson(
        PromptTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'template': instance.template,
      'variables': instance.variables,
      'function': _$PromptFunctionEnumMap[instance.function]!,
      'enabled': instance.enabled,
      'isCustom': instance.isCustom,
      'aiProviderId': instance.aiProviderId,
      'modelId': instance.modelId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
      'metadata': instance.metadata,
    };

const _$PromptFunctionEnumMap = {
  PromptFunction.contentAnalysis: 'contentAnalysis',
  PromptFunction.valueEvaluation: 'valueEvaluation',
  PromptFunction.behaviorAnalysis: 'behaviorAnalysis',
  PromptFunction.userProfiling: 'userProfiling',
  PromptFunction.contentClassification: 'contentClassification',
  PromptFunction.riskAssessment: 'riskAssessment',
  PromptFunction.customAnalysis: 'customAnalysis',
};

PromptExecution _$PromptExecutionFromJson(Map<String, dynamic> json) =>
    PromptExecution(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      prompt: json['prompt'] as String,
      aiProviderId: json['aiProviderId'] as String,
      modelId: json['modelId'] as String,
      inputVariables: Map<String, String>.from(json['inputVariables'] as Map),
      response: json['response'] as String?,
      executedAt: DateTime.parse(json['executedAt'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PromptExecutionToJson(PromptExecution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'prompt': instance.prompt,
      'aiProviderId': instance.aiProviderId,
      'modelId': instance.modelId,
      'inputVariables': instance.inputVariables,
      'response': instance.response,
      'executedAt': instance.executedAt.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'success': instance.success,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };
