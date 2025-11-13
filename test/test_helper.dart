import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:synchronized/synchronized.dart';
import 'package:value_filter/services/storage_service.dart';
import 'package:value_filter/models/value_template_model.dart';
import 'package:value_filter/models/ai_provider_model.dart';

import 'mocks/mock_path_provider.dart';

/// 测试初始化配置
class TestHelper {
  static bool _isInitialized = false;
  static final _lock = Lock();
  static final Set<String> _openedBoxes = {};

  /// 初始化测试环境
  static Future<void> initializeTestEnvironment() async {
    // 使用互斥锁防止并发初始化
    await _lock.synchronized(() async {
      if (_isInitialized) return;

      // 初始化Hive
      await _initializeHive();

      // 注意：不在测试环境中初始化 StorageService
      // 原因：StorageService会打开所有Box，导致并发测试时文件锁冲突
      // 解决方案：每个测试使用独立的测试Box

      // 设置测试环境标志
      _isInitialized = true;
    });
  }

  /// 初始化Hive用于测试
  static Future<void> _initializeHive() async {
    // 使用内存存储
    PathProviderPlatform.instance = MockPathProvider();

    // 初始化Hive
    Hive.init('./test/temp');

    // 预注册必要的适配器
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AIProviderModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ValueTemplateModelAdapter());
    }
  }

  /// 清理测试环境
  static Future<void> cleanupTestEnvironment() async {
    await _lock.synchronized(() async {
      // 关闭所有已打开的测试Box
      for (final boxName in _openedBoxes.toList()) {
        if (Hive.isBoxOpen(boxName)) {
          try {
            await Hive.box(boxName).close();
          } catch (e) {
            print('⚠️ 关闭Box失败: $boxName - $e');
          }
        }
      }
      _openedBoxes.clear();

      // 重置StorageService状态
      await StorageService.reset();

      // 清理Hive
      try {
        await Hive.deleteFromDisk();
        await Hive.close();
      } catch (e) {
        print('⚠️ 清理Hive失败: $e');
      }

      _isInitialized = false;
    });
  }

  /// 创建测试用的临时Box
  static Future<Box<T>> createTestBox<T>(String name) async {
    await initializeTestEnvironment();

    return await _lock.synchronized(() async {
      final boxName = 'test_$name';

      // 如果Box已经打开，先关闭它
      if (Hive.isBoxOpen(boxName)) {
        try {
          await Hive.box<T>(boxName).close();
          _openedBoxes.remove(boxName);
        } catch (e) {
          print('⚠️ 关闭已存在的Box失败: $boxName - $e');
        }
      }

      // 打开新的Box
      final box = await Hive.openBox<T>(boxName);
      _openedBoxes.add(boxName);
      return box;
    });
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
        return uri.isAbsolute &&
            (uri.scheme == 'http' || uri.scheme == 'https');
      } catch (e) {
        return false;
      }
    }, 'is valid URL');
  }
}
