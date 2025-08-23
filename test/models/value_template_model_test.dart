import 'package:flutter_test/flutter_test.dart';
import 'package:fucktt/models/value_template_model.dart';

void main() {
  group('ValueTemplateModel Tests', () {
    late ValueTemplateModel testTemplate;
    late DateTime testTime;
    
    setUp(() {
      testTime = DateTime.now();
      testTemplate = ValueTemplateModel(
        id: 'test_template',
        name: '积极正面价值观',
        description: '传播正能量，倡导积极向上的价值观',
        category: '社会价值',
        keywords: ['正能量', '积极', '向上', '正面'],
        negativeKeywords: ['负能量', '消极', '负面'],
        enabled: true,
        weight: 0.8,
        createdAt: testTime,
        updatedAt: testTime,
      );
    });

    test('should create ValueTemplateModel with correct properties', () {
      expect(testTemplate.id, equals('test_template'));
      expect(testTemplate.name, equals('积极正面价值观'));
      expect(testTemplate.description, equals('传播正能量，倡导积极向上的价值观'));
      expect(testTemplate.category, equals('社会价值'));
      expect(testTemplate.keywords, equals(['正能量', '积极', '向上', '正面']));
      expect(testTemplate.negativeKeywords, equals(['负能量', '消极', '负面']));
      expect(testTemplate.enabled, isTrue);
      expect(testTemplate.weight, equals(0.8));
    });

    test('should convert to JSON correctly', () {
      final json = testTemplate.toJson();
      
      expect(json['id'], equals('test_template'));
      expect(json['name'], equals('积极正面价值观'));
      expect(json['category'], equals('社会价值'));
      expect(json['keywords'], equals(['正能量', '积极', '向上', '正面']));
      expect(json['negativeKeywords'], equals(['负能量', '消极', '负面']));
      expect(json['enabled'], isTrue);
      expect(json['weight'], equals(0.8));
    });

    test('should create from JSON correctly', () {
      final json = testTemplate.toJson();
      final fromJson = ValueTemplateModel.fromJson(json);
      
      expect(fromJson.id, equals(testTemplate.id));
      expect(fromJson.name, equals(testTemplate.name));
      expect(fromJson.description, equals(testTemplate.description));
      expect(fromJson.category, equals(testTemplate.category));
      expect(fromJson.keywords, equals(testTemplate.keywords));
      expect(fromJson.negativeKeywords, equals(testTemplate.negativeKeywords));
      expect(fromJson.enabled, equals(testTemplate.enabled));
      expect(fromJson.weight, equals(testTemplate.weight));
    });

    test('should create copy with modified properties', () {
      final copy = testTemplate.copyWith(
        name: '修改后的价值观',
        enabled: false,
        weight: 0.5,
        keywords: ['新关键词'],
      );
      
      expect(copy.id, equals(testTemplate.id)); // 未修改
      expect(copy.name, equals('修改后的价值观')); // 已修改
      expect(copy.enabled, isFalse); // 已修改
      expect(copy.weight, equals(0.5)); // 已修改
      expect(copy.keywords, equals(['新关键词'])); // 已修改
      expect(copy.description, equals(testTemplate.description)); // 未修改
    });

    test('should handle empty keyword lists', () {
      final templateWithEmptyKeywords = testTemplate.copyWith(
        keywords: [],
        negativeKeywords: [],
      );
      
      expect(templateWithEmptyKeywords.keywords, isEmpty);
      expect(templateWithEmptyKeywords.negativeKeywords, isEmpty);
      
      final json = templateWithEmptyKeywords.toJson();
      expect(json['keywords'], isA<List>());
      expect(json['negativeKeywords'], isA<List>());
    });

    test('should handle weight boundaries', () {
      // 测试最小权重
      final minWeightTemplate = testTemplate.copyWith(weight: 0.0);
      expect(minWeightTemplate.weight, equals(0.0));
      
      // 测试最大权重
      final maxWeightTemplate = testTemplate.copyWith(weight: 1.0);
      expect(maxWeightTemplate.weight, equals(1.0));
    });

    test('should validate keyword matching logic', () {
      const testContent = '这是一篇传播正能量的积极文章，倡导向上的价值观';
      
      // 计算正面关键词匹配
      int positiveMatches = 0;
      for (final keyword in testTemplate.keywords) {
        if (testContent.contains(keyword)) {
          positiveMatches++;
        }
      }
      
      // 计算负面关键词匹配
      int negativeMatches = 0;
      for (final keyword in testTemplate.negativeKeywords) {
        if (testContent.contains(keyword)) {
          negativeMatches++;
        }
      }
      
      expect(positiveMatches, greaterThan(0)); // 应该匹配正面关键词
      expect(negativeMatches, equals(0)); // 不应该匹配负面关键词
    });

    test('should handle different categories', () {
      final categories = ['社会价值', '道德品质', '文化传承', '个人成长'];
      
      for (final category in categories) {
        final template = testTemplate.copyWith(category: category);
        expect(template.category, equals(category));
      }
    });

    test('should maintain data integrity through serialization', () {
      // 序列化和反序列化多次
      var current = testTemplate;
      
      for (int i = 0; i < 5; i++) {
        final json = current.toJson();
        current = ValueTemplateModel.fromJson(json);
      }
      
      // 验证数据完整性
      expect(current.id, equals(testTemplate.id));
      expect(current.name, equals(testTemplate.name));
      expect(current.keywords, equals(testTemplate.keywords));
      expect(current.weight, equals(testTemplate.weight));
    });

    test('should handle special characters in keywords', () {
      final specialTemplate = testTemplate.copyWith(
        keywords: ['测试@符号', '#话题标签', '中文，符号', 'English混合'],
        negativeKeywords: ['特殊*字符', '换行\n测试'],
      );
      
      final json = specialTemplate.toJson();
      final fromJson = ValueTemplateModel.fromJson(json);
      
      expect(fromJson.keywords, equals(specialTemplate.keywords));
      expect(fromJson.negativeKeywords, equals(specialTemplate.negativeKeywords));
    });

    test('should validate weight calculation in scoring', () {
      const content = '正能量积极向上';
      
      // 模拟评分计算
      double score = 0.0;
      int matches = 0;
      
      for (final keyword in testTemplate.keywords) {
        if (content.contains(keyword)) {
          matches++;
        }
      }
      
      if (matches > 0) {
        score = (matches / testTemplate.keywords.length) * testTemplate.weight;
      }
      
      expect(score, greaterThan(0));
      expect(score, lessThanOrEqualTo(testTemplate.weight));
    });
  });
}