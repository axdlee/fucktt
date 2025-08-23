import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'mocks/mock_path_provider.dart';

/// 测试初始化配置
class TestHelper {
  static bool _isInitialized = false;
  
  /// 初始化测试环境
  static Future<void> initializeTestEnvironment() async {
    if (_isInitialized) return;
    
    // 初始化Hive
    await _initializeHive();
    
    // 设置测试环境标志
    _isInitialized = true;
  }
  
  /// 初始化Hive用于测试
  static Future<void> _initializeHive() async {
    // 使用内存存储
    PathProviderPlatform.instance = MockPathProvider();
    
    // 初始化Hive
    Hive.init('./test/temp');
    
    // 注册适配器（如果需要）
    // Hive.registerAdapter(AIProviderModelAdapter());
  }
  
  /// 清理测试环境
  static Future<void> cleanupTestEnvironment() async {
    // 清理Hive
    await Hive.deleteFromDisk();
    await Hive.close();
    
    _isInitialized = false;
  }
  
  /// 创建测试用的临时Box
  static Future<Box<T>> createTestBox<T>(String name) async {
    await initializeTestEnvironment();
    return await Hive.openBox<T>('test_$name');
  }
  
  /// 创建测试数据
  static Map<String, dynamic> createTestAIProvider({
    String id = 'test_ai_provider',
    String name = 'Test AI Provider',
    String displayName = 'Test Provider',
    String type = 'OpenAI',
    String apiKey = 'test_api_key',
    String baseUrl = 'https://api.test.com/v1',
    bool enabled = true,
    int priority = 1,
  }) {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'type': type,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'enabled': enabled,
      'priority': priority,
      'supportedModels': ['gpt-3.5-turbo', 'gpt-4'],
      'maxTokens': 4096,
      'temperature': 0.7,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// 创建测试用的价值观模板
  static Map<String, dynamic> createTestValueTemplate({
    String id = 'test_value_template',
    String name = 'Test Value',
    String category = '测试分类',
    String description = 'Test description',
    List<String> keywords = const ['positive', 'test'],
    List<String> negativeKeywords = const ['negative'],
    double weight = 0.5,
    bool enabled = true,
  }) {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'keywords': keywords,
      'negativeKeywords': negativeKeywords,
      'weight': weight,
      'enabled': enabled,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// 创建测试用的用户配置
  static Map<String, dynamic> createTestUserConfig({
    String userId = 'test_user',
    String displayName = 'Test User',
    List<String> blacklist = const ['spam', 'ads'],
    List<String> whitelist = const ['important', 'news'],
  }) {
    return {
      'userId': userId,
      'displayName': displayName,
      'blacklist': blacklist,
      'whitelist': whitelist,
      'preferences': {
        'autoFilter': true,
        'strictMode': false,
        'notificationEnabled': true,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// 等待异步操作完成
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  
  /// 验证所有box都已关闭
  static Future<void> verifyBoxesClosed() async {
    expect(Hive.isBoxOpen('test_ai_providers'), false);
    expect(Hive.isBoxOpen('test_value_templates'), false);
    expect(Hive.isBoxOpen('test_user_config'), false);
  }
}

/// 自定义测试匹配器
class TestMatchers {
  /// 验证AI提供商数据结构
  static Matcher hasValidAIProviderStructure() {
    return predicate<Map<String, dynamic>>((map) {
      return map.containsKey('id') &&
             map.containsKey('name') &&
             map.containsKey('apiKey') &&
             map.containsKey('baseUrl') &&
             map.containsKey('enabled') &&
             map['id'] is String &&
             map['name'] is String &&
             map['apiKey'] is String &&
             map['baseUrl'] is String &&
             map['enabled'] is bool;
    }, 'has valid AI provider structure');
  }
  
  /// 验证价值观模板数据结构
  static Matcher hasValidValueTemplateStructure() {
    return predicate<Map<String, dynamic>>((map) {
      return map.containsKey('id') &&
             map.containsKey('name') &&
             map.containsKey('category') &&
             map.containsKey('keywords') &&
             map.containsKey('weight') &&
             map['id'] is String &&
             map['name'] is String &&
             map['category'] is String &&
             map['keywords'] is List &&
             map['weight'] is double;
    }, 'has valid value template structure');
  }
  
  /// 验证URL格式
  static Matcher isValidUrl() {
    return predicate<String>((url) {
      try {
        final uri = Uri.parse(url);
        return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
      } catch (e) {
        return false;
      }
    }, 'is valid URL');
  }
}