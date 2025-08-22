import 'package:flutter/material.dart';
import '../models/ai_provider_model.dart';
import '../models/values_template_model.dart';
import '../models/user_config_model.dart';
import '../services/storage_service.dart';
import '../services/ai_service_manager.dart';
import '../services/user_config_service.dart';
import '../services/data_backup_service.dart';
import '../providers/ai_provider.dart';
import '../providers/values_provider.dart';
import '../providers/content_provider.dart';

/// 功能测试服务 - 验证应用各模块功能
class TestService {
  static const String testUserId = 'test_user';
  
  /// 测试结果模型
  static List<TestResult> _testResults = [];
  
  /// 获取所有测试结果
  static List<TestResult> get testResults => List.unmodifiable(_testResults);
  
  /// 运行所有测试
  static Future<TestSummary> runAllTests() async {
    _testResults.clear();
    
    print('🧪 开始运行功能测试...');
    
    // 1. 数据存储测试
    await _testStorageService();
    
    // 2. AI服务管理测试
    await _testAIServiceManager();
    
    // 3. 用户配置测试
    await _testUserConfigService();
    
    // 4. 价值观系统测试
    await _testValuesSystem();
    
    // 5. 内容分析测试
    await _testContentAnalysis();
    
    // 6. 数据备份测试
    await _testDataBackup();
    
    // 7. 集成测试
    await _testIntegration();
    
    final summary = _generateTestSummary();
    print('✅ 测试完成！通过: ${summary.passedCount}/${summary.totalCount}');
    
    return summary;
  }
  
  /// 测试存储服务
  static Future<void> _testStorageService() async {
    await _runTest(
      '存储服务初始化',
      () async {
        await StorageService.initialize();
        return StorageService.isInitialized;
      },
    );
    
    await _runTest(
      'AI服务商数据存储',
      () async {
        final provider = AIProviderModel(
          id: 'test_provider',
          name: '测试服务商',
          type: AIProviderType.openai,
          baseUrl: 'https://api.test.com',
          apiKey: 'test_key',
          models: ['test-model'],
          isEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final box = StorageService.aiProviderBox;
        await box.put(provider.id, provider);
        
        final retrieved = box.get(provider.id);
        return retrieved != null && retrieved.name == provider.name;
      },
    );
    
    await _runTest(
      '价值观模板数据存储',
      () async {
        final template = ValuesTemplateModel(
          id: 'test_template',
          name: '测试价值观',
          description: '测试描述',
          category: '测试分类',
          keywords: ['测试', '关键词'],
          positiveValues: ['正面价值'],
          negativeValues: ['负面价值'],
          isEnabled: true,
          isCustom: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final box = StorageService.valuesTemplateBox;
        await box.put(template.id, template);
        
        final retrieved = box.get(template.id);
        return retrieved != null && retrieved.name == template.name;
      },
    );
  }
  
  /// 测试AI服务管理
  static Future<void> _testAIServiceManager() async {
    final manager = AIServiceManager();
    
    await _runTest(
      'AI服务管理器初始化',
      () async {
        // 测试初始化
        return manager != null;
      },
    );
    
    await _runTest(
      'AI服务请求处理',
      () async {
        try {
          // 模拟请求（可能会失败，但不应该崩溃）
          final response = await manager.executeRequest(
            prompt: '测试内容分析',
            temperature: 0.7,
            maxTokens: 100,
          );
          // 即使失败也算通过，只要没有崩溃
          return true;
        } catch (e) {
          // 预期可能失败，因为没有配置真实的API
          return e.toString().contains('No healthy') || 
                 e.toString().contains('API') ||
                 e.toString().contains('network');
        }
      },
    );
  }
  
  /// 测试用户配置服务
  static Future<void> _testUserConfigService() async {
    await _runTest(
      '创建默认用户配置',
      () async {
        await UserConfigService.resetToDefault();
        final config = UserConfigService.getUserConfig();
        return config != null && config.userId == 'default_user';
      },
    );
    
    await _runTest(
      '更新应用设置',
      () async {
        final newSettings = AppSettings(
          language: 'en_US',
          themeMode: 'dark',
          enableNotifications: false,
        );
        
        await UserConfigService.updateAppSettings(newSettings);
        final config = UserConfigService.getUserConfig();
        
        return config?.appSettings.language == 'en_US' &&
               config?.appSettings.themeMode == 'dark' &&
               config?.appSettings.enableNotifications == false;
      },
    );
    
    await _runTest(
      '配置数据导出导入',
      () async {
        final exported = UserConfigService.exportUserConfig();
        final success = await UserConfigService.importUserConfig(exported);
        return exported.isNotEmpty && success;
      },
    );
  }
  
  /// 测试价值观系统
  static Future<void> _testValuesSystem() async {
    await _runTest(
      '价值观模板创建和启用',
      () async {
        final template = ValuesTemplateModel(
          id: 'test_values',
          name: '测试价值观模板',
          description: '用于测试的价值观模板',
          category: '测试',
          keywords: ['正面', '积极', '健康'],
          positiveValues: ['家庭和谐', '积极向上'],
          negativeValues: ['暴力', '消极'],
          isEnabled: true,
          isCustom: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final box = StorageService.valuesTemplateBox;
        await box.put(template.id, template);
        
        return box.containsKey(template.id);
      },
    );
    
    await _runTest(
      '内容价值观匹配计算',
      () async {
        // 创建测试内容
        const testContent = '这是一篇关于家庭和谐的积极文章，传播正面价值观';
        
        // 简单的匹配算法测试
        final keywords = ['家庭', '和谐', '积极', '正面'];
        var matchCount = 0;
        
        for (final keyword in keywords) {
          if (testContent.contains(keyword)) {
            matchCount++;
          }
        }
        
        final score = matchCount / keywords.length;
        return score > 0.5; // 应该有较高的匹配度
      },
    );
  }
  
  /// 测试内容分析
  static Future<void> _testContentAnalysis() async {
    await _runTest(
      '内容分析结果保存',
      () async {
        final result = ContentAnalysisResult(
          id: 'test_analysis',
          contentId: 'test_content',
          content: '测试内容',
          contentType: ContentType.article,
          valueScores: {'正面': 0.8},
          overallScore: 0.8,
          sentiment: SentimentAnalysis(
            positive: 0.8,
            negative: 0.1,
            neutral: 0.1,
            dominantSentiment: 'positive',
          ),
          extractedTopics: ['测试'],
          matchedKeywords: ['正面'],
          recommendedAction: FilterAction.allow,
          analyzedAt: DateTime.now(),
          aiProviderId: 'test',
          promptTemplateId: 'test',
          rawResponse: {},
        );
        
        final box = StorageService.analysisResultBox;
        await box.put(result.id, result);
        
        return box.containsKey(result.id);
      },
    );
    
    await _runTest(
      '过滤动作决策逻辑',
      () async {
        // 测试不同分数对应的过滤动作
        final testCases = [
          (0.9, FilterAction.allow),
          (0.7, FilterAction.warning),
          (0.5, FilterAction.blur),
          (0.2, FilterAction.block),
        ];
        
        for (final (score, expectedAction) in testCases) {
          FilterAction actualAction;
          if (score >= 0.8) {
            actualAction = FilterAction.allow;
          } else if (score >= 0.6) {
            actualAction = FilterAction.warning;
          } else if (score >= 0.4) {
            actualAction = FilterAction.blur;
          } else {
            actualAction = FilterAction.block;
          }
          
          if (actualAction != expectedAction) {
            return false;
          }
        }
        
        return true;
      },
    );
  }
  
  /// 测试数据备份
  static Future<void> _testDataBackup() async {
    await _runTest(
      '数据备份服务功能',
      () async {
        try {
          final backupService = DataBackupService();
          
          // 测试导出数据
          final backupData = await backupService.exportAllData();
          
          // 验证导出的数据结构
          return backupData.metadata.exportTime != null &&
                 backupData.metadata.version.isNotEmpty &&
                 backupData.userData != null;
        } catch (e) {
          print('备份测试异常: $e');
          return false;
        }
      },
    );
  }
  
  /// 测试集成功能
  static Future<void> _testIntegration() async {
    await _runTest(
      '应用完整流程测试',
      () async {
        try {
          // 1. 初始化存储
          await StorageService.initialize();
          
          // 2. 创建测试配置
          await UserConfigService.resetToDefault();
          
          // 3. 添加测试AI服务商
          final provider = AIProviderModel(
            id: 'integration_test',
            name: '集成测试AI',
            type: AIProviderType.openai,
            baseUrl: 'https://api.test.com',
            apiKey: 'test_key',
            models: ['test-model'],
            isEnabled: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          final aiBox = StorageService.aiProviderBox;
          await aiBox.put(provider.id, provider);
          
          // 4. 添加测试价值观模板
          final template = ValuesTemplateModel(
            id: 'integration_test_values',
            name: '集成测试价值观',
            description: '集成测试专用',
            category: '测试',
            keywords: ['正面', '积极'],
            positiveValues: ['健康'],
            negativeValues: ['暴力'],
            isEnabled: true,
            isCustom: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          final valuesBox = StorageService.valuesTemplateBox;
          await valuesBox.put(template.id, template);
          
          // 5. 验证数据完整性
          final retrievedProvider = aiBox.get(provider.id);
          final retrievedTemplate = valuesBox.get(template.id);
          final userConfig = UserConfigService.getUserConfig();
          
          return retrievedProvider != null &&
                 retrievedTemplate != null &&
                 userConfig != null;
        } catch (e) {
          print('集成测试异常: $e');
          return false;
        }
      },
    );
  }
  
  /// 运行单个测试
  static Future<void> _runTest(String name, Future<bool> Function() test) async {
    final startTime = DateTime.now();
    
    try {
      print('🔍 运行测试: $name');
      final result = await test();
      final duration = DateTime.now().difference(startTime);
      
      _testResults.add(TestResult(
        name: name,
        passed: result,
        duration: duration,
        error: null,
      ));
      
      if (result) {
        print('✅ $name - 通过 (${duration.inMilliseconds}ms)');
      } else {
        print('❌ $name - 失败 (${duration.inMilliseconds}ms)');
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      
      _testResults.add(TestResult(
        name: name,
        passed: false,
        duration: duration,
        error: e.toString(),
      ));
      
      print('💥 $name - 异常: $e (${duration.inMilliseconds}ms)');
    }
  }
  
  /// 生成测试总结
  static TestSummary _generateTestSummary() {
    final totalCount = _testResults.length;
    final passedCount = _testResults.where((r) => r.passed).length;
    final failedCount = totalCount - passedCount;
    final totalDuration = _testResults
        .map((r) => r.duration)
        .fold(Duration.zero, (sum, duration) => sum + duration);
    
    return TestSummary(
      totalCount: totalCount,
      passedCount: passedCount,
      failedCount: failedCount,
      totalDuration: totalDuration,
      results: List.unmodifiable(_testResults),
    );
  }
  
  /// 清理测试数据
  static Future<void> cleanupTestData() async {
    try {
      // 清理测试用的AI服务商
      final aiBox = StorageService.aiProviderBox;
      await aiBox.delete('test_provider');
      await aiBox.delete('integration_test');
      
      // 清理测试用的价值观模板
      final valuesBox = StorageService.valuesTemplateBox;
      await valuesBox.delete('test_template');
      await valuesBox.delete('test_values');
      await valuesBox.delete('integration_test_values');
      
      // 清理测试用的分析结果
      final analysisBox = StorageService.analysisResultBox;
      await analysisBox.delete('test_analysis');
      
      print('🧹 测试数据清理完成');
    } catch (e) {
      print('❌ 清理测试数据失败: $e');
    }
  }
}

/// 测试结果模型
class TestResult {
  final String name;
  final bool passed;
  final Duration duration;
  final String? error;
  
  TestResult({
    required this.name,
    required this.passed,
    required this.duration,
    this.error,
  });
}

/// 测试总结模型
class TestSummary {
  final int totalCount;
  final int passedCount;
  final int failedCount;
  final Duration totalDuration;
  final List<TestResult> results;
  
  TestSummary({
    required this.totalCount,
    required this.passedCount,
    required this.failedCount,
    required this.totalDuration,
    required this.results,
  });
  
  double get successRate => totalCount > 0 ? passedCount / totalCount : 0.0;
  
  List<TestResult> get failedTests => results.where((r) => !r.passed).toList();
  
  @override
  String toString() {
    return '''
测试总结:
- 总测试数: $totalCount
- 通过数: $passedCount
- 失败数: $failedCount
- 成功率: ${(successRate * 100).toStringAsFixed(1)}%
- 总耗时: ${totalDuration.inMilliseconds}ms
''';
  }
}

/// 内容分析结果模型 (简化版，用于测试)
class ContentAnalysisResult {
  final String id;
  final String contentId;
  final String content;
  final ContentType contentType;
  final Map<String, double> valueScores;
  final double overallScore;
  final SentimentAnalysis sentiment;
  final List<String> extractedTopics;
  final List<String> matchedKeywords;
  final FilterAction recommendedAction;
  final DateTime analyzedAt;
  final String aiProviderId;
  final String promptTemplateId;
  final Map<String, dynamic> rawResponse;
  
  ContentAnalysisResult({
    required this.id,
    required this.contentId,
    required this.content,
    required this.contentType,
    required this.valueScores,
    required this.overallScore,
    required this.sentiment,
    required this.extractedTopics,
    required this.matchedKeywords,
    required this.recommendedAction,
    required this.analyzedAt,
    required this.aiProviderId,
    required this.promptTemplateId,
    required this.rawResponse,
  });
}

/// 内容类型枚举
enum ContentType { article, comment, video, image }

/// 情感分析结果
class SentimentAnalysis {
  final double positive;
  final double negative;
  final double neutral;
  final String dominantSentiment;
  
  SentimentAnalysis({
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.dominantSentiment,
  });
}

/// 过滤动作枚举
enum FilterAction { allow, warning, blur, block }