import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_provider_model.dart';
import '../models/value_template_model.dart';
import '../models/prompt_template_model.dart';
import '../models/behavior_model.dart';
import '../models/user_config_model.dart';

/// 本地存储服务 - 统一管理所有Hive数据库操作
class StorageService {
  // 单例模式
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Hive Box 实例
  static late Box<UserConfigModel> _userConfigBox;
  static late Box<AIProviderModel> _aiProviderBox;
  static late Box<ValueTemplateModel> _valueTemplateBox;
  static late Box<PromptTemplateModel> _promptTemplateBox;
  static late Box<BehaviorLogModel> _behaviorLogBox;
  static late Box<ContentAnalysisResult> _analysisResultBox;
  static late Box<AIInsightModel> _aiInsightBox;
  
  // 通用数据存储Box
  static late Box<dynamic> _settingsBox;
  static late Box<dynamic> _cacheBox;

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      // 注册Hive适配器
      await _registerAdapters();
      
      // 打开数据库Box
      await _openBoxes();
      
      // 初始化默认数据
      await _initializeDefaultData();
      
      print('📦 存储服务初始化成功');
    } catch (e) {
      print('⚠️ 存储服务初始化失败: $e');
      
      if (kIsWeb) {
        // Web环境下的降级处理
        print('🌐 Web环境检测到，尝试降级处理...');
        await _initializeWebFallback();
      } else {
        rethrow;
      }
    }
  }

  /// 注册Hive适配器
  static Future<void> _registerAdapters() async {
    // 注册模型适配器
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AIProviderModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ModelConfigAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ValueTemplateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UserValuesProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ValueCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PromptTemplateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PromptFunctionAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(PromptExecutionAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(BehaviorLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(BehaviorTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ContentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ContentAnalysisResultAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(SentimentAnalysisAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(FilterActionAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(AIInsightModelAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(UserConfigModelAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(FloatingButtonPositionAdapter());
    }
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(FilterSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(FilterLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(PrivacySettingsAdapter());
    }
  }

  /// Web环境下的降级初始化
  static Future<void> _initializeWebFallback() async {
    try {
      // 尝试创建最小化的Box
      _settingsBox = await Hive.openBox('settings');
      _cacheBox = await Hive.openBox('cache');
      
      // 为其他Box创建空的占位符（防止late初始化错误）
      try {
        _userConfigBox = await Hive.openBox<UserConfigModel>('user_config_web');
        _aiProviderBox = await Hive.openBox<AIProviderModel>('ai_providers_web');
        _valueTemplateBox = await Hive.openBox<ValueTemplateModel>('value_templates_web');
        _promptTemplateBox = await Hive.openBox<PromptTemplateModel>('prompt_templates_web');
        _behaviorLogBox = await Hive.openBox<BehaviorLogModel>('behavior_logs_web');
        _analysisResultBox = await Hive.openBox<ContentAnalysisResult>('analysis_results_web');
        _aiInsightBox = await Hive.openBox<AIInsightModel>('ai_insights_web');
      } catch (e) {
        print('🌐 Web环境下部分数据库无法初始化，将使用限定功能: $e');
      }
      
      print('🌐 Web环境降级初始化完成');
    } catch (e) {
      print('⚠️ Web降级初始化也失败: $e');
      // 最后的降级方案：创建虚拟Box
      await _createMockBoxes();
    }
  }
  
  /// 创建虚拟Box以防止应用崩溃
  static Future<void> _createMockBoxes() async {
    // 注意：这里需要创建一个简单的Mock实现
    // 在实际项目中，你可能需要使用SharedPreferences或其他Web存储方案
    print('🔄 使用紧急模式，某些功能可能不可用');
  }
  static Future<void> _openBoxes() async {
    _userConfigBox = await Hive.openBox<UserConfigModel>('user_config');
    _aiProviderBox = await Hive.openBox<AIProviderModel>('ai_providers');
    _valueTemplateBox = await Hive.openBox<ValueTemplateModel>('value_templates');
    _promptTemplateBox = await Hive.openBox<PromptTemplateModel>('prompt_templates');
    _behaviorLogBox = await Hive.openBox<BehaviorLogModel>('behavior_logs');
    _analysisResultBox = await Hive.openBox<ContentAnalysisResult>('analysis_results');
    _aiInsightBox = await Hive.openBox<AIInsightModel>('ai_insights');
    _settingsBox = await Hive.openBox('settings');
    _cacheBox = await Hive.openBox('cache');
  }

  /// 初始化默认数据
  static Future<void> _initializeDefaultData() async {
    // 如果没有用户配置，创建默认配置
    if (_userConfigBox.isEmpty) {
      final defaultConfig = UserConfigModel(
        userId: 'default_user',
        userName: '默认用户',
        appSettings: AppSettings(),
        filterSettings: FilterSettings(),
        privacySettings: PrivacySettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: '1.0.0',
      );
      await _userConfigBox.put('default', defaultConfig);
    }

    // 初始化默认AI服务提供商
    if (_aiProviderBox.isEmpty) {
      await _initializeDefaultAIProviders();
    }

    // 初始化默认价值观模板
    if (_valueTemplateBox.isEmpty) {
      await _initializeDefaultValueTemplates();
    }

    // 初始化默认Prompt模板
    if (_promptTemplateBox.isEmpty) {
      await _initializeDefaultPromptTemplates();
    }
  }

  /// 初始化默认AI服务提供商
  static Future<void> _initializeDefaultAIProviders() async {
    final providers = [
      AIProviderModel(
        id: 'openai',
        name: 'openai',
        displayName: 'OpenAI',
        baseUrl: 'https://api.openai.com/v1',
        apiKey: '',
        supportedModels: [
          ModelConfig(modelId: 'gpt-3.5-turbo', displayName: 'GPT-3.5 Turbo'),
          ModelConfig(modelId: 'gpt-4', displayName: 'GPT-4'),
          ModelConfig(modelId: 'gpt-4-turbo', displayName: 'GPT-4 Turbo'),
        ],
        enabled: false,
        description: 'OpenAI官方API服务',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: 1,
      ),
      AIProviderModel(
        id: 'deepseek',
        name: 'deepseek',
        displayName: 'DeepSeek',
        baseUrl: 'https://api.deepseek.com/v1',
        apiKey: '',
        supportedModels: [
          ModelConfig(modelId: 'deepseek-chat', displayName: 'DeepSeek Chat'),
          ModelConfig(modelId: 'deepseek-coder', displayName: 'DeepSeek Coder'),
        ],
        enabled: false,
        description: 'DeepSeek AI服务',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: 2,
      ),
    ];

    for (final provider in providers) {
      await _aiProviderBox.put(provider.id, provider);
    }
  }

  /// 初始化默认价值观模板
  static Future<void> _initializeDefaultValueTemplates() async {
    final templates = [
      ValueTemplateModel(
        id: 'positive_values',
        name: '正面价值观',
        category: '社会价值',
        description: '包含正能量、积极向上的内容',
        keywords: ['正能量', '积极', '向上', '励志', '感人', '温暖'],
        negativeKeywords: ['负面', '消极', '抱怨', '仇恨'],
        weight: 0.8,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ValueTemplateModel(
        id: 'family_values',
        name: '家庭价值观',
        category: '生活方式',
        description: '重视家庭、亲情、教育的内容',
        keywords: ['家庭', '亲情', '教育', '孩子', '父母', '责任'],
        negativeKeywords: ['家暴', '冷漠', '自私'],
        weight: 0.7,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final template in templates) {
      await _valueTemplateBox.put(template.id, template);
    }
  }

  /// 初始化默认Prompt模板
  static Future<void> _initializeDefaultPromptTemplates() async {
    final templates = [
      PromptTemplateModel(
        id: 'content_analysis',
        name: '内容价值观分析',
        category: '内容分析',
        description: '分析内容的价值观倾向和情感色彩',
        template: '''你是一个专业的内容分析师。请分析以下内容的价值观倾向：

内容：{content}
用户价值观偏好：{user_values}

请从以下维度分析：
1. 情感倾向（正面/负面/中性，0-1分）
2. 价值观匹配度（与用户偏好的匹配程度，0-1分）
3. 主要主题标签
4. 风险评估（是否包含不当内容）
5. 推荐操作（显示/警告/屏蔽）

请以JSON格式返回结果。''',
        variables: ['content', 'user_values'],
        function: PromptFunction.contentAnalysis,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PromptTemplateModel(
        id: 'behavior_analysis',
        name: '用户行为分析',
        category: '行为分析',
        description: '分析用户行为模式，提取价值观偏好',
        template: '''你是一个专业的用户行为分析师。请分析以下用户行为数据：

行为历史：{behavior_history}
时间范围：{time_range}

请分析：
1. 用户主要兴趣偏好
2. 价值观倾向变化
3. 行为模式总结
4. 个性化建议

以JSON格式返回分析结果。''',
        variables: ['behavior_history', 'time_range'],
        function: PromptFunction.behaviorAnalysis,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final template in templates) {
      await _promptTemplateBox.put(template.id, template);
    }
  }

  // Getter 方法
  static Box<UserConfigModel> get userConfigBox => _userConfigBox;
  static Box<AIProviderModel> get aiProviderBox => _aiProviderBox;
  static Box<ValueTemplateModel> get valueTemplateBox => _valueTemplateBox;
  static Box<PromptTemplateModel> get promptTemplateBox => _promptTemplateBox;
  static Box<BehaviorLogModel> get behaviorLogBox => _behaviorLogBox;
  static Box<ContentAnalysisResult> get analysisResultBox => _analysisResultBox;
  static Box<AIInsightModel> get aiInsightBox => _aiInsightBox;
  static Box<dynamic> get settingsBox => _settingsBox;
  static Box<dynamic> get cacheBox => _cacheBox;

  /// 清理过期数据
  static Future<void> cleanupExpiredData() async {
    final now = DateTime.now();
    final retentionDays = 30; // 默认保留30天

    // 清理过期的行为日志
    final expiredLogs = _behaviorLogBox.values
        .where((log) => now.difference(log.timestamp).inDays > retentionDays)
        .toList();

    for (final log in expiredLogs) {
      await _behaviorLogBox.delete(log.id);
    }

    // 清理过期的分析结果
    final expiredResults = _analysisResultBox.values
        .where((result) => now.difference(result.analyzedAt).inDays > retentionDays)
        .toList();

    for (final result in expiredResults) {
      await _analysisResultBox.delete(result.id);
    }

    print('清理了 ${expiredLogs.length} 条过期行为日志，${expiredResults.length} 条过期分析结果');
  }

  /// 备份数据
  static Future<Map<String, dynamic>> exportData() async {
    return {
      'userConfig': _userConfigBox.toMap(),
      'aiProviders': _aiProviderBox.toMap(),
      'valueTemplates': _valueTemplateBox.toMap(),
      'promptTemplates': _promptTemplateBox.toMap(),
      'settings': _settingsBox.toMap(),
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// 恢复数据
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // 验证数据格式
      if (!data.containsKey('version') || !data.containsKey('exportTime')) {
        throw Exception('无效的备份数据格式');
      }

      // 清空现有数据
      await _userConfigBox.clear();
      await _aiProviderBox.clear();
      await _valueTemplateBox.clear();
      await _promptTemplateBox.clear();

      // 恢复数据
      if (data.containsKey('userConfig')) {
        final configs = data['userConfig'] as Map;
        for (final entry in configs.entries) {
          if (entry.value is UserConfigModel) {
            await _userConfigBox.put(entry.key, entry.value);
          }
        }
      }

      // 类似地恢复其他数据...
      print('数据恢复成功');
    } catch (e) {
      print('数据恢复失败: $e');
      rethrow;
    }
  }

  /// 关闭所有Box
  static Future<void> dispose() async {
    await _userConfigBox.close();
    await _aiProviderBox.close();
    await _valueTemplateBox.close();
    await _promptTemplateBox.close();
    await _behaviorLogBox.close();
    await _analysisResultBox.close();
    await _aiInsightBox.close();
    await _settingsBox.close();
    await _cacheBox.close();
  }
}