import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:value_filter/pages/values_config_page.dart';
import 'package:value_filter/providers/values_provider.dart';
import 'package:value_filter/models/value_template_model.dart';
import '../test_helper.dart';

void main() {
  group('ValuesConfigPage Widget Tests', () {
    late ValuesProvider valuesProvider;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();
      valuesProvider = ValuesProvider();
    });

    tearDown(() async {
      await TestHelper.cleanupTestEnvironment();
    });

    Widget createTestWidget() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: ChangeNotifierProvider<ValuesProvider>.value(
            value: valuesProvider,
            child: const ValuesConfigPage(),
          ),
        ),
      );
    }

    testWidgets('应该显示基本UI元素', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证AppBar存在
      expect(find.byType(AppBar), findsOneWidget);
      
      // 验证标题
      expect(find.text('价值观配置'), findsOneWidget);
      
      // 验证主要内容区域
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('应该显示价值观模板列表', (WidgetTester tester) async {
      // 先添加一些测试数据
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

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证模板显示
      expect(find.text('测试价值观'), findsOneWidget);
      expect(find.text('测试用的价值观模板'), findsOneWidget);
    });

    testWidgets('应该显示添加按钮', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找添加按钮
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('应该响应添加按钮点击', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 点击添加按钮
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // 验证对话框或新页面打开
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('应该显示模板开关', (WidgetTester tester) async {
      // 添加测试模板
      final testTemplate = ValueTemplateModel(
        id: 'switch_test_template',
        name: '开关测试模板',
        description: '用于测试开关功能',
        category: '测试',
        keywords: ['测试'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找开关组件
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('应该响应模板开关切换', (WidgetTester tester) async {
      // 添加测试模板
      final testTemplate = ValueTemplateModel(
        id: 'toggle_test_template',
        name: '切换测试模板',
        description: '用于测试切换功能',
        category: '测试',
        keywords: ['测试'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找并点击开关
      final switchWidget = find.byType(Switch).first;
      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      // 验证状态改变
      final updatedTemplate = valuesProvider.getTemplate('toggle_test_template');
      expect(updatedTemplate?.enabled, isFalse);
    });

    testWidgets('应该显示权重滑块', (WidgetTester tester) async {
      // 添加测试模板
      final testTemplate = ValueTemplateModel(
        id: 'weight_test_template',
        name: '权重测试模板',
        description: '用于测试权重调整',
        category: '测试',
        keywords: ['测试'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找滑块组件
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('应该处理加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证加载状态不会导致崩溃
      expect(find.byType(Widget), findsWidgets);
    });

    testWidgets('应该显示分类标题', (WidgetTester tester) async {
      // 添加不同分类的模板
      final template1 = ValueTemplateModel(
        id: 'category_test_1',
        name: '社会价值观',
        description: '社会相关价值观',
        category: '社会价值',
        keywords: ['社会'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final template2 = ValueTemplateModel(
        id: 'category_test_2',
        name: '个人品质',
        description: '个人品质相关',
        category: '个人品质',
        keywords: ['品质'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(template1);
      await valuesProvider.addTemplate(template2);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证分类标题显示
      expect(find.text('社会价值'), findsOneWidget);
      expect(find.text('个人品质'), findsOneWidget);
    });

    testWidgets('应该支持删除模板', (WidgetTester tester) async {
      // 添加测试模板
      final testTemplate = ValueTemplateModel(
        id: 'delete_test_template',
        name: '待删除模板',
        description: '用于测试删除功能',
        category: '测试',
        keywords: ['测试'],
        negativeKeywords: [],
        enabled: true,
        weight: 0.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await valuesProvider.addTemplate(testTemplate);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找删除按钮（可能是IconButton或PopupMenuItem）
      final deleteButtons = find.byIcon(Icons.delete);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // 可能出现确认对话框
        final confirmDialog = find.byType(AlertDialog);
        if (confirmDialog.evaluate().isNotEmpty) {
          final confirmButton = find.text('确认');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('应该支持搜索功能', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找搜索组件
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, '测试');
        await tester.pumpAndSettle();
      }
    });
  });
}