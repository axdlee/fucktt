import 'dart:convert';
import '../services/ai_service_interface.dart';
import '../models/ai_provider_model.dart';

/// AI模拟服务 - 用于测试和演示
/// 提供预设的AI响应，模拟真实的AI服务行为
class AISimulationService implements AIService {
  late final AIProviderModel _provider;
  
  AISimulationService() {
    _provider = AIProviderModel(
      id: 'simulation',
      name: 'simulation',
      displayName: '模拟AI服务',
      baseUrl: 'mock://simulation',
      apiKey: 'mock-key',
      supportedModels: [
        ModelConfig(modelId: 'simulation-model', displayName: 'Mock AI Model'),
        ModelConfig(modelId: 'test-model', displayName: 'Test Model'),
      ],
      enabled: true,
      description: '用于测试和演示的模拟AI服务',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      priority: 99, // 最低优先级
    );
  }

  @override
  AIProviderModel get provider => _provider;

  @override
  Future<bool> checkAvailability() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<bool> validateConfiguration() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Stream<String> chatStream({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async* {
    // 模拟流式响应
    final response = await chat(
      prompt: prompt,
      modelId: modelId,
      parameters: parameters,
    );
    
    // 将响应分块返回以模拟流式
    final content = response.content;
    final chunks = content.split('');
    
    for (int i = 0; i < chunks.length; i += 5) {
      final chunk = chunks.skip(i).take(5).join('');
      await Future.delayed(const Duration(milliseconds: 50));
      yield chunk;
    }
  }

  @override
  Future<List<ModelConfig>> getAvailableModels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _provider.supportedModels;
  }

  @override
  Future<AIResponse> chat({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800 + (DateTime.now().millisecond % 500)));

    // 从prompt中提取要分析的内容
    final content = _extractContentFromPrompt(prompt);
    
    // 生成模拟的AI分析结果
    final analysis = _generateMockAnalysis(content);

    return AIResponse(
      content: jsonEncode(analysis),
      modelId: modelId ?? 'simulation-model',
      usage: {
        'prompt_tokens': prompt.length ~/ 4,
        'completion_tokens': 150,
        'total_tokens': (prompt.length ~/ 4) + 150,
      },
      timestamp: DateTime.now(),
      success: true,
      metadata: {
        'simulation': true,
        'analysis_type': 'content_value_analysis',
      },
    );
  }



  /// 从prompt中提取要分析的内容
  String _extractContentFromPrompt(String prompt) {
    // 简单的内容提取逻辑
    final lines = prompt.split('\n');
    for (final line in lines) {
      if (line.contains('内容：') || line.contains('content:')) {
        return line.split('：').length > 1 
            ? line.split('：')[1].trim()
            : line.split(':').length > 1 
                ? line.split(':')[1].trim()
                : line.trim();
      }
    }
    return prompt.length > 100 ? prompt.substring(0, 100) : prompt;
  }

  /// 生成模拟的AI分析结果
  Map<String, dynamic> _generateMockAnalysis(String content) {
    // 基于内容关键词进行简单的情感和价值观分析
    final contentLower = content.toLowerCase();
    
    // 检测正面关键词
    final positiveKeywords = ['志愿者', '帮助', '教育', '奉献', '科技', '创新', '突破', '贡献', '学习', '思考', '清华', '大学'];
    final negativeKeywords = ['丑闻', '对骂', '失控', '低俗', '八卦', '污染', '负能量', '没有', '差', '不如'];
    final neutralKeywords = ['新闻', '报道', '消息', '内容', '信息'];

    double positiveScore = 0.0;
    double negativeScore = 0.0;
    double neutralScore = 0.5;

    // 计算正面关键词匹配度
    for (final keyword in positiveKeywords) {
      if (contentLower.contains(keyword)) {
        positiveScore += 0.15;
      }
    }

    // 计算负面关键词匹配度
    for (final keyword in negativeKeywords) {
      if (contentLower.contains(keyword)) {
        negativeScore += 0.2;
      }
    }

    // 计算中性关键词
    for (final keyword in neutralKeywords) {
      if (contentLower.contains(keyword)) {
        neutralScore += 0.1;
      }
    }

    // 归一化分数
    final total = positiveScore + negativeScore + neutralScore;
    if (total > 0) {
      positiveScore = positiveScore / total;
      negativeScore = negativeScore / total;
      neutralScore = neutralScore / total;
    }

    // 计算整体价值观匹配度
    double overallScore = positiveScore * 0.8 + neutralScore * 0.5 - negativeScore * 0.3;
    overallScore = overallScore.clamp(0.0, 1.0);

    // 确定主导情感
    String dominantSentiment = 'neutral';
    if (positiveScore > negativeScore && positiveScore > neutralScore) {
      dominantSentiment = 'positive';
    } else if (negativeScore > positiveScore && negativeScore > neutralScore) {
      dominantSentiment = 'negative';
    }

    // 生成内容标签
    List<String> tags = [];
    if (contentLower.contains('教育') || contentLower.contains('学习') || contentLower.contains('大学')) {
      tags.add('教育');
    }
    if (contentLower.contains('科技') || contentLower.contains('创新') || contentLower.contains('技术')) {
      tags.add('科技');
    }
    if (contentLower.contains('志愿') || contentLower.contains('帮助') || contentLower.contains('奉献')) {
      tags.add('公益');
    }
    if (contentLower.contains('八卦') || contentLower.contains('明星') || contentLower.contains('丑闻')) {
      tags.add('娱乐');
    }
    if (contentLower.contains('负面') || contentLower.contains('抱怨') || contentLower.contains('差')) {
      tags.add('负面');
    }

    return {
      'overallScore': overallScore,
      'sentiment': {
        'positive': positiveScore,
        'negative': negativeScore,
        'neutral': neutralScore,
        'dominantSentiment': dominantSentiment,
      },
      'valueScores': {
        '正面价值观': positiveScore,
        '社会价值': neutralScore,
        '教育价值': contentLower.contains('教育') ? 0.8 : 0.3,
        '科技创新': contentLower.contains('科技') ? 0.9 : 0.2,
      },
      'tags': tags,
      'reasoning': _generateReasoning(content, overallScore, dominantSentiment),
      'recommendations': _generateRecommendations(overallScore),
    };
  }

  /// 生成分析推理
  String _generateReasoning(String content, double score, String sentiment) {
    if (score >= 0.7) {
      return '该内容体现了积极正面的价值观，符合用户的价值观偏好。内容具有教育意义或积极的社会价值。';
    } else if (score >= 0.4) {
      return '该内容基本中性，没有明显的价值观冲突，但也缺乏特别积极的价值导向。';
    } else {
      return '该内容可能包含负面情绪或价值观倾向，与用户设定的价值观存在一定冲突。';
    }
  }

  /// 生成建议
  List<String> _generateRecommendations(double score) {
    if (score >= 0.7) {
      return ['推荐阅读', '分享给朋友', '收藏保存'];
    } else if (score >= 0.4) {
      return ['谨慎阅读', '关注来源', '多角度思考'];
    } else {
      return ['建议跳过', '避免传播', '寻找正面内容'];
    }
  }
}


  });
}

/// AI使用情况数据模型
class AIUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  AIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
}