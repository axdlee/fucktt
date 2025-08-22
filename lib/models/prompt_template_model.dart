import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prompt_template_model.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class PromptTemplateModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String template; // Prompt模板内容，支持变量占位符
  
  @HiveField(5)
  final List<String> variables; // 模板中的变量列表
  
  @HiveField(6)
  final PromptFunction function; // 功能类型
  
  @HiveField(7)
  final bool enabled;
  
  @HiveField(8)
  final bool isCustom; // 是否为用户自定义
  
  @HiveField(9)
  final String? aiProviderId; // 关联的AI服务商ID
  
  @HiveField(10)
  final String? modelId; // 指定的模型ID
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;
  
  @HiveField(13)
  final int version; // 版本号
  
  @HiveField(14)
  final Map<String, dynamic> metadata; // 元数据

  PromptTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.template,
    this.variables = const [],
    required this.function,
    this.enabled = true,
    this.isCustom = false,
    this.aiProviderId,
    this.modelId,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.metadata = const {},
  });

  factory PromptTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$PromptTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PromptTemplateModelToJson(this);

  PromptTemplateModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? template,
    List<String>? variables,
    PromptFunction? function,
    bool? enabled,
    bool? isCustom,
    String? aiProviderId,
    String? modelId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return PromptTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      template: template ?? this.template,
      variables: variables ?? this.variables,
      function: function ?? this.function,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
      aiProviderId: aiProviderId ?? this.aiProviderId,
      modelId: modelId ?? this.modelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// 根据提供的变量值生成最终的Prompt
  String generatePrompt(Map<String, String> variableValues) {
    String result = template;
    for (final variable in variables) {
      final value = variableValues[variable] ?? '';
      result = result.replaceAll('{$variable}', value);
    }
    return result;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromptTemplateModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 7)
enum PromptFunction {
  @HiveField(0)
  contentAnalysis,     // 内容分析
  
  @HiveField(1)
  valueEvaluation,     // 价值观评估
  
  @HiveField(2)
  behaviorAnalysis,    // 行为分析
  
  @HiveField(3)
  userProfiling,       // 用户画像
  
  @HiveField(4)
  contentClassification, // 内容分类
  
  @HiveField(5)
  riskAssessment,      // 风险评估
  
  @HiveField(6)
  customAnalysis,      // 自定义分析
}

@HiveType(typeId: 8)
@JsonSerializable()
class PromptExecution {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String templateId;
  
  @HiveField(2)
  final String prompt; // 生成的最终Prompt
  
  @HiveField(3)
  final String aiProviderId;
  
  @HiveField(4)
  final String modelId;
  
  @HiveField(5)
  final Map<String, String> inputVariables;
  
  @HiveField(6)
  final String? response; // AI响应
  
  @HiveField(7)
  final DateTime executedAt;
  
  @HiveField(8)
  final Duration? duration; // 执行时长
  
  @HiveField(9)
  final bool success;
  
  @HiveField(10)
  final String? errorMessage;
  
  @HiveField(11)
  final Map<String, dynamic> metadata;

  PromptExecution({
    required this.id,
    required this.templateId,
    required this.prompt,
    required this.aiProviderId,
    required this.modelId,
    required this.inputVariables,
    this.response,
    required this.executedAt,
    this.duration,
    this.success = false,
    this.errorMessage,
    this.metadata = const {},
  });

  factory PromptExecution.fromJson(Map<String, dynamic> json) =>
      _$PromptExecutionFromJson(json);

  Map<String, dynamic> toJson() => _$PromptExecutionToJson(this);

  PromptExecution copyWith({
    String? id,
    String? templateId,
    String? prompt,
    String? aiProviderId,
    String? modelId,
    Map<String, String>? inputVariables,
    String? response,
    DateTime? executedAt,
    Duration? duration,
    bool? success,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PromptExecution(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      prompt: prompt ?? this.prompt,
      aiProviderId: aiProviderId ?? this.aiProviderId,
      modelId: modelId ?? this.modelId,
      inputVariables: inputVariables ?? this.inputVariables,
      response: response ?? this.response,
      executedAt: executedAt ?? this.executedAt,
      duration: duration ?? this.duration,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}