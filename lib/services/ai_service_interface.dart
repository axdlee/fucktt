import '../models/ai_provider_model.dart';

/// AI服务统一接口定义
abstract class AIService {
  /// 服务商配置
  AIProviderModel get provider;
  
  /// 检查服务可用性
  Future<bool> checkAvailability();
  
  /// 发送聊天请求
  Future<AIResponse> chat({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  });
  
  /// 流式聊天请求
  Stream<String> chatStream({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  });
  
  /// 获取模型列表
  Future<List<ModelConfig>> getAvailableModels();
  
  /// 验证API配置
  Future<bool> validateConfiguration();
}

/// AI响应结果
class AIResponse {
  final String content;
  final String modelId;
  final Map<String, dynamic> usage;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  AIResponse({
    required this.content,
    required this.modelId,
    this.usage = const {},
    required this.timestamp,
    this.success = true,
    this.errorMessage,
    this.metadata = const {},
  });

  factory AIResponse.error(String errorMessage) {
    return AIResponse(
      content: '',
      modelId: '',
      timestamp: DateTime.now(),
      success: false,
      errorMessage: errorMessage,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'modelId': modelId,
      'usage': usage,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }
}

/// AI请求参数
class AIRequest {
  final String prompt;
  final String? modelId;
  final double temperature;
  final int maxTokens;
  final double? topP;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final List<String>? stop;
  final Map<String, dynamic> customParameters;

  AIRequest({
    required this.prompt,
    this.modelId,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.stop,
    this.customParameters = const {},
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'prompt': prompt,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    if (modelId != null) json['model'] = modelId;
    if (topP != null) json['top_p'] = topP;
    if (frequencyPenalty != null) json['frequency_penalty'] = frequencyPenalty;
    if (presencePenalty != null) json['presence_penalty'] = presencePenalty;
    if (stop != null && stop!.isNotEmpty) json['stop'] = stop;

    // 添加自定义参数
    for (final entry in customParameters.entries) {
      json[entry.key] = entry.value;
    }

    return json;
  }
}

/// 消息类型（用于支持对话格式的AI）
class ChatMessage {
  final String role; // 'system', 'user', 'assistant'
  final String content;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.role,
    required this.content,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'role': role,
      'content': content,
    };
    if (metadata != null) {
      for (final entry in metadata!.entries) {
        json[entry.key] = entry.value;
      }
    }
    return json;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// AI服务异常
class AIServiceException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  AIServiceException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'AIServiceException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}