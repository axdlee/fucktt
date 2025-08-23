// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserConfigModelAdapter extends TypeAdapter<UserConfigModel> {
  @override
  final int typeId = 16;

  @override
  UserConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserConfigModel(
      userId: fields[0] as String,
      userName: fields[1] as String,
      avatar: fields[2] as String?,
      appSettings: fields[3] as AppSettings,
      filterSettings: fields[4] as FilterSettings,
      privacySettings: fields[5] as PrivacySettings,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      version: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserConfigModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.appSettings)
      ..writeByte(4)
      ..write(obj.filterSettings)
      ..writeByte(5)
      ..write(obj.privacySettings)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 17;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      language: fields[0] as String,
      themeMode: fields[1] as String,
      primaryColor: fields[2] as String,
      enableNotifications: fields[3] as bool,
      enableFloatingButton: fields[4] as bool,
      enableAutoStart: fields[5] as bool,
      enableHapticFeedback: fields[6] as bool,
      floatingButtonOpacity: fields[7] as double,
      floatingButtonPosition: fields[8] as FloatingButtonPosition,
      customSettings: (fields[9] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.primaryColor)
      ..writeByte(3)
      ..write(obj.enableNotifications)
      ..writeByte(4)
      ..write(obj.enableFloatingButton)
      ..writeByte(5)
      ..write(obj.enableAutoStart)
      ..writeByte(6)
      ..write(obj.enableHapticFeedback)
      ..writeByte(7)
      ..write(obj.floatingButtonOpacity)
      ..writeByte(8)
      ..write(obj.floatingButtonPosition)
      ..writeByte(9)
      ..write(obj.customSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FilterSettingsAdapter extends TypeAdapter<FilterSettings> {
  @override
  final int typeId = 19;

  @override
  FilterSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilterSettings(
      filterLevel: fields[0] as FilterLevel,
      enableAutoFilter: fields[1] as bool,
      enableAutoReport: fields[2] as bool,
      enableAutoBlock: fields[3] as bool,
      confidenceThreshold: fields[4] as double,
      enabledContentTypes: (fields[5] as List).cast<String>(),
      categoryWeights: (fields[6] as Map).cast<String, double>(),
      enableLearning: fields[7] as bool,
      learningFrequency: fields[8] as int,
      enablePreview: fields[9] as bool,
      advancedSettings: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FilterSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.filterLevel)
      ..writeByte(1)
      ..write(obj.enableAutoFilter)
      ..writeByte(2)
      ..write(obj.enableAutoReport)
      ..writeByte(3)
      ..write(obj.enableAutoBlock)
      ..writeByte(4)
      ..write(obj.confidenceThreshold)
      ..writeByte(5)
      ..write(obj.enabledContentTypes)
      ..writeByte(6)
      ..write(obj.categoryWeights)
      ..writeByte(7)
      ..write(obj.enableLearning)
      ..writeByte(8)
      ..write(obj.learningFrequency)
      ..writeByte(9)
      ..write(obj.enablePreview)
      ..writeByte(10)
      ..write(obj.advancedSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivacySettingsAdapter extends TypeAdapter<PrivacySettings> {
  @override
  final int typeId = 21;

  @override
  PrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivacySettings(
      enableDataCollection: fields[0] as bool,
      enableAnalytics: fields[1] as bool,
      enableCrashReporting: fields[2] as bool,
      enableLocalStorage: fields[3] as bool,
      dataRetentionDays: fields[4] as int,
      enableEncryption: fields[5] as bool,
      sensitiveDataTypes: (fields[6] as List).cast<String>(),
      permissions: (fields[7] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.enableDataCollection)
      ..writeByte(1)
      ..write(obj.enableAnalytics)
      ..writeByte(2)
      ..write(obj.enableCrashReporting)
      ..writeByte(3)
      ..write(obj.enableLocalStorage)
      ..writeByte(4)
      ..write(obj.dataRetentionDays)
      ..writeByte(5)
      ..write(obj.enableEncryption)
      ..writeByte(6)
      ..write(obj.sensitiveDataTypes)
      ..writeByte(7)
      ..write(obj.permissions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FloatingButtonPositionAdapter
    extends TypeAdapter<FloatingButtonPosition> {
  @override
  final int typeId = 18;

  @override
  FloatingButtonPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FloatingButtonPosition.topLeft;
      case 1:
        return FloatingButtonPosition.topRight;
      case 2:
        return FloatingButtonPosition.bottomLeft;
      case 3:
        return FloatingButtonPosition.bottomRight;
      case 4:
        return FloatingButtonPosition.centerLeft;
      case 5:
        return FloatingButtonPosition.centerRight;
      default:
        return FloatingButtonPosition.topLeft;
    }
  }

  @override
  void write(BinaryWriter writer, FloatingButtonPosition obj) {
    switch (obj) {
      case FloatingButtonPosition.topLeft:
        writer.writeByte(0);
        break;
      case FloatingButtonPosition.topRight:
        writer.writeByte(1);
        break;
      case FloatingButtonPosition.bottomLeft:
        writer.writeByte(2);
        break;
      case FloatingButtonPosition.bottomRight:
        writer.writeByte(3);
        break;
      case FloatingButtonPosition.centerLeft:
        writer.writeByte(4);
        break;
      case FloatingButtonPosition.centerRight:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloatingButtonPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FilterLevelAdapter extends TypeAdapter<FilterLevel> {
  @override
  final int typeId = 20;

  @override
  FilterLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FilterLevel.strict;
      case 1:
        return FilterLevel.balanced;
      case 2:
        return FilterLevel.relaxed;
      case 3:
        return FilterLevel.custom;
      default:
        return FilterLevel.strict;
    }
  }

  @override
  void write(BinaryWriter writer, FilterLevel obj) {
    switch (obj) {
      case FilterLevel.strict:
        writer.writeByte(0);
        break;
      case FilterLevel.balanced:
        writer.writeByte(1);
        break;
      case FilterLevel.relaxed:
        writer.writeByte(2);
        break;
      case FilterLevel.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserConfigModel _$UserConfigModelFromJson(Map<String, dynamic> json) =>
    UserConfigModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatar: json['avatar'] as String?,
      appSettings:
          AppSettings.fromJson(json['appSettings'] as Map<String, dynamic>),
      filterSettings: FilterSettings.fromJson(
          json['filterSettings'] as Map<String, dynamic>),
      privacySettings: PrivacySettings.fromJson(
          json['privacySettings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: json['version'] as String,
    );

Map<String, dynamic> _$UserConfigModelToJson(UserConfigModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'avatar': instance.avatar,
      'appSettings': instance.appSettings,
      'filterSettings': instance.filterSettings,
      'privacySettings': instance.privacySettings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
    };

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      language: json['language'] as String? ?? 'zh_CN',
      themeMode: json['themeMode'] as String? ?? 'system',
      primaryColor: json['primaryColor'] as String? ?? '#1890FF',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableFloatingButton: json['enableFloatingButton'] as bool? ?? true,
      enableAutoStart: json['enableAutoStart'] as bool? ?? false,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      floatingButtonOpacity:
          (json['floatingButtonOpacity'] as num?)?.toDouble() ?? 0.8,
      floatingButtonPosition: $enumDecodeNullable(
              _$FloatingButtonPositionEnumMap,
              json['floatingButtonPosition']) ??
          FloatingButtonPosition.bottomRight,
      customSettings:
          json['customSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'language': instance.language,
      'themeMode': instance.themeMode,
      'primaryColor': instance.primaryColor,
      'enableNotifications': instance.enableNotifications,
      'enableFloatingButton': instance.enableFloatingButton,
      'enableAutoStart': instance.enableAutoStart,
      'enableHapticFeedback': instance.enableHapticFeedback,
      'floatingButtonOpacity': instance.floatingButtonOpacity,
      'floatingButtonPosition':
          _$FloatingButtonPositionEnumMap[instance.floatingButtonPosition]!,
      'customSettings': instance.customSettings,
    };

const _$FloatingButtonPositionEnumMap = {
  FloatingButtonPosition.topLeft: 'topLeft',
  FloatingButtonPosition.topRight: 'topRight',
  FloatingButtonPosition.bottomLeft: 'bottomLeft',
  FloatingButtonPosition.bottomRight: 'bottomRight',
  FloatingButtonPosition.centerLeft: 'centerLeft',
  FloatingButtonPosition.centerRight: 'centerRight',
};

FilterSettings _$FilterSettingsFromJson(Map<String, dynamic> json) =>
    FilterSettings(
      filterLevel:
          $enumDecodeNullable(_$FilterLevelEnumMap, json['filterLevel']) ??
              FilterLevel.balanced,
      enableAutoFilter: json['enableAutoFilter'] as bool? ?? true,
      enableAutoReport: json['enableAutoReport'] as bool? ?? false,
      enableAutoBlock: json['enableAutoBlock'] as bool? ?? false,
      confidenceThreshold:
          (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.7,
      enabledContentTypes: (json['enabledContentTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['article', 'comment'],
      categoryWeights: (json['categoryWeights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      enableLearning: json['enableLearning'] as bool? ?? true,
      learningFrequency: (json['learningFrequency'] as num?)?.toInt() ?? 7,
      enablePreview: json['enablePreview'] as bool? ?? false,
      advancedSettings:
          json['advancedSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FilterSettingsToJson(FilterSettings instance) =>
    <String, dynamic>{
      'filterLevel': _$FilterLevelEnumMap[instance.filterLevel]!,
      'enableAutoFilter': instance.enableAutoFilter,
      'enableAutoReport': instance.enableAutoReport,
      'enableAutoBlock': instance.enableAutoBlock,
      'confidenceThreshold': instance.confidenceThreshold,
      'enabledContentTypes': instance.enabledContentTypes,
      'categoryWeights': instance.categoryWeights,
      'enableLearning': instance.enableLearning,
      'learningFrequency': instance.learningFrequency,
      'enablePreview': instance.enablePreview,
      'advancedSettings': instance.advancedSettings,
    };

const _$FilterLevelEnumMap = {
  FilterLevel.strict: 'strict',
  FilterLevel.balanced: 'balanced',
  FilterLevel.relaxed: 'relaxed',
  FilterLevel.custom: 'custom',
};

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      enableDataCollection: json['enableDataCollection'] as bool? ?? true,
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? true,
      enableLocalStorage: json['enableLocalStorage'] as bool? ?? true,
      dataRetentionDays: (json['dataRetentionDays'] as num?)?.toInt() ?? 30,
      enableEncryption: json['enableEncryption'] as bool? ?? true,
      sensitiveDataTypes: (json['sensitiveDataTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      permissions: (json['permissions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'enableDataCollection': instance.enableDataCollection,
      'enableAnalytics': instance.enableAnalytics,
      'enableCrashReporting': instance.enableCrashReporting,
      'enableLocalStorage': instance.enableLocalStorage,
      'dataRetentionDays': instance.dataRetentionDays,
      'enableEncryption': instance.enableEncryption,
      'sensitiveDataTypes': instance.sensitiveDataTypes,
      'permissions': instance.permissions,
    };
