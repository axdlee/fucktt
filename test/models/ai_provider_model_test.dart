import 'package:flutter_test/flutter_test.dart';
import 'package:fucktt/models/ai_provider_model.dart';

void main() {
  group('AIProviderModel Tests', () {
    late AIProviderModel testProvider;
    
    setUp(() {
      testProvider = AIProviderModel(
        id: 'test_provider',
        name: 'TestAI',
        displayName: 'Test AI Provider',
        baseUrl: 'https://api.test.com/v1',
        apiKey: 'test_api_key',
        headers: {'Authorization': 'Bearer test'},
        supportedModels: [
          ModelConfig(
            modelId: 'test-model',
            displayName: 'Test Model',
            maxTokens: 4096,
            temperature: 0.7,
          ),
        ],
        enabled: true,
        description: 'Test AI provider for testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: 1,
        customConfig: {'test': 'value'},
      );
    });

    test('should create AIProviderModel with correct properties', () {
      expect(testProvider.id, equals('test_provider'));
      expect(testProvider.name, equals('TestAI'));
      expect(testProvider.displayName, equals('Test AI Provider'));
      expect(testProvider.baseUrl, equals('https://api.test.com/v1'));
      expect(testProvider.apiKey, equals('test_api_key'));
      expect(testProvider.enabled, isTrue);
      expect(testProvider.priority, equals(1));
      expect(testProvider.supportedModels.length, equals(1));
    });

    test('should convert to JSON correctly', () {
      final json = testProvider.toJson();
      
      expect(json['id'], equals('test_provider'));
      expect(json['name'], equals('TestAI'));
      expect(json['displayName'], equals('Test AI Provider'));
      expect(json['baseUrl'], equals('https://api.test.com/v1'));
      expect(json['enabled'], isTrue);
      expect(json['priority'], equals(1));
      expect(json['supportedModels'], isA<List>());
    });

    test('should create from JSON correctly', () {
      final json = testProvider.toJson();
      final fromJson = AIProviderModel.fromJson(json);
      
      expect(fromJson.id, equals(testProvider.id));
      expect(fromJson.name, equals(testProvider.name));
      expect(fromJson.displayName, equals(testProvider.displayName));
      expect(fromJson.baseUrl, equals(testProvider.baseUrl));
      expect(fromJson.enabled, equals(testProvider.enabled));
      expect(fromJson.priority, equals(testProvider.priority));
    });

    test('should create copy with modified properties', () {
      final copy = testProvider.copyWith(
        name: 'ModifiedAI',
        enabled: false,
        priority: 5,
      );
      
      expect(copy.id, equals(testProvider.id)); // 未修改的属性保持不变
      expect(copy.name, equals('ModifiedAI')); // 修改的属性
      expect(copy.enabled, isFalse); // 修改的属性
      expect(copy.priority, equals(5)); // 修改的属性
      expect(copy.baseUrl, equals(testProvider.baseUrl)); // 未修改的属性保持不变
    });

    test('should have correct equality comparison', () {
      final anotherProvider = AIProviderModel(
        id: 'test_provider', // 相同ID
        name: 'DifferentName',
        displayName: 'Different Display Name',
        baseUrl: 'https://different.com',
        apiKey: 'different_key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final differentProvider = AIProviderModel(
        id: 'different_provider', // 不同ID
        name: 'TestAI',
        displayName: 'Test AI Provider',
        baseUrl: 'https://api.test.com/v1',
        apiKey: 'test_api_key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(testProvider == anotherProvider, isTrue); // 相同ID应该相等
      expect(testProvider == differentProvider, isFalse); // 不同ID应该不相等
      expect(testProvider.hashCode, equals(anotherProvider.hashCode));
    });

    test('should handle empty supportedModels list', () {
      final providerWithoutModels = testProvider.copyWith(
        supportedModels: [],
      );
      
      expect(providerWithoutModels.supportedModels, isEmpty);
      expect(providerWithoutModels.toJson()['supportedModels'], isA<List>());
    });

    test('should handle null description', () {
      final providerWithoutDescription = testProvider.copyWith(
        description: null,
      );
      
      expect(providerWithoutDescription.description, isNull);
      expect(providerWithoutDescription.toJson()['description'], isNull);
    });
  });

  group('ModelConfig Tests', () {
    late ModelConfig testModel;
    
    setUp(() {
      testModel = ModelConfig(
        modelId: 'gpt-3.5-turbo',
        displayName: 'GPT-3.5 Turbo',
        maxTokens: 4096,
        temperature: 0.7,
        topP: 1.0,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        parameters: {'stream': false},
        enabled: true,
        description: 'OpenAI GPT-3.5 Turbo model',
      );
    });

    test('should create ModelConfig with correct properties', () {
      expect(testModel.modelId, equals('gpt-3.5-turbo'));
      expect(testModel.displayName, equals('GPT-3.5 Turbo'));
      expect(testModel.maxTokens, equals(4096));
      expect(testModel.temperature, equals(0.7));
      expect(testModel.enabled, isTrue);
    });

    test('should convert to JSON correctly', () {
      final json = testModel.toJson();
      
      expect(json['modelId'], equals('gpt-3.5-turbo'));
      expect(json['displayName'], equals('GPT-3.5 Turbo'));
      expect(json['maxTokens'], equals(4096));
      expect(json['temperature'], equals(0.7));
      expect(json['enabled'], isTrue);
    });

    test('should create from JSON correctly', () {
      final json = testModel.toJson();
      final fromJson = ModelConfig.fromJson(json);
      
      expect(fromJson.modelId, equals(testModel.modelId));
      expect(fromJson.displayName, equals(testModel.displayName));
      expect(fromJson.maxTokens, equals(testModel.maxTokens));
      expect(fromJson.temperature, equals(testModel.temperature));
    });

    test('should create copy with modified properties', () {
      final copy = testModel.copyWith(
        maxTokens: 8192,
        temperature: 0.5,
        enabled: false,
      );
      
      expect(copy.modelId, equals(testModel.modelId));
      expect(copy.maxTokens, equals(8192));
      expect(copy.temperature, equals(0.5));
      expect(copy.enabled, isFalse);
    });

    test('should handle default values correctly', () {
      final defaultModel = ModelConfig(
        modelId: 'test-model',
        displayName: 'Test Model',
      );
      
      expect(defaultModel.maxTokens, equals(4096));
      expect(defaultModel.temperature, equals(0.7));
      expect(defaultModel.enabled, isTrue);
      expect(defaultModel.parameters, isEmpty);
    });
  });
}