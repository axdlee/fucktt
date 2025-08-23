import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/behavior_model.dart';
import '../services/behavior_log_service.dart';
import '../services/ai_service_manager.dart';
import '../services/storage_service.dart';
import '../providers/ai_provider.dart';
import '../providers/values_provider.dart';

/// 内容分析Provider - 管理内容分析和过滤相关状态
class ContentProvider extends ChangeNotifier {
  final AIServiceManager _aiManager = AIServiceManager();
  
  List<ContentAnalysisResult> _analysisHistory = [];
  List<BehaviorLogModel> _recentBehaviors = [];
  bool _isAnalyzing = false;
  bool _isInitialized = false;
  String? _errorMessage;
  
  // 过滤统计
  int _totalAnalyzed = 0;
  int _totalBlocked = 0;
  int _totalWarned = 0;
  Map<String, int> _categoryStats = {};

  // Getters
  List<ContentAnalysisResult> get analysisHistory => List.unmodifiable(_analysisHistory);
  List<BehaviorLogModel> get recentBehaviors => List.unmodifiable(_recentBehaviors);
  bool get isAnalyzing => _isAnalyzing;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  
  int get totalAnalyzed => _totalAnalyzed;
  int get totalBlocked => _totalBlocked;
  int get totalWarned => _totalWarned;
  Map<String, int> get categoryStats => Map.unmodifiable(_categoryStats);
  
  /// 过滤效率
  double get filterEfficiency => _totalAnalyzed > 0 ? 
      (_totalBlocked + _totalWarned) / _totalAnalyzed : 0.0;

  /// 初始化内容Provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadAnalysisHistory();
      await _loadRecentBehaviors();
      await _calculateStatistics();
      
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('内容分析系统初始化失败: $e');
    }
  }

  /// 加载分析历史
  Future<void> _loadAnalysisHistory() async {
    try {
      final box = StorageService.analysisResultBox;
      _analysisHistory = box.values.toList()
        ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      
      // 只保留最近100条记录在内存中
      if (_analysisHistory.length > 100) {
        _analysisHistory = _analysisHistory.take(100).toList();
      }
    } catch (e) {
      print('加载分析历史失败: $e');
    }
  }

  /// 加载最近行为
  Future<void> _loadRecentBehaviors() async {
    try {
      _recentBehaviors = BehaviorLogService.getRecentBehaviors(
        'default_user',
        days: 7,
        limit: 50,
      );
    } catch (e) {
      print('加载最近行为失败: $e');
    }
  }

  /// 计算统计信息
  Future<void> _calculateStatistics() async {
    _totalAnalyzed = _analysisHistory.length;
    _totalBlocked = _analysisHistory.where((r) => r.recommendedAction == FilterAction.block).length;
    _totalWarned = _analysisHistory.where((r) => r.recommendedAction == FilterAction.warning).length;
    
    _categoryStats.clear();
    for (final result in _analysisHistory) {
      final contentType = result.contentType.toString();
      _categoryStats[contentType] = (_categoryStats[contentType] ?? 0) + 1;
    }
  }

  /// 分析内容
  Future<ContentAnalysisResult?> analyzeContent({
    required String content,
    required ContentType contentType,
    String? contentId,
    String? authorId,
    String? authorName,
    ValuesProvider? valuesProvider,
    AIProvider? aiProvider,
  }) async {
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      // 首先进行本地价值观匹配
      final localScore = valuesProvider?.calculateMatchScore(content) ?? 0.5;
      
      // 如果有AI服务，进行AI分析
      double aiScore = localScore;
      Map<String, double> valueScores = {};
      SentimentAnalysis sentiment = SentimentAnalysis(
        positive: 0.5,
        negative: 0.3,
        neutral: 0.2,
        dominantSentiment: 'neutral',
      );
      
      if (aiProvider != null && aiProvider.hasAvailableServices) {
        try {
          final aiResult = await _performAIAnalysis(content, valuesProvider);
          if (aiResult != null) {
            aiScore = aiResult['overallScore'] ?? localScore;
            valueScores = Map<String, double>.from(aiResult['valueScores'] ?? {});
            sentiment = aiResult['sentiment'] ?? sentiment;
          }
        } catch (e) {
          print('AI分析失败，使用本地分析结果: $e');
        }
      }
      
      // 决定过滤动作
      final action = _determineFilterAction(aiScore);
      
      // 创建分析结果
      final result = ContentAnalysisResult(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        contentId: contentId ?? '',
        content: content,
        contentType: contentType,
        valueScores: valueScores,
        overallScore: aiScore,
        sentiment: sentiment,
        extractedTopics: _extractTopics(content),
        matchedKeywords: _extractKeywords(content, valuesProvider),
        recommendedAction: action,
        analyzedAt: DateTime.now(),
        aiProviderId: aiProvider?.healthyProviders.isNotEmpty == true 
            ? aiProvider!.healthyProviders.first.id 
            : '',
        promptTemplateId: 'content_analysis',
        rawResponse: {},
      );
      
      // 保存分析结果
      await _saveAnalysisResult(result);
      
      // 记录行为日志
      await BehaviorLogService.logBehavior(
        userId: 'default_user',
        actionType: BehaviorType.read,
        content: content,
        contentType: contentType,
        contentId: contentId,
        authorId: authorId,
        authorName: authorName,
        metadata: {
          'analysisScore': aiScore,
          'filterAction': action.toString(),
          'analysisId': result.id,
        },
        confidence: aiScore,
      );
      
      await _refreshData();
      _clearError();
      return result;
      
    } catch (e) {
      _setError('内容分析失败: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 执行AI分析
  Future<Map<String, dynamic>?> _performAIAnalysis(
    String content,
    ValuesProvider? valuesProvider,
  ) async {
    try {
      // 构建分析提示词
      final userValues = valuesProvider?.enabledTemplates
          .map((t) => '${t.name}: ${t.description}')
          .join('\n') ?? '';
      
      final prompt = '''你是一个专业的内容分析师。请分析以下内容的价值观倾向：

内容：$content

用户价值观偏好：
$userValues

请从以下维度分析：
1. 情感倾向（positive/negative/neutral，0-1分）
2. 价值观匹配度（与用户偏好的匹配程度，0-1分）
3. 主要主题标签
4. 风险评估（是否包含不当内容）

请以JSON格式返回结果：
{
  "overallScore": 0.7,
  "valueScores": {"正面价值观": 0.8, "家庭价值观": 0.6},
  "sentiment": {
    "positive": 0.6,
    "negative": 0.2,
    "neutral": 0.2,
    "dominantSentiment": "positive"
  },
  "topics": ["家庭", "教育"],
  "riskLevel": "low"
}''';

      final response = await _aiManager.executeRequest(prompt: prompt);
      
      if (response.success == true) {
        // 尝试解析JSON响应
        try {
          final jsonData = _parseAIResponse(response.content);
          return jsonData;
        } catch (e) {
          print('解析AI响应失败: $e');
          return null;
        }
      }
      
      return null;
    } catch (e) {
      print('AI分析请求失败: $e');
      return null;
    }
  }

  /// 解析AI响应
  Map<String, dynamic> _parseAIResponse(String response) {
    // 简化的JSON解析，实际应用中需要更robust的解析
    // 这里假设AI返回的是规范的JSON
    try {
      // 提取JSON部分
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        // 这里需要实际的JSON解析，目前简化处理
        return {
          'overallScore': 0.7,
          'valueScores': {},
          'sentiment': SentimentAnalysis(
            positive: 0.6,
            negative: 0.2,
            neutral: 0.2,
            dominantSentiment: 'positive',
          ),
        };
      }
    } catch (e) {
      print('JSON解析错误: $e');
    }
    
    return {};
  }

  /// 决定过滤动作
  FilterAction _determineFilterAction(double score) {
    if (score >= 0.8) return FilterAction.allow;
    if (score >= 0.6) return FilterAction.warning;
    if (score >= 0.4) return FilterAction.blur;
    return FilterAction.block;
  }

  /// 提取主题
  List<String> _extractTopics(String content) {
    // 简化的主题提取，实际应用中可以使用更复杂的NLP
    final topics = <String>[];
    final keywords = ['家庭', '教育', '政治', '经济', '科技', '娱乐', '体育', '健康'];
    
    for (final keyword in keywords) {
      if (content.contains(keyword)) {
        topics.add(keyword);
      }
    }
    
    return topics;
  }

  /// 提取关键词
  List<String> _extractKeywords(String content, ValuesProvider? valuesProvider) {
    final matched = <String>[];
    
    if (valuesProvider != null) {
      for (final template in valuesProvider.enabledTemplates) {
        for (final keyword in template.keywords) {
          if (content.toLowerCase().contains(keyword.toLowerCase())) {
            matched.add(keyword);
          }
        }
      }
    }
    
    return matched;
  }

  /// 保存分析结果
  Future<void> _saveAnalysisResult(ContentAnalysisResult result) async {
    final box = StorageService.analysisResultBox;
    await box.put(result.id, result);
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    await _loadAnalysisHistory();
    await _loadRecentBehaviors();
    await _calculateStatistics();
    notifyListeners();
  }

  /// 记录用户反馈
  Future<void> recordUserFeedback({
    required String contentId,
    required BehaviorType action,
    String? content,
    ContentType? contentType,
  }) async {
    try {
      await BehaviorLogService.logBehavior(
        userId: 'default_user',
        actionType: action,
        content: content ?? '',
        contentType: contentType ?? ContentType.article,
        contentId: contentId,
        metadata: {
          'userFeedback': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      await _loadRecentBehaviors();
      notifyListeners();
    } catch (e) {
      _setError('记录用户反馈失败: $e');
    }
  }

  /// 获取过滤统计
  Map<String, dynamic> getFilterStatistics({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentResults = _analysisHistory
        .where((result) => result.analyzedAt.isAfter(cutoffDate))
        .toList();
    
    final actionCounts = <FilterAction, int>{};
    final dailyStats = <String, int>{};
    
    for (final result in recentResults) {
      actionCounts[result.recommendedAction] = 
          (actionCounts[result.recommendedAction] ?? 0) + 1;
      
      final dateKey = '${result.analyzedAt.year}-${result.analyzedAt.month.toString().padLeft(2, '0')}-${result.analyzedAt.day.toString().padLeft(2, '0')}';
      dailyStats[dateKey] = (dailyStats[dateKey] ?? 0) + 1;
    }
    
    return {
      'totalAnalyzed': recentResults.length,
      'actionCounts': actionCounts.map((k, v) => MapEntry(k.toString(), v)),
      'dailyStats': dailyStats,
      'averageScore': recentResults.isNotEmpty 
          ? recentResults.map((r) => r.overallScore).reduce((a, b) => a + b) / recentResults.length
          : 0.0,
      'dateRange': {
        'start': cutoffDate.toIso8601String(),
        'end': DateTime.now().toIso8601String(),
      },
    };
  }

  /// 清理历史数据
  Future<void> clearHistory() async {
    try {
      final box = StorageService.analysisResultBox;
      await box.clear();
      
      await BehaviorLogService.clearUserBehaviorLogs('default_user');
      
      await _refreshData();
      _clearError();
    } catch (e) {
      _setError('清理历史数据失败: $e');
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
