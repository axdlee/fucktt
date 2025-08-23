import 'package:flutter_test/flutter_test.dart';
import 'package:value_filter/providers/values_provider.dart';
import 'package:value_filter/models/value_template_model.dart';
import '../test_helper.dart';

void main() {
  group('ValuesProvider Tests', () {
    late ValuesProvider valuesProvider;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();
      valuesProvider = ValuesProvider();
    });

    tearDown(() async {
      valuesProvider.dispose();
      await TestHelper.cleanupTestEnvironment();
    });

    test('should initialize with correct default state', () {
      expect(valuesProvider.isInitialized, isFalse);
      expect(valuesProvider.isLoading, isFalse);
      expect(valuesProvider.errorMessage, isNull);
      expect(valuesProvider.templates, isEmpty);
      expect(valuesProvider.userProfile, isNull);
      expect(valuesProvider.enabledTemplates, isEmpty);
      expect(valuesProvider.customTemplates, isEmpty);
      expect(valuesProvider.presetTemplates, isEmpty);
    });

    test('should initialize successfully', () async {
      await valuesProvider.initialize();
      
      expect(valuesProvider.isInitialized, isTrue);
      expect(valuesProvider.isLoading, isFalse);
      expect(valuesProvider.userProfile, isNotNull);
    });

    test('should add value template successfully', () async {
      await valuesProvider.initialize();
      
      final testTemplate = ValueTemplateModel(
        id: 'test_template',
        name: '测试价值观',
        description: '测试用的价值观模板',
        category: '测试分类',
        keywords: ['测试', '正能量'],
        negativeKeywords: ['负面'],
        enabled: true,
        weight: 0.7,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      expect(valuesProvider.templates.length, equals(1));
      expect(valuesProvider.templates.first.id, equals(testTemplate.id));
      expect(valuesProvider.templates.first.name, equals(testTemplate.name));
    });

    test('should update value template successfully', () async {
      await valuesProvider.initialize();
      
      final originalTemplate = ValueTemplateModel(
        id: 'update_test_template',
        name: '原始价值观',
        description: '原始描述',
        category: '原始分类',
        keywords: ['原始'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(originalTemplate);

      final updatedTemplate = originalTemplate.copyWith(
        name: '更新后的价值观',
        description: '更新后的描述',
        keywords: ['更新', '测试'],
        weight: 0.8,
      );

      await valuesProvider.updateTemplate(updatedTemplate);

      final retrieved = valuesProvider.getTemplate(originalTemplate.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('更新后的价值观'));
      expect(retrieved.description, equals('更新后的描述'));
      expect(retrieved.keywords, equals(['更新', '测试']));
      expect(retrieved.weight, equals(0.8));
    });

    test('should remove value template successfully', () async {
      await valuesProvider.initialize();
      
      final testTemplate = ValueTemplateModel(
        id: 'remove_test_template',
        name: '待删除价值观',
        description: '用于测试删除功能',
        category: '测试分类',
        keywords: ['删除'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);
      expect(valuesProvider.templates.length, equals(1));

      await valuesProvider.removeTemplate(testTemplate.id);
      expect(valuesProvider.templates.isEmpty, isTrue);
      expect(valuesProvider.getTemplate(testTemplate.id), isNull);
    });

    test('should toggle template enabled state', () async {
      await valuesProvider.initialize();
      
      final testTemplate = ValueTemplateModel(
        id: 'toggle_test_template',
        name: '切换测试价值观',
        description: '用于测试切换功能',
        category: '测试分类',
        keywords: ['切换'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);
      
      // 验证初始状态
      expect(valuesProvider.getTemplate(testTemplate.id)!.enabled, isTrue);

      // 切换状态
      await valuesProvider.toggleTemplate(testTemplate.id);
      expect(valuesProvider.getTemplate(testTemplate.id)!.enabled, isFalse);

      // 再次切换
      await valuesProvider.toggleTemplate(testTemplate.id);
      expect(valuesProvider.getTemplate(testTemplate.id)!.enabled, isTrue);
    });

    test('should set template weight correctly', () async {
      await valuesProvider.initialize();
      
      final testTemplate = ValueTemplateModel(
        id: 'weight_test_template',
        name: '权重测试价值观',
        description: '用于测试权重设置',
        category: '测试分类',
        keywords: ['权重'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);
      
      // 设置新权重
      await valuesProvider.setTemplateWeight(testTemplate.id, 0.9);
      
      final updated = valuesProvider.getTemplate(testTemplate.id);
      expect(updated!.weight, equals(0.9));

      // 测试权重范围限制
      await valuesProvider.setTemplateWeight(testTemplate.id, 1.5); // 超过上限
      expect(valuesProvider.getTemplate(testTemplate.id)!.weight, equals(1.0));

      await valuesProvider.setTemplateWeight(testTemplate.id, -0.5); // 低于下限
      expect(valuesProvider.getTemplate(testTemplate.id)!.weight, equals(0.0));
    });

    test('should filter templates by enabled state', () async {
      await valuesProvider.initialize();
      
      final enabledTemplate = ValueTemplateModel(
        id: 'enabled_template',
        name: '启用的价值观',
        description: '启用状态的价值观模板',
        category: '测试分类',
        keywords: ['启用'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final disabledTemplate = ValueTemplateModel(
        id: 'disabled_template',
        name: '禁用的价值观',
        description: '禁用状态的价值观模板',
        category: '测试分类',
        keywords: ['禁用'],
        negativeKeywords: [],
        enabled: false,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(enabledTemplate);
      await valuesProvider.addTemplate(disabledTemplate);

      expect(valuesProvider.templates.length, equals(2));
      expect(valuesProvider.enabledTemplates.length, equals(1));
      expect(valuesProvider.enabledTemplates.first.id, equals(enabledTemplate.id));
    });

    test('should create custom template with correct properties', () {
      final customTemplate = valuesProvider.createCustomTemplate(
        name: '自定义价值观',
        category: '自定义分类',
        description: '自定义描述',
        keywords: ['自定义', '价值观'],
        negativeKeywords: ['负面内容'],
        weight: 0.8,
      );

      expect(customTemplate.name, equals('自定义价值观'));
      expect(customTemplate.category, equals('自定义分类'));
      expect(customTemplate.description, equals('自定义描述'));
      expect(customTemplate.keywords, equals(['自定义', '价值观']));
      expect(customTemplate.negativeKeywords, equals(['负面内容']));
      expect(customTemplate.weight, equals(0.8));
      expect(customTemplate.enabled, isTrue);
      expect(customTemplate.isCustom, isTrue);
      expect(customTemplate.id.startsWith('custom_'), isTrue);
    });

    test('should group templates by category correctly', () async {
      await valuesProvider.initialize();
      
      final template1 = ValueTemplateModel(
        id: 'template_1',
        name: '价值观1',
        description: '描述1',
        category: '社会价值',
        keywords: ['关键词1'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final template2 = ValueTemplateModel(
        id: 'template_2',
        name: '价值观2',
        description: '描述2',
        category: '个人品质',
        keywords: ['关键词2'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final template3 = ValueTemplateModel(
        id: 'template_3',
        name: '价值观3',
        description: '描述3',
        category: '社会价值',
        keywords: ['关键词3'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(template1);
      await valuesProvider.addTemplate(template2);
      await valuesProvider.addTemplate(template3);

      final groupedTemplates = valuesProvider.templatesByCategory;
      
      expect(groupedTemplates.keys.length, equals(2));
      expect(groupedTemplates['社会价值']?.length, equals(2));
      expect(groupedTemplates['个人品质']?.length, equals(1));
    });

    test('should handle template lookup correctly', () async {
      await valuesProvider.initialize();
      
      final testTemplate = ValueTemplateModel(
        id: 'lookup_test_template',
        name: '查找测试价值观',
        description: '用于测试查找功能',
        category: '测试分类',
        keywords: ['查找'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      // 测试存在的template
      final found = valuesProvider.getTemplate(testTemplate.id);
      expect(found, isNotNull);
      expect(found!.id, equals(testTemplate.id));

      // 测试不存在的template
      final notFound = valuesProvider.getTemplate('non_existent_template');
      expect(notFound, isNull);
    });

    test('should handle multiple template operations', () async {
      await valuesProvider.initialize();
      
      // 创建多个模板
      final templates = List.generate(5, (index) => ValueTemplateModel(
        id: 'bulk_template_$index',
        name: '批量模板 $index',
        description: '批量操作测试模板 $index',
        category: index % 2 == 0 ? '分类A' : '分类B',
        keywords: ['批量', '模板$index'],
        negativeKeywords: [],
        enabled: index % 3 != 0, // 部分启用，部分禁用
        weight: 0.1 * (index + 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 批量添加
      for (final template in templates) {
        await valuesProvider.addTemplate(template);
      }

      expect(valuesProvider.templates.length, equals(5));
      expect(valuesProvider.enabledTemplates.length, equals(4)); // 0,1,2,4 enabled (3 disabled)
      expect(valuesProvider.templatesByCategory.keys.length, equals(2));
    });

    test('should notify listeners on state changes', () async {
      bool notified = false;
      valuesProvider.addListener(() {
        notified = true;
      });

      await valuesProvider.initialize();
      expect(notified, isTrue);

      notified = false;
      final testTemplate = ValueTemplateModel(
        id: 'notification_test_template',
        name: '通知测试价值观',
        description: '用于测试通知功能',
        category: '测试分类',
        keywords: ['通知'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);
      expect(notified, isTrue);
    });

    test('should handle errors gracefully', () async {
      expect(valuesProvider.isInitialized, isFalse);
      
      // 先初始化
      await valuesProvider.initialize();
      
      // 尝试操作不存在的模板
      await valuesProvider.toggleTemplate('non_existent_template');
      await valuesProvider.setTemplateWeight('non_existent_template', 0.5);
      
      // 应该能够处理错误而不崩溃
      expect(valuesProvider.isInitialized, isTrue);
    });

    test('should manage loading state correctly', () async {
      expect(valuesProvider.isLoading, isFalse);
      
      // 初始化时应该设置加载状态
      final initFuture = valuesProvider.initialize();
      await initFuture;
      
      expect(valuesProvider.isLoading, isFalse); // 完成后应该为false
    });
  });
}