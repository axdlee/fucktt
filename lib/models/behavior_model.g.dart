// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BehaviorLogModelAdapter extends TypeAdapter<BehaviorLogModel> {
  @override
  final int typeId = 9;

  @override
  BehaviorLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehaviorLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      actionType: fields[2] as BehaviorType,
      contentId: fields[3] as String?,
      content: fields[4] as String,
      contentType: fields[5] as ContentType,
      authorId: fields[6] as String?,
      authorName: fields[7] as String?,
      timestamp: fields[8] as DateTime,
      metadata: (fields[9] as Map).cast<String, dynamic>(),
      confidence: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BehaviorLogModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.actionType)
      ..writeByte(3)
      ..write(obj.contentId)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.contentType)
      ..writeByte(6)
      ..write(obj.authorId)
      ..writeByte(7)
      ..write(obj.authorName)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.metadata)
      ..writeByte(10)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehaviorLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContentAnalysisResultAdapter extends TypeAdapter<ContentAnalysisResult> {
  @override
  final int typeId = 12;

  @override
  ContentAnalysisResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentAnalysisResult(
      id: fields[0] as String,
      contentId: fields[1] as String,
      content: fields[2] as String,
      contentType: fields[3] as ContentType,
      valueScores: (fields[4] as Map).cast<String, double>(),
      overallScore: fields[5] as double,
      sentiment: fields[6] as SentimentAnalysis,
      extractedTopics: (fields[7] as List).cast<String>(),
      matchedKeywords: (fields[8] as List).cast<String>(),
      recommendedAction: fields[9] as FilterAction,
      analyzedAt: fields[10] as DateTime,
      aiProviderId: fields[11] as String,
      promptTemplateId: fields[12] as String,
      rawResponse: (fields[13] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ContentAnalysisResult obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contentId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.contentType)
      ..writeByte(4)
      ..write(obj.valueScores)
      ..writeByte(5)
      ..write(obj.overallScore)
      ..writeByte(6)
      ..write(obj.sentiment)
      ..writeByte(7)
      ..write(obj.extractedTopics)
      ..writeByte(8)
      ..write(obj.matchedKeywords)
      ..writeByte(9)
      ..write(obj.recommendedAction)
      ..writeByte(10)
      ..write(obj.analyzedAt)
      ..writeByte(11)
      ..write(obj.aiProviderId)
      ..writeByte(12)
      ..write(obj.promptTemplateId)
      ..writeByte(13)
      ..write(obj.rawResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentAnalysisResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SentimentAnalysisAdapter extends TypeAdapter<SentimentAnalysis> {
  @override
  final int typeId = 13;

  @override
  SentimentAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SentimentAnalysis(
      positive: fields[0] as double,
      negative: fields[1] as double,
      neutral: fields[2] as double,
      dominantSentiment: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SentimentAnalysis obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.positive)
      ..writeByte(1)
      ..write(obj.negative)
      ..writeByte(2)
      ..write(obj.neutral)
      ..writeByte(3)
      ..write(obj.dominantSentiment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentimentAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AIInsightModelAdapter extends TypeAdapter<AIInsightModel> {
  @override
  final int typeId = 15;

  @override
  AIInsightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIInsightModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      analysisType: fields[2] as String,
      prompt: fields[3] as String,
      aiResponse: fields[4] as String,
      aiProviderId: fields[5] as String,
      createdAt: fields[6] as DateTime,
      inputData: (fields[7] as Map).cast<String, dynamic>(),
      extractedInsights: (fields[8] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AIInsightModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.analysisType)
      ..writeByte(3)
      ..write(obj.prompt)
      ..writeByte(4)
      ..write(obj.aiResponse)
      ..writeByte(5)
      ..write(obj.aiProviderId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.inputData)
      ..writeByte(8)
      ..write(obj.extractedInsights);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIInsightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BehaviorTypeAdapter extends TypeAdapter<BehaviorType> {
  @override
  final int typeId = 10;

  @override
  BehaviorType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BehaviorType.like;
      case 1:
        return BehaviorType.dislike;
      case 2:
        return BehaviorType.share;
      case 3:
        return BehaviorType.comment;
      case 4:
        return BehaviorType.report;
      case 5:
        return BehaviorType.block;
      case 6:
        return BehaviorType.read;
      case 7:
        return BehaviorType.skip;
      case 8:
        return BehaviorType.bookmark;
      case 9:
        return BehaviorType.follow;
      case 10:
        return BehaviorType.unfollow;
      default:
        return BehaviorType.like;
    }
  }

  @override
  void write(BinaryWriter writer, BehaviorType obj) {
    switch (obj) {
      case BehaviorType.like:
        writer.writeByte(0);
        break;
      case BehaviorType.dislike:
        writer.writeByte(1);
        break;
      case BehaviorType.share:
        writer.writeByte(2);
        break;
      case BehaviorType.comment:
        writer.writeByte(3);
        break;
      case BehaviorType.report:
        writer.writeByte(4);
        break;
      case BehaviorType.block:
        writer.writeByte(5);
        break;
      case BehaviorType.read:
        writer.writeByte(6);
        break;
      case BehaviorType.skip:
        writer.writeByte(7);
        break;
      case BehaviorType.bookmark:
        writer.writeByte(8);
        break;
      case BehaviorType.follow:
        writer.writeByte(9);
        break;
      case BehaviorType.unfollow:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehaviorTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContentTypeAdapter extends TypeAdapter<ContentType> {
  @override
  final int typeId = 11;

  @override
  ContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContentType.article;
      case 1:
        return ContentType.comment;
      case 2:
        return ContentType.video;
      case 3:
        return ContentType.image;
      case 4:
        return ContentType.author;
      case 5:
        return ContentType.advertisement;
      default:
        return ContentType.article;
    }
  }

  @override
  void write(BinaryWriter writer, ContentType obj) {
    switch (obj) {
      case ContentType.article:
        writer.writeByte(0);
        break;
      case ContentType.comment:
        writer.writeByte(1);
        break;
      case ContentType.video:
        writer.writeByte(2);
        break;
      case ContentType.image:
        writer.writeByte(3);
        break;
      case ContentType.author:
        writer.writeByte(4);
        break;
      case ContentType.advertisement:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FilterActionAdapter extends TypeAdapter<FilterAction> {
  @override
  final int typeId = 14;

  @override
  FilterAction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FilterAction.allow;
      case 1:
        return FilterAction.blur;
      case 2:
        return FilterAction.warning;
      case 3:
        return FilterAction.block;
      case 4:
        return FilterAction.askUser;
      default:
        return FilterAction.allow;
    }
  }

  @override
  void write(BinaryWriter writer, FilterAction obj) {
    switch (obj) {
      case FilterAction.allow:
        writer.writeByte(0);
        break;
      case FilterAction.blur:
        writer.writeByte(1);
        break;
      case FilterAction.warning:
        writer.writeByte(2);
        break;
      case FilterAction.block:
        writer.writeByte(3);
        break;
      case FilterAction.askUser:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BehaviorLogModel _$BehaviorLogModelFromJson(Map<String, dynamic> json) =>
    BehaviorLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      actionType: $enumDecode(_$BehaviorTypeEnumMap, json['actionType']),
      contentId: json['contentId'] as String?,
      content: json['content'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['contentType']),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BehaviorLogModelToJson(BehaviorLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'actionType': _$BehaviorTypeEnumMap[instance.actionType]!,
      'contentId': instance.contentId,
      'content': instance.content,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'confidence': instance.confidence,
    };

const _$BehaviorTypeEnumMap = {
  BehaviorType.like: 'like',
  BehaviorType.dislike: 'dislike',
  BehaviorType.share: 'share',
  BehaviorType.comment: 'comment',
  BehaviorType.report: 'report',
  BehaviorType.block: 'block',
  BehaviorType.read: 'read',
  BehaviorType.skip: 'skip',
  BehaviorType.bookmark: 'bookmark',
  BehaviorType.follow: 'follow',
  BehaviorType.unfollow: 'unfollow',
};

const _$ContentTypeEnumMap = {
  ContentType.article: 'article',
  ContentType.comment: 'comment',
  ContentType.video: 'video',
  ContentType.image: 'image',
  ContentType.author: 'author',
  ContentType.advertisement: 'advertisement',
};

ContentAnalysisResult _$ContentAnalysisResultFromJson(
        Map<String, dynamic> json) =>
    ContentAnalysisResult(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      content: json['content'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['contentType']),
      valueScores: (json['valueScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      overallScore: (json['overallScore'] as num).toDouble(),
      sentiment:
          SentimentAnalysis.fromJson(json['sentiment'] as Map<String, dynamic>),
      extractedTopics: (json['extractedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      matchedKeywords: (json['matchedKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recommendedAction:
          $enumDecode(_$FilterActionEnumMap, json['recommendedAction']),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      aiProviderId: json['aiProviderId'] as String,
      promptTemplateId: json['promptTemplateId'] as String,
      rawResponse: json['rawResponse'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ContentAnalysisResultToJson(
        ContentAnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentId': instance.contentId,
      'content': instance.content,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'valueScores': instance.valueScores,
      'overallScore': instance.overallScore,
      'sentiment': instance.sentiment,
      'extractedTopics': instance.extractedTopics,
      'matchedKeywords': instance.matchedKeywords,
      'recommendedAction': _$FilterActionEnumMap[instance.recommendedAction]!,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'aiProviderId': instance.aiProviderId,
      'promptTemplateId': instance.promptTemplateId,
      'rawResponse': instance.rawResponse,
    };

const _$FilterActionEnumMap = {
  FilterAction.allow: 'allow',
  FilterAction.blur: 'blur',
  FilterAction.warning: 'warning',
  FilterAction.block: 'block',
  FilterAction.askUser: 'askUser',
};

SentimentAnalysis _$SentimentAnalysisFromJson(Map<String, dynamic> json) =>
    SentimentAnalysis(
      positive: (json['positive'] as num).toDouble(),
      negative: (json['negative'] as num).toDouble(),
      neutral: (json['neutral'] as num).toDouble(),
      dominantSentiment: json['dominantSentiment'] as String,
    );

Map<String, dynamic> _$SentimentAnalysisToJson(SentimentAnalysis instance) =>
    <String, dynamic>{
      'positive': instance.positive,
      'negative': instance.negative,
      'neutral': instance.neutral,
      'dominantSentiment': instance.dominantSentiment,
    };

AIInsightModel _$AIInsightModelFromJson(Map<String, dynamic> json) =>
    AIInsightModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      analysisType: json['analysisType'] as String,
      prompt: json['prompt'] as String,
      aiResponse: json['aiResponse'] as String,
      aiProviderId: json['aiProviderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      inputData: json['inputData'] as Map<String, dynamic>? ?? const {},
      extractedInsights:
          json['extractedInsights'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AIInsightModelToJson(AIInsightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'analysisType': instance.analysisType,
      'prompt': instance.prompt,
      'aiResponse': instance.aiResponse,
      'aiProviderId': instance.aiProviderId,
      'createdAt': instance.createdAt.toIso8601String(),
      'inputData': instance.inputData,
      'extractedInsights': instance.extractedInsights,
    };
