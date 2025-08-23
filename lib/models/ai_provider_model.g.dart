// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIProviderModelAdapter extends TypeAdapter<AIProviderModel> {
  @override
  final int typeId = 1;

  @override
  AIProviderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIProviderModel(
      id: fields[0] as String,
      name: fields[1] as String,
      displayName: fields[2] as String,
      baseUrl: fields[3] as String,
      apiKey: fields[4] as String,
      headers: (fields[5] as Map).cast<String, String>(),
      supportedModels: (fields[6] as List).cast<ModelConfig>(),
      enabled: fields[7] as bool,
      description: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      priority: fields[11] as int,
      customConfig: (fields[12] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AIProviderModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.baseUrl)
      ..writeByte(4)
      ..write(obj.apiKey)
      ..writeByte(5)
      ..write(obj.headers)
      ..writeByte(6)
      ..write(obj.supportedModels)
      ..writeByte(7)
      ..write(obj.enabled)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.customConfig);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIProviderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModelConfigAdapter extends TypeAdapter<ModelConfig> {
  @override
  final int typeId = 2;

  @override
  ModelConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModelConfig(
      modelId: fields[0] as String,
      displayName: fields[1] as String,
      maxTokens: fields[2] as int,
      temperature: fields[3] as double,
      topP: fields[4] as double?,
      frequencyPenalty: fields[5] as double?,
      presencePenalty: fields[6] as double?,
      parameters: (fields[7] as Map).cast<String, dynamic>(),
      enabled: fields[8] as bool,
      description: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ModelConfig obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.modelId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.maxTokens)
      ..writeByte(3)
      ..write(obj.temperature)
      ..writeByte(4)
      ..write(obj.topP)
      ..writeByte(5)
      ..write(obj.frequencyPenalty)
      ..writeByte(6)
      ..write(obj.presencePenalty)
      ..writeByte(7)
      ..write(obj.parameters)
      ..writeByte(8)
      ..write(obj.enabled)
      ..writeByte(9)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIProviderModel _$AIProviderModelFromJson(Map<String, dynamic> json) =>
    AIProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      supportedModels: (json['supportedModels'] as List<dynamic>?)
              ?.map((e) => ModelConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      customConfig: json['customConfig'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AIProviderModelToJson(AIProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'headers': instance.headers,
      'supportedModels': instance.supportedModels,
      'enabled': instance.enabled,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'priority': instance.priority,
      'customConfig': instance.customConfig,
    };

ModelConfig _$ModelConfigFromJson(Map<String, dynamic> json) => ModelConfig(
      modelId: json['modelId'] as String,
      displayName: json['displayName'] as String,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 4096,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble(),
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble(),
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ModelConfigToJson(ModelConfig instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'displayName': instance.displayName,
      'maxTokens': instance.maxTokens,
      'temperature': instance.temperature,
      'topP': instance.topP,
      'frequencyPenalty': instance.frequencyPenalty,
      'presencePenalty': instance.presencePenalty,
      'parameters': instance.parameters,
      'enabled': instance.enabled,
      'description': instance.description,
    };
