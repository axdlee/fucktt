import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'value_template_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class ValueTemplateModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final List<String> keywords;
  
  @HiveField(5)
  final List<String> negativeKeywords;
  
  @HiveField(6)
  final double weight; // 权重，0.0-1.0
  
  @HiveField(7)
  final bool enabled;
  
  @HiveField(8)
  final bool isCustom; // 是否为用户自定义
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final int priority; // 优先级
  
  @HiveField(12)
  final Map<String, dynamic> customConfig; // 自定义配置

  ValueTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.keywords = const [],
    this.negativeKeywords = const [],
    this.weight = 0.5,
    this.enabled = true,
    this.isCustom = false,
    required this.createdAt,
    required this.updatedAt,
    this.priority = 0,
    this.customConfig = const {},
  });

  factory ValueTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$ValueTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValueTemplateModelToJson(this);

  ValueTemplateModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    List<String>? keywords,
    List<String>? negativeKeywords,
    double? weight,
    bool? enabled,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
    Map<String, dynamic>? customConfig,
  }) {
    return ValueTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      negativeKeywords: negativeKeywords ?? this.negativeKeywords,
      weight: weight ?? this.weight,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      customConfig: customConfig ?? this.customConfig,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValueTemplateModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 4)
@JsonSerializable()
class UserValuesProfile {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final Map<String, double> templateWeights; // 模板ID -> 权重
  
  @HiveField(2)
  final List<String> blacklist; // 黑名单关键词
  
  @HiveField(3)
  final List<String> whitelist; // 白名单关键词
  
  @HiveField(4)
  final Map<String, ValueCategory> customCategories; // 自定义分类
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;
  
  @HiveField(7)
  final Map<String, dynamic> preferences; // 个人偏好设置

  UserValuesProfile({
    required this.userId,
    this.templateWeights = const {},
    this.blacklist = const [],
    this.whitelist = const [],
    this.customCategories = const {},
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
  });

  factory UserValuesProfile.fromJson(Map<String, dynamic> json) =>
      _$UserValuesProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserValuesProfileToJson(this);

  UserValuesProfile copyWith({
    String? userId,
    Map<String, double>? templateWeights,
    List<String>? blacklist,
    List<String>? whitelist,
    Map<String, ValueCategory>? customCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserValuesProfile(
      userId: userId ?? this.userId,
      templateWeights: templateWeights ?? this.templateWeights,
      blacklist: blacklist ?? this.blacklist,
      whitelist: whitelist ?? this.whitelist,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

@HiveType(typeId: 5)
@JsonSerializable()
class ValueCategory {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String color; // 十六进制颜色值
  
  @HiveField(4)
  final String icon; // 图标名称或Unicode
  
  @HiveField(5)
  final int sortOrder;

  ValueCategory({
    required this.id,
    required this.name,
    required this.description,
    this.color = '#1890FF',
    this.icon = '🏷️',
    this.sortOrder = 0,
  });

  factory ValueCategory.fromJson(Map<String, dynamic> json) =>
      _$ValueCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ValueCategoryToJson(this);

  ValueCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    int? sortOrder,
  }) {
    return ValueCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}