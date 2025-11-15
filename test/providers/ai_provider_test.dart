import 'package:flutter_test/flutter_test.dart';
import 'package:value_filter/providers/ai_provider.dart';
import 'package:value_filter/models/ai_provider_model.dart';
import '../test_helper.dart';

void main() {
  group('AIProvider Tests', () {
    late AIProvider aiProvider;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();

      // 创建测试专用的Box
      final testBox = await TestHelper.createTestBox<AIProviderModel>('ai_providers');
      await testBox.clear();

      aiProvider = AIProvider();
      // 设置测试Box
      aiProvider.setTestBox(testBox);
    });

    tearDown(() async {
      aiProvider.dispose();
      await TestHelper.cleanupTestEnvironment();
    });

    test('should initialize with correct default state', () {
      expect(aiProvider.isInitialized, isFalse);
      expect(aiProvider.isLoading, isFalse);
      expect(aiProvider.errorMessage, isNull);
      expect(aiProvider.providers, isEmpty);
      expect(aiProvider.healthStatus, isEmpty);
      expect(aiProvider.hasAvailableServices, isFalse);
      expect(aiProvider.enabledProviders, isEmpty);
      expect(aiProvider.healthyProviders, isEmpty);
    });

    test('should initialize successfully', () async {
      await aiProvider.initialize();
      
      expect(aiProvider.isInitialized, isTrue);
      expect(aiProvider.isLoading, isFalse);
      expect(aiProvider.errorMessage, isNull);
    });

    test('should add AI provider successfully', () async {
      await aiProvider.initialize();

      final testProvider = AIProviderModel(
        id: 'test_provider',
        name: 'TestAI',
        displayName: 'Test AI Provider',
        baseUrl: 'https://api.test.com/v1',
        apiKey: 'test_key',
        supportedModels: [
          ModelConfig(
            modelId: 'test-model',
            displayName: 'Test Model',
          ),
        ],
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      // 检查是否有错误
      if (aiProvider.errorMessage != null) {
        print('Error: ${aiProvider.errorMessage}');
      }

      expect(aiProvider.providers.length, equals(1));
      expect(aiProvider.providers.first.id, equals(testProvider.id));
      expect(aiProvider.providers.first.name, equals(testProvider.name));
    });

    test('should update AI provider successfully', () async {
      await aiProvider.initialize();
      
      final originalProvider = AIProviderModel(
        id: 'update_test_provider',
        name: 'OriginalAI',
        displayName: 'Original AI Provider',
        baseUrl: 'https://api.original.com/v1',
        apiKey: 'original_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(originalProvider);

      final updatedProvider = originalProvider.copyWith(
        name: 'UpdatedAI',
        displayName: 'Updated AI Provider',
        baseUrl: 'https://api.updated.com/v1',
      );

      await aiProvider.updateProvider(updatedProvider);

      final retrieved = aiProvider.getProvider(originalProvider.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('UpdatedAI'));
      expect(retrieved.displayName, equals('Updated AI Provider'));
      expect(retrieved.baseUrl, equals('https://api.updated.com/v1'));
    });

    test('should remove AI provider successfully', () async {
      await aiProvider.initialize();
      
      final testProvider = AIProviderModel(
        id: 'remove_test_provider',
        name: 'RemoveTestAI',
        displayName: 'Remove Test AI Provider',
        baseUrl: 'https://api.remove.com/v1',
        apiKey: 'remove_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);
      expect(aiProvider.providers.length, equals(1));

      await aiProvider.removeProvider(testProvider.id);
      expect(aiProvider.providers.isEmpty, isTrue);
      expect(aiProvider.getProvider(testProvider.id), isNull);
    });

    test('should toggle provider enabled state', () async {
      await aiProvider.initialize();
      
      final testProvider = AIProviderModel(
        id: 'toggle_test_provider',
        name: 'ToggleTestAI',
        displayName: 'Toggle Test AI Provider',
        baseUrl: 'https://api.toggle.com/v1',
        apiKey: 'toggle_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);
      
      // 验证初始状态
      expect(aiProvider.getProvider(testProvider.id)!.enabled, isTrue);

      // 切换状态
      await aiProvider.toggleProvider(testProvider.id);
      expect(aiProvider.getProvider(testProvider.id)!.enabled, isFalse);

      // 再次切换
      await aiProvider.toggleProvider(testProvider.id);
      expect(aiProvider.getProvider(testProvider.id)!.enabled, isTrue);
    });

    test('should set provider priority correctly', () async {
      await aiProvider.initialize();
      
      final provider1 = AIProviderModel(
        id: 'priority_test_1',
        name: 'PriorityTest1',
        displayName: 'Priority Test 1',
        baseUrl: 'https://api.test1.com/v1',
        apiKey: 'test_key_1',
        priority: 3,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(provider1);
      
      // 更新优先级
      await aiProvider.setProviderPriority(provider1.id, 1);
      
      final updated = aiProvider.getProvider(provider1.id);
      expect(updated!.priority, equals(1));
    });

    test('should filter enabled providers correctly', () async {
      await aiProvider.initialize();
      
      final enabledProvider = AIProviderModel(
        id: 'enabled_provider',
        name: 'EnabledAI',
        displayName: 'Enabled AI Provider',
        baseUrl: 'https://api.enabled.com/v1',
        apiKey: 'enabled_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final disabledProvider = AIProviderModel(
        id: 'disabled_provider',
        name: 'DisabledAI',
        displayName: 'Disabled AI Provider',
        baseUrl: 'https://api.disabled.com/v1',
        apiKey: 'disabled_key',
        enabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(enabledProvider);
      await aiProvider.addProvider(disabledProvider);

      expect(aiProvider.providers.length, equals(2));
      expect(aiProvider.enabledProviders.length, equals(1));
      expect(aiProvider.enabledProviders.first.id, equals(enabledProvider.id));
    });

    test('should create OpenAI provider with correct configuration', () {
      final openAIProvider = aiProvider.createOpenAIProvider(
        apiKey: 'test_openai_key',
        baseUrl: 'https://api.openai.com/v1',
      );

      expect(openAIProvider.name, equals('openai'));
      expect(openAIProvider.displayName, equals('OpenAI'));
      expect(openAIProvider.apiKey, equals('test_openai_key'));
      expect(openAIProvider.baseUrl, equals('https://api.openai.com/v1'));
      expect(openAIProvider.enabled, isTrue);
      expect(openAIProvider.supportedModels.length, greaterThan(0));
      expect(openAIProvider.supportedModels.any((m) => m.modelId == 'gpt-3.5-turbo'), isTrue);
    });

    test('should create DeepSeek provider with correct configuration', () {
      final deepSeekProvider = aiProvider.createDeepSeekProvider(
        apiKey: 'test_deepseek_key',
        baseUrl: 'https://api.deepseek.com/v1',
      );

      expect(deepSeekProvider.name, equals('deepseek'));
      expect(deepSeekProvider.displayName, equals('DeepSeek'));
      expect(deepSeekProvider.apiKey, equals('test_deepseek_key'));
      expect(deepSeekProvider.baseUrl, equals('https://api.deepseek.com/v1'));
      expect(deepSeekProvider.enabled, isTrue);
      expect(deepSeekProvider.supportedModels.length, greaterThan(0));
      expect(deepSeekProvider.supportedModels.any((m) => m.modelId == 'deepseek-chat'), isTrue);
    });

    test('should handle provider lookup correctly', () async {
      await aiProvider.initialize();
      
      final testProvider = AIProviderModel(
        id: 'lookup_test_provider',
        name: 'LookupTestAI',
        displayName: 'Lookup Test AI Provider',
        baseUrl: 'https://api.lookup.com/v1',
        apiKey: 'lookup_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      // 测试存在的provider
      final found = aiProvider.getProvider(testProvider.id);
      expect(found, isNotNull);
      expect(found!.id, equals(testProvider.id));

      // 测试不存在的provider
      final notFound = aiProvider.getProvider('non_existent_provider');
      expect(notFound, isNull);
    });

    test('should handle errors gracefully', () async {
      // 测试在未初始化状态下执行操作
      expect(aiProvider.isInitialized, isFalse);
      
      // 这些操作应该不会抛出异常，但可能设置错误状态
      final invalidProvider = AIProviderModel(
        id: 'invalid_provider',
        name: 'InvalidAI',
        displayName: 'Invalid AI Provider',
        baseUrl: '', // 无效的URL
        apiKey: '',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 先初始化
      await aiProvider.initialize();
      
      // 然后尝试添加无效provider
      await aiProvider.addProvider(invalidProvider);
      
      // 应该能够处理错误而不崩溃
      expect(aiProvider.isInitialized, isTrue);
    });

    test('should manage loading state correctly', () async {
      expect(aiProvider.isLoading, isFalse);
      
      // 初始化时应该设置加载状态
      final initFuture = aiProvider.initialize();
      // 注意：由于异步操作，这里可能无法捕获到loading状态
      await initFuture;
      
      expect(aiProvider.isLoading, isFalse); // 完成后应该为false
    });

    test('should notify listeners on state changes', () async {
      bool notified = false;
      aiProvider.addListener(() {
        notified = true;
      });

      await aiProvider.initialize();
      expect(notified, isTrue);

      notified = false;
      final testProvider = AIProviderModel(
        id: 'notification_test_provider',
        name: 'NotificationTestAI',
        displayName: 'Notification Test AI Provider',
        baseUrl: 'https://api.notification.com/v1',
        apiKey: 'notification_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);
      expect(notified, isTrue);
    });
  });
}