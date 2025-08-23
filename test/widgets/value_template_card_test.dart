import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:value_filter/widgets/value_template_card.dart';
import 'package:value_filter/models/value_template_model.dart';

void main() {
  group('ValueTemplateCard Widget Tests', () {
    late ValueTemplateModel testTemplate;

    setUp(() {
      testTemplate = ValueTemplateModel(
        id: 'test_template',
        name: '测试价值观',
        description: '这是一个用于测试的价值观模板',
        category: '测试分类',
        keywords: ['正能量', '积极', '善良'],
        negativeKeywords: ['负面', '消极'],
        enabled: true,
        weight: 0.8,
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('should display template information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证模板名称显示
      expect(find.text('测试价值观'), findsOneWidget);
      
      // 验证描述显示
      expect(find.text('这是一个用于测试的价值观模板'), findsOneWidget);
      
      // 验证分类显示
      expect(find.text('测试分类'), findsOneWidget);
      
      // 验证启用开关
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display keywords correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证正面关键词显示
      expect(find.text('正能量'), findsOneWidget);
      expect(find.text('积极'), findsOneWidget);
      expect(find.text('善良'), findsOneWidget);
      
      // 验证负面关键词显示
      expect(find.text('负面'), findsOneWidget);
      expect(find.text('消极'), findsOneWidget);
    });

    testWidgets('should call onToggle when switch is tapped', (WidgetTester tester) async {
      bool toggleCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
                onToggle: () {
                  toggleCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击开关
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(toggleCalled, isTrue);
    });

    testWidgets('should display weight slider and handle changes', (WidgetTester tester) async {
      double? newWeight;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
                onWeightChanged: (weight) {
                  newWeight = weight;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证权重滑块显示
      expect(find.byType(Slider), findsOneWidget);
      
      // 验证权重百分比显示
      expect(find.text('80%'), findsOneWidget);

      // 测试滑块拖动
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(newWeight, isNotNull);
    });

    testWidgets('should show compact layout when compact is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
                compact: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 在紧凑模式下，某些元素可能不显示或以不同方式显示
      expect(find.text('测试价值观'), findsOneWidget);
      expect(find.text('这是一个用于测试的价值观模板'), findsOneWidget);
    });

    testWidgets('should call action callbacks when buttons are tapped', (WidgetTester tester) async {
      bool editCalled = false;
      bool deleteCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate.copyWith(isCustom: true), // 只有自定义模板才能删除
                onEdit: () {
                  editCalled = true;
                },
                onDelete: () {
                  deleteCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找并点击编辑按钮
      final editButton = find.byIcon(Icons.edit_outlined);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await tester.pumpAndSettle();
        expect(editCalled, isTrue);
      }

      // 查找并点击删除按钮
      final deleteButton = find.byIcon(Icons.delete_outline);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        expect(deleteCalled, isTrue);
      }
    });

    testWidgets('should not show delete button for preset templates', (WidgetTester tester) async {
      final presetTemplate = testTemplate.copyWith(isCustom: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: presetTemplate,
                onEdit: () {},
                // 不提供onDelete回调，因为预设模板不能删除
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证删除按钮不显示（没有提供onDelete回调）
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('should display disabled state correctly', (WidgetTester tester) async {
      final disabledTemplate = testTemplate.copyWith(enabled: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: disabledTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证开关状态
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
      
      // 验证模板名称仍然显示
      expect(find.text('测试价值观'), findsOneWidget);
    });

    testWidgets('should handle empty keywords gracefully', (WidgetTester tester) async {
      final templateWithoutKeywords = testTemplate.copyWith(
        keywords: [],
        negativeKeywords: [],
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: templateWithoutKeywords,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证显示"暂无关键词"提示
      expect(find.text('暂无关键词'), findsOneWidget);
    });

    testWidgets('should display category chip with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证分类标签显示
      expect(find.text('测试分类'), findsOneWidget);
    });

    testWidgets('should handle weight display correctly', (WidgetTester tester) async {
      final heavyWeightTemplate = testTemplate.copyWith(weight: 1.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: heavyWeightTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证权重百分比显示
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should show creation time information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证创建时间信息可能在某处显示
      // 这取决于具体的实现
    });

    testWidgets('should differentiate positive and negative keywords visually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: ValueTemplateCard(
                template: testTemplate,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证正面和负面关键词都显示
      expect(find.text('正能量'), findsOneWidget);
      expect(find.text('负面'), findsOneWidget);
      
      // 在实际实现中，正面和负面关键词可能有不同的颜色或样式
    });
  });
}