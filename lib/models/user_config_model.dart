import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_config_model.g.dart';

@HiveType(typeId: 16)
@JsonSerializable()
class UserConfigModel {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String userName;
  
  @HiveField(2)
  final String? avatar;
  
  @HiveField(3)
  final AppSettings appSettings;
  
  @HiveField(4)
  final FilterSettings filterSettings;
  
  @HiveField(5)
  final PrivacySettings privacySettings;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;
  
  @HiveField(8)
  final String version; // 配置版本号

  UserConfigModel({
    required this.userId,
    required this.userName,
    this.avatar,
    required this.appSettings,
    required this.filterSettings,
    required this.privacySettings,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory UserConfigModel.fromJson(Map<String, dynamic> json) =>
      _$UserConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserConfigModelToJson(this);

  UserConfigModel copyWith({
    String? userId,
    String? userName,
    String? avatar,
    AppSettings? appSettings,
    FilterSettings? filterSettings,
    PrivacySettings? privacySettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? version,
  }) {
    return UserConfigModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      appSettings: appSettings ?? this.appSettings,
      filterSettings: filterSettings ?? this.filterSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

@HiveType(typeId: 17)
@JsonSerializable()
class AppSettings {
  @HiveField(0)
  final String language; // 语言设置
  
  @HiveField(1)
  final String themeMode; // 主题模式
  
  @HiveField(2)
  final String primaryColor; // 主色调
  
  @HiveField(3)
  final bool enableNotifications; // 开启通知
  
  @HiveField(4)
  final bool enableFloatingButton; // 开启悬浮按钮
  
  @HiveField(5)
  final bool enableAutoStart; // 开机自启
  
  @HiveField(6)
  final bool enableHapticFeedback; // 触觉反馈
  
  @HiveField(7)
  final double floatingButtonOpacity; // 悬浮按钮透明度
  
  @HiveField(8)
  final FloatingButtonPosition floatingButtonPosition; // 悬浮按钮位置
  
  @HiveField(9)
  final Map<String, dynamic> customSettings; // 自定义设置

  AppSettings({
    this.language = 'zh_CN',
    this.themeMode = 'system',
    this.primaryColor = '#1890FF',
    this.enableNotifications = true,
    this.enableFloatingButton = true,
    this.enableAutoStart = false,
    this.enableHapticFeedback = true,
    this.floatingButtonOpacity = 0.8,
    this.floatingButtonPosition = FloatingButtonPosition.bottomRight,
    this.customSettings = const {},
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    String? language,
    String? themeMode,
    String? primaryColor,
    bool? enableNotifications,
    bool? enableFloatingButton,
    bool? enableAutoStart,
    bool? enableHapticFeedback,
    double? floatingButtonOpacity,
    FloatingButtonPosition? floatingButtonPosition,
    Map<String, dynamic>? customSettings,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableFloatingButton: enableFloatingButton ?? this.enableFloatingButton,
      enableAutoStart: enableAutoStart ?? this.enableAutoStart,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      floatingButtonOpacity: floatingButtonOpacity ?? this.floatingButtonOpacity,
      floatingButtonPosition: floatingButtonPosition ?? this.floatingButtonPosition,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

@HiveType(typeId: 18)
enum FloatingButtonPosition {
  @HiveField(0)
  topLeft,
  
  @HiveField(1)
  topRight,
  
  @HiveField(2)
  bottomLeft,
  
  @HiveField(3)
  bottomRight,
  
  @HiveField(4)
  centerLeft,
  
  @HiveField(5)
  centerRight,
}

@HiveType(typeId: 19)
@JsonSerializable()
class FilterSettings {
  @HiveField(0)
  final FilterLevel filterLevel; // 过滤级别
  
  @HiveField(1)
  final bool enableAutoFilter; // 自动过滤
  
  @HiveField(2)
  final bool enableAutoReport; // 自动举报
  
  @HiveField(3)
  final bool enableAutoBlock; // 自动拉黑
  
  @HiveField(4)
  final double confidenceThreshold; // 置信度阈值
  
  @HiveField(5)
  final List<String> enabledContentTypes; // 启用的内容类型
  
  @HiveField(6)
  final Map<String, double> categoryWeights; // 分类权重
  
  @HiveField(7)
  final bool enableLearning; // 开启学习功能
  
  @HiveField(8)
  final int learningFrequency; // 学习频率（天）
  
  @HiveField(9)
  final bool enablePreview; // 开启预览模式
  
  @HiveField(10)
  final Map<String, dynamic> advancedSettings; // 高级设置

  FilterSettings({
    this.filterLevel = FilterLevel.balanced,
    this.enableAutoFilter = true,
    this.enableAutoReport = false,
    this.enableAutoBlock = false,
    this.confidenceThreshold = 0.7,
    this.enabledContentTypes = const ['article', 'comment'],
    this.categoryWeights = const {},
    this.enableLearning = true,
    this.learningFrequency = 7,
    this.enablePreview = false,
    this.advancedSettings = const {},
  });

  factory FilterSettings.fromJson(Map<String, dynamic> json) =>
      _$FilterSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$FilterSettingsToJson(this);

  FilterSettings copyWith({
    FilterLevel? filterLevel,
    bool? enableAutoFilter,
    bool? enableAutoReport,
    bool? enableAutoBlock,
    double? confidenceThreshold,
    List<String>? enabledContentTypes,
    Map<String, double>? categoryWeights,
    bool? enableLearning,
    int? learningFrequency,
    bool? enablePreview,
    Map<String, dynamic>? advancedSettings,
  }) {
    return FilterSettings(
      filterLevel: filterLevel ?? this.filterLevel,
      enableAutoFilter: enableAutoFilter ?? this.enableAutoFilter,
      enableAutoReport: enableAutoReport ?? this.enableAutoReport,
      enableAutoBlock: enableAutoBlock ?? this.enableAutoBlock,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      enabledContentTypes: enabledContentTypes ?? this.enabledContentTypes,
      categoryWeights: categoryWeights ?? this.categoryWeights,
      enableLearning: enableLearning ?? this.enableLearning,
      learningFrequency: learningFrequency ?? this.learningFrequency,
      enablePreview: enablePreview ?? this.enablePreview,
      advancedSettings: advancedSettings ?? this.advancedSettings,
    );
  }
}

@HiveType(typeId: 20)
enum FilterLevel {
  @HiveField(0)
  strict,    // 严格模式
  
  @HiveField(1)
  balanced,  // 平衡模式
  
  @HiveField(2)
  relaxed,   // 宽松模式
  
  @HiveField(3)
  custom,    // 自定义模式
}

@HiveType(typeId: 21)
@JsonSerializable()
class PrivacySettings {
  @HiveField(0)
  final bool enableDataCollection; // 数据收集
  
  @HiveField(1)
  final bool enableAnalytics; // 分析统计
  
  @HiveField(2)
  final bool enableCrashReporting; // 崩溃报告
  
  @HiveField(3)
  final bool enableLocalStorage; // 本地存储
  
  @HiveField(4)
  final int dataRetentionDays; // 数据保留天数
  
  @HiveField(5)
  final bool enableEncryption; // 开启加密
  
  @HiveField(6)
  final List<String> sensitiveDataTypes; // 敏感数据类型
  
  @HiveField(7)
  final Map<String, bool> permissions; // 权限设置

  PrivacySettings({
    this.enableDataCollection = true,
    this.enableAnalytics = false,
    this.enableCrashReporting = true,
    this.enableLocalStorage = true,
    this.dataRetentionDays = 30,
    this.enableEncryption = true,
    this.sensitiveDataTypes = const [],
    this.permissions = const {},
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);

  PrivacySettings copyWith({
    bool? enableDataCollection,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enableLocalStorage,
    int? dataRetentionDays,
    bool? enableEncryption,
    List<String>? sensitiveDataTypes,
    Map<String, bool>? permissions,
  }) {
    return PrivacySettings(
      enableDataCollection: enableDataCollection ?? this.enableDataCollection,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enableLocalStorage: enableLocalStorage ?? this.enableLocalStorage,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      sensitiveDataTypes: sensitiveDataTypes ?? this.sensitiveDataTypes,
      permissions: permissions ?? this.permissions,
    );
  }
}