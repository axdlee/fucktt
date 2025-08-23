// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ValueTemplateModelAdapter extends TypeAdapter<ValueTemplateModel> {
  @override
  final int typeId = 3;

  @override
  ValueTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValueTemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      keywords: (fields[4] as List).cast<String>(),
      negativeKeywords: (fields[5] as List).cast<String>(),
      weight: fields[6] as double,
      enabled: fields[7] as bool,
      isCustom: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      priority: fields[11] as int,
      customConfig: (fields[12] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ValueTemplateModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.keywords)
      ..writeByte(5)
      ..write(obj.negativeKeywords)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.enabled)
      ..writeByte(8)
      ..write(obj.isCustom)
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
      other is ValueTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserValuesProfileAdapter extends TypeAdapter<UserValuesProfile> {
  @override
  final int typeId = 4;

  @override
  UserValuesProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserValuesProfile(
      userId: fields[0] as String,
      templateWeights: (fields[1] as Map).cast<String, double>(),
      blacklist: (fields[2] as List).cast<String>(),
      whitelist: (fields[3] as List).cast<String>(),
      customCategories: (fields[4] as Map).cast<String, ValueCategory>(),
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      preferences: (fields[7] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserValuesProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.templateWeights)
      ..writeByte(2)
      ..write(obj.blacklist)
      ..writeByte(3)
      ..write(obj.whitelist)
      ..writeByte(4)
      ..write(obj.customCategories)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserValuesProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ValueCategoryAdapter extends TypeAdapter<ValueCategory> {
  @override
  final int typeId = 5;

  @override
  ValueCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValueCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      color: fields[3] as String,
      icon: fields[4] as String,
      sortOrder: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ValueCategory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValueTemplateModel _$ValueTemplateModelFromJson(Map<String, dynamic> json) =>
    ValueTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      negativeKeywords: (json['negativeKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weight: (json['weight'] as num?)?.toDouble() ?? 0.5,
      enabled: json['enabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      customConfig: json['customConfig'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ValueTemplateModelToJson(ValueTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'keywords': instance.keywords,
      'negativeKeywords': instance.negativeKeywords,
      'weight': instance.weight,
      'enabled': instance.enabled,
      'isCustom': instance.isCustom,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'priority': instance.priority,
      'customConfig': instance.customConfig,
    };

UserValuesProfile _$UserValuesProfileFromJson(Map<String, dynamic> json) =>
    UserValuesProfile(
      userId: json['userId'] as String,
      templateWeights: (json['templateWeights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      blacklist: (json['blacklist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      whitelist: (json['whitelist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customCategories: (json['customCategories'] as Map<String, dynamic>?)
              ?.map(
            (k, e) =>
                MapEntry(k, ValueCategory.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$UserValuesProfileToJson(UserValuesProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'templateWeights': instance.templateWeights,
      'blacklist': instance.blacklist,
      'whitelist': instance.whitelist,
      'customCategories': instance.customCategories,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'preferences': instance.preferences,
    };

ValueCategory _$ValueCategoryFromJson(Map<String, dynamic> json) =>
    ValueCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String? ?? '#1890FF',
      icon: json['icon'] as String? ?? '🏷️',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ValueCategoryToJson(ValueCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'icon': instance.icon,
      'sortOrder': instance.sortOrder,
    };
