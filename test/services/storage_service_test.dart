import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:value_filter/services/storage_service.dart';
import 'package:value_filter/models/ai_provider_model.dart';
import 'package:value_filter/models/value_template_model.dart';
import '../test_helper.dart';

void main() {
  group('StorageService Tests', () {
    setUp(() async {
      await TestHelper.initializeTestEnvironment();
    });

    tearDown(() async {
      await TestHelper.cleanupTestEnvironment();
    });

    test('should initialize Hive boxes correctly', () async {
      // 验证box是否已初始化
      expect(Hive.isBoxOpen('ai_providers'), isTrue);
      expect(Hive.isBoxOpen('value_templates'), isTrue);
      expect(Hive.isBoxOpen('settings'), isTrue);
      expect(Hive.isBoxOpen('behavior_logs'), isTrue);
    });

    test('should store and retrieve AI provider data', () async {
      final testProvider = AIProviderModel(
        id: 'test_storage_provider',
        name: 'TestAI',
        displayName: 'Test Storage AI',
        baseUrl: 'https://api.test.com',
        apiKey: 'test_key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = StorageService.aiProviderBox;
      await box.put(testProvider.id, testProvider);

      final retrieved = box.get(testProvider.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(testProvider.id));
      expect(retrieved.name, equals(testProvider.name));
      expect(retrieved.displayName, equals(testProvider.displayName));
    });

    test('should store and retrieve value template data', () async {
      final testTemplate = ValueTemplateModel(
        id: 'test_storage_template',
        name: '存储测试价值观',
        description: '用于测试存储功能的价值观模板',
        category: '测试分类',
        keywords: ['存储', '测试'],
        negativeKeywords: ['错误'],
        enabled: true,
        weight: 0.6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = StorageService.valueTemplateBox;
      await box.put(testTemplate.id, testTemplate);

      final retrieved = box.get(testTemplate.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(testTemplate.id));
      expect(retrieved.name, equals(testTemplate.name));
      expect(retrieved.keywords, equals(testTemplate.keywords));
    });

    test('should handle multiple data operations', () async {
      final aiBox = StorageService.aiProviderBox;
      final valueBox = StorageService.valueTemplateBox;

      // 存储多个AI提供商
      final providers = List.generate(5, (index) => AIProviderModel(
        id: 'provider_$index',
        name: 'Provider $index',
        displayName: 'Provider $index',
        baseUrl: 'https://api$index.test.com',
        apiKey: 'key_$index',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      for (final provider in providers) {
        await aiBox.put(provider.id, provider);
      }

      // 存储多个价值观模板
      final templates = List.generate(3, (index) => ValueTemplateModel(
        id: 'template_$index',
        name: '模板 $index',
        description: '测试模板 $index',
        category: '测试',
        keywords: ['关键词$index'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5 + (index * 0.1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      for (final template in templates) {
        await valueBox.put(template.id, template);
      }

      // 验证数据存储
      expect(aiBox.length, equals(5));
      expect(valueBox.length, equals(3));

      // 验证数据检索
      final retrievedProvider = aiBox.get('provider_2');
      expect(retrievedProvider, isNotNull);
      expect(retrievedProvider!.name, equals('Provider 2'));

      final retrievedTemplate = valueBox.get('template_1');
      expect(retrievedTemplate, isNotNull);
      expect(retrievedTemplate!.name, equals('模板 1'));
    });

    test('should handle data deletion', () async {
      final aiBox = StorageService.aiProviderBox;
      
      final testProvider = AIProviderModel(
        id: 'delete_test_provider',
        name: 'DeleteTest',
        displayName: 'Delete Test Provider',
        baseUrl: 'https://api.delete.com',
        apiKey: 'delete_key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 存储数据
      await aiBox.put(testProvider.id, testProvider);
      expect(aiBox.containsKey(testProvider.id), isTrue);

      // 删除数据
      await aiBox.delete(testProvider.id);
      expect(aiBox.containsKey(testProvider.id), isFalse);
      expect(aiBox.get(testProvider.id), isNull);
    });

    test('should handle settings storage', () async {
      final settingsBox = StorageService.settingsBox;

      // 存储设置
      await settingsBox.put('theme', 'dark');
      await settingsBox.put('language', 'zh_CN');
      await settingsBox.put('notifications_enabled', true);
      await settingsBox.put('filter_level', 0.7);

      // 验证设置存储
      expect(settingsBox.get('theme'), equals('dark'));
      expect(settingsBox.get('language'), equals('zh_CN'));
      expect(settingsBox.get('notifications_enabled'), isTrue);
      expect(settingsBox.get('filter_level'), equals(0.7));
    });

    test('should handle data update operations', () async {
      final valueBox = StorageService.valueTemplateBox;
      
      final originalTemplate = ValueTemplateModel(
        id: 'update_test_template',
        name: '原始模板',
        description: '原始描述',
        category: '原始分类',
        keywords: ['原始'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 存储原始数据
      await valueBox.put(originalTemplate.id, originalTemplate);

      // 更新数据
      final updatedTemplate = originalTemplate.copyWith(
        name: '更新后的模板',
        description: '更新后的描述',
        keywords: ['更新', '测试'],
        weight: 0.8,
      );

      await valueBox.put(updatedTemplate.id, updatedTemplate);

      // 验证更新
      final retrieved = valueBox.get(updatedTemplate.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('更新后的模板'));
      expect(retrieved.description, equals('更新后的描述'));
      expect(retrieved.keywords, equals(['更新', '测试']));
      expect(retrieved.weight, equals(0.8));
      expect(retrieved.id, equals(originalTemplate.id)); // ID应该保持不变
    });

    test('should handle large data sets efficiently', () async {
      final settingsBox = StorageService.settingsBox;
      
      // 存储大量设置数据
      final startTime = DateTime.now();
      
      for (int i = 0; i < 1000; i++) {
        await settingsBox.put('setting_$i', 'value_$i');
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // 验证性能（应该在合理时间内完成）
      expect(duration.inSeconds, lessThan(10));
      expect(settingsBox.length, equals(1000));
      
      // 验证数据完整性
      expect(settingsBox.get('setting_0'), equals('value_0'));
      expect(settingsBox.get('setting_500'), equals('value_500'));
      expect(settingsBox.get('setting_999'), equals('value_999'));
    });

    test('should handle box queries and filters', () async {
      final aiBox = StorageService.aiProviderBox;
      
      // 创建测试数据
      final providers = [
        AIProviderModel(
          id: 'openai_test',
          name: 'OpenAI',
          displayName: 'OpenAI Test',
          baseUrl: 'https://api.openai.com',
          apiKey: 'openai_key',
          enabled: true,
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AIProviderModel(
          id: 'deepseek_test',
          name: 'DeepSeek',
          displayName: 'DeepSeek Test',
          baseUrl: 'https://api.deepseek.com',
          apiKey: 'deepseek_key',
          enabled: false,
          priority: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AIProviderModel(
          id: 'claude_test',
          name: 'Claude',
          displayName: 'Claude Test',
          baseUrl: 'https://api.anthropic.com',
          apiKey: 'claude_key',
          enabled: true,
          priority: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final provider in providers) {
        await aiBox.put(provider.id, provider);
      }

      // 测试过滤查询
      final enabledProviders = aiBox.values.where((p) => p.enabled).toList();
      expect(enabledProviders.length, equals(2));
      expect(enabledProviders.every((p) => p.enabled), isTrue);

      final disabledProviders = aiBox.values.where((p) => !p.enabled).toList();
      expect(disabledProviders.length, equals(1));
      expect(disabledProviders.first.name, equals('DeepSeek'));

      // 测试排序
      final sortedByPriority = aiBox.values.toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
      expect(sortedByPriority.first.name, equals('OpenAI'));
      expect(sortedByPriority.last.name, equals('Claude'));
    });
  });
}