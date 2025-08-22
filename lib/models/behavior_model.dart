import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'behavior_model.g.dart';

@HiveType(typeId: 9)
@JsonSerializable()
class BehaviorLogModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final BehaviorType actionType;
  
  @HiveField(3)
  final String? contentId; // 关联的内容ID
  
  @HiveField(4)
  final String content; // 内容文本
  
  @HiveField(5)
  final ContentType contentType;
  
  @HiveField(6)
  final String? authorId; // 作者ID
  
  @HiveField(7)
  final String? authorName; // 作者名称
  
  @HiveField(8)
  final DateTime timestamp;
  
  @HiveField(9)
  final Map<String, dynamic> metadata; // 额外元数据
  
  @HiveField(10)
  final double? confidence; // 置信度

  BehaviorLogModel({
    required this.id,
    required this.userId,
    required this.actionType,
    this.contentId,
    required this.content,
    required this.contentType,
    this.authorId,
    this.authorName,
    required this.timestamp,
    this.metadata = const {},
    this.confidence,
  });

  factory BehaviorLogModel.fromJson(Map<String, dynamic> json) =>
      _$BehaviorLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviorLogModelToJson(this);

  BehaviorLogModel copyWith({
    String? id,
    String? userId,
    BehaviorType? actionType,
    String? contentId,
    String? content,
    ContentType? contentType,
    String? authorId,
    String? authorName,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    double? confidence,
  }) {
    return BehaviorLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      contentId: contentId ?? this.contentId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
    );
  }
}

@HiveType(typeId: 10)
enum BehaviorType {
  @HiveField(0)
  like,          // 点赞
  
  @HiveField(1)
  dislike,       // 点踩
  
  @HiveField(2)
  share,         // 分享
  
  @HiveField(3)
  comment,       // 评论
  
  @HiveField(4)
  report,        // 举报
  
  @HiveField(5)
  block,         // 屏蔽
  
  @HiveField(6)
  read,          // 阅读
  
  @HiveField(7)
  skip,          // 跳过
  
  @HiveField(8)
  bookmark,      // 收藏
  
  @HiveField(9)
  follow,        // 关注作者
  
  @HiveField(10)
  unfollow,      // 取消关注
}

@HiveType(typeId: 11)
enum ContentType {
  @HiveField(0)
  article,       // 文章
  
  @HiveField(1)
  comment,       // 评论
  
  @HiveField(2)
  video,         // 视频
  
  @HiveField(3)
  image,         // 图片
  
  @HiveField(4)
  author,        // 作者信息
  
  @HiveField(5)
  advertisement, // 广告
}

@HiveType(typeId: 12)
@JsonSerializable()
class ContentAnalysisResult {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String contentId;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final ContentType contentType;
  
  @HiveField(4)
  final Map<String, double> valueScores; // 价值观分数
  
  @HiveField(5)
  final double overallScore; // 总体匹配分数
  
  @HiveField(6)
  final SentimentAnalysis sentiment; // 情感分析
  
  @HiveField(7)
  final List<String> extractedTopics; // 提取的主题
  
  @HiveField(8)
  final List<String> matchedKeywords; // 匹配的关键词
  
  @HiveField(9)
  final FilterAction recommendedAction; // 推荐的过滤动作
  
  @HiveField(10)
  final DateTime analyzedAt;
  
  @HiveField(11)
  final String aiProviderId; // 使用的AI服务商
  
  @HiveField(12)
  final String promptTemplateId; // 使用的Prompt模板
  
  @HiveField(13)
  final Map<String, dynamic> rawResponse; // AI原始响应

  ContentAnalysisResult({
    required this.id,
    required this.contentId,
    required this.content,
    required this.contentType,
    this.valueScores = const {},
    required this.overallScore,
    required this.sentiment,
    this.extractedTopics = const [],
    this.matchedKeywords = const [],
    required this.recommendedAction,
    required this.analyzedAt,
    required this.aiProviderId,
    required this.promptTemplateId,
    this.rawResponse = const {},
  });

  factory ContentAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ContentAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$ContentAnalysisResultToJson(this);
}

@HiveType(typeId: 13)
@JsonSerializable()
class SentimentAnalysis {
  @HiveField(0)
  final double positive; // 正面情感 0.0-1.0
  
  @HiveField(1)
  final double negative; // 负面情感 0.0-1.0
  
  @HiveField(2)
  final double neutral;  // 中性情感 0.0-1.0
  
  @HiveField(3)
  final String dominantSentiment; // 主导情感

  SentimentAnalysis({
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.dominantSentiment,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SentimentAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);
}

@HiveType(typeId: 14)
enum FilterAction {
  @HiveField(0)
  allow,         // 允许显示
  
  @HiveField(1)
  blur,          // 模糊显示
  
  @HiveField(2)
  warning,       // 警告标记
  
  @HiveField(3)
  block,         // 完全屏蔽
  
  @HiveField(4)
  askUser,       // 询问用户
}

@HiveType(typeId: 15)
@JsonSerializable()
class AIInsightModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String analysisType; // 分析类型
  
  @HiveField(3)
  final String prompt; // 使用的Prompt
  
  @HiveField(4)
  final String aiResponse; // AI响应
  
  @HiveField(5)
  final String aiProviderId;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final Map<String, dynamic> inputData; // 输入数据
  
  @HiveField(8)
  final Map<String, dynamic> extractedInsights; // 提取的洞察

  AIInsightModel({
    required this.id,
    required this.userId,
    required this.analysisType,
    required this.prompt,
    required this.aiResponse,
    required this.aiProviderId,
    required this.createdAt,
    this.inputData = const {},
    this.extractedInsights = const {},
  });

  factory AIInsightModel.fromJson(Map<String, dynamic> json) =>
      _$AIInsightModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIInsightModelToJson(this);
}