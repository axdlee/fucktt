import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_provider_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class AIProviderModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String baseUrl;
  
  @HiveField(4)
  final String apiKey;
  
  @HiveField(5)
  final Map<String, String> headers;
  
  @HiveField(6)
  final List<ModelConfig> supportedModels;
  
  @HiveField(7)
  final bool enabled;
  
  @HiveField(8)
  final String? description;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final int priority; // 优先级，数字越小优先级越高
  
  @HiveField(12)
  final Map<String, dynamic> customConfig; // 自定义配置

  AIProviderModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.baseUrl,
    required this.apiKey,
    this.headers = const {},
    this.supportedModels = const [],
    this.enabled = true,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.priority = 0,
    this.customConfig = const {},
  });

  factory AIProviderModel.fromJson(Map<String, dynamic> json) =>
      _$AIProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIProviderModelToJson(this);

  AIProviderModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? baseUrl,
    String? apiKey,
    Map<String, String>? headers,
    List<ModelConfig>? supportedModels,
    bool? enabled,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
    Map<String, dynamic>? customConfig,
  }) {
    return AIProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      headers: headers ?? this.headers,
      supportedModels: supportedModels ?? this.supportedModels,
      enabled: enabled ?? this.enabled,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      customConfig: customConfig ?? this.customConfig,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIProviderModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 2)
@JsonSerializable()
class ModelConfig {
  @HiveField(0)
  final String modelId;
  
  @HiveField(1)
  final String displayName;
  
  @HiveField(2)
  final int maxTokens;
  
  @HiveField(3)
  final double temperature;
  
  @HiveField(4)
  final double? topP;
  
  @HiveField(5)
  final double? frequencyPenalty;
  
  @HiveField(6)
  final double? presencePenalty;
  
  @HiveField(7)
  final Map<String, dynamic> parameters;
  
  @HiveField(8)
  final bool enabled;
  
  @HiveField(9)
  final String? description;

  ModelConfig({
    required this.modelId,
    required this.displayName,
    this.maxTokens = 4096,
    this.temperature = 0.7,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.parameters = const {},
    this.enabled = true,
    this.description,
  });

  factory ModelConfig.fromJson(Map<String, dynamic> json) =>
      _$ModelConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ModelConfigToJson(this);

  ModelConfig copyWith({
    String? modelId,
    String? displayName,
    int? maxTokens,
    double? temperature,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    Map<String, dynamic>? parameters,
    bool? enabled,
    String? description,
  }) {
    return ModelConfig(
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      parameters: parameters ?? this.parameters,
      enabled: enabled ?? this.enabled,
      description: description ?? this.description,
    );
  }
}