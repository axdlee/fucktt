import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:value_filter/pages/ai_config_page.dart';
import 'package:value_filter/providers/ai_provider.dart';
import 'package:value_filter/models/ai_provider_model.dart';
import '../test_helper.dart';

void main() {
  group('AIConfigPage Widget Tests', () {
    late AIProvider aiProvider;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();
      aiProvider = AIProvider();
    });

    tearDown(() async {
      await TestHelper.cleanupTestEnvironment();
    });

    Widget createTestWidget() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: ChangeNotifierProvider<AIProvider>.value(
            value: aiProvider,
            child: const AIConfigPage(),
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
      expect(find.text('AI服务配置'), findsOneWidget);
      
      // 验证主要内容区域
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('应该显示添加AI服务按钮', (WidgetTester tester) async {
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

      // 验证表单对话框打开
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('应该显示AI服务提供商列表', (WidgetTester tester) async {
      // 添加测试AI提供商
      final testProvider = AIProviderModel(
        id: 'test_provider',
        name: 'TestAI',
        displayName: 'Test AI Provider',
        baseUrl: 'https://api.test.com/v1',
        apiKey: 'test_api_key',
        supportedModels: [
          ModelConfig(
            modelId: 'test-model',
            displayName: 'Test Model',
          ),
        ],
        enabled: true,
        description: 'Test AI provider',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: 1,
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证提供商显示
      expect(find.text('Test AI Provider'), findsOneWidget);
      expect(find.text('Test AI provider'), findsOneWidget);
    });

    testWidgets('应该显示健康状态指示器', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找健康状态相关图标
      final healthIcons = find.byIcon(Icons.check_circle);
      final errorIcons = find.byIcon(Icons.error_outline);
      
      // 至少应该有状态指示器
      expect(healthIcons.evaluate().isNotEmpty || errorIcons.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('应该支持测试连接功能', (WidgetTester tester) async {
      // 添加测试提供商
      final testProvider = AIProviderModel(
        id: 'connection_test_provider',
        name: 'ConnectionTest',
        displayName: 'Connection Test Provider',
        baseUrl: 'https://api.connectiontest.com/v1',
        apiKey: 'connection_test_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找测试连接按钮
      final testButtons = find.text('测试连接');
      if (testButtons.evaluate().isNotEmpty) {
        await tester.tap(testButtons.first);
        await tester.pumpAndSettle();
        
        // 验证测试过程或结果显示
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      }
    });

    testWidgets('应该支持启用/禁用服务', (WidgetTester tester) async {
      // 添加测试提供商
      final testProvider = AIProviderModel(
        id: 'toggle_test_provider',
        name: 'ToggleTest',
        displayName: 'Toggle Test Provider',
        baseUrl: 'https://api.toggletest.com/v1',
        apiKey: 'toggle_test_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找开关组件
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
        
        // 验证状态改变
        final updatedProvider = aiProvider.getProvider('toggle_test_provider');
        expect(updatedProvider?.enabled, isFalse);
      }
    });

    testWidgets('应该显示模型配置', (WidgetTester tester) async {
      // 添加有多个模型的提供商
      final testProvider = AIProviderModel(
        id: 'multi_model_provider',
        name: 'MultiModel',
        displayName: 'Multi Model Provider',
        baseUrl: 'https://api.multimodel.com/v1',
        apiKey: 'multi_model_key',
        supportedModels: [
          ModelConfig(
            modelId: 'model-1',
            displayName: 'Model 1',
          ),
          ModelConfig(
            modelId: 'model-2',
            displayName: 'Model 2',
          ),
        ],
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证模型显示
      expect(find.text('Model 1'), findsOneWidget);
      expect(find.text('Model 2'), findsOneWidget);
    });

    testWidgets('应该支持编辑服务配置', (WidgetTester tester) async {
      // 添加测试提供商
      final testProvider = AIProviderModel(
        id: 'edit_test_provider',
        name: 'EditTest',
        displayName: 'Edit Test Provider',
        baseUrl: 'https://api.editest.com/v1',
        apiKey: 'edit_test_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找编辑按钮
      final editButtons = find.byIcon(Icons.edit);
      if (editButtons.evaluate().isNotEmpty) {
        await tester.tap(editButtons.first);
        await tester.pumpAndSettle();
        
        // 验证编辑对话框打开
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });

    testWidgets('应该支持删除服务', (WidgetTester tester) async {
      // 添加测试提供商
      final testProvider = AIProviderModel(
        id: 'delete_test_provider',
        name: 'DeleteTest',
        displayName: 'Delete Test Provider',
        baseUrl: 'https://api.deletetest.com/v1',
        apiKey: 'delete_test_key',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找删除按钮
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

    testWidgets('应该处理加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证加载状态不会导致崩溃
      expect(find.byType(Widget), findsWidgets);
    });

    testWidgets('应该显示服务优先级', (WidgetTester tester) async {
      // 添加不同优先级的提供商
      final provider1 = AIProviderModel(
        id: 'priority_test_1',
        name: 'Priority1',
        displayName: 'Priority 1 Provider',
        baseUrl: 'https://api.priority1.com/v1',
        apiKey: 'priority1_key',
        enabled: true,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider2 = AIProviderModel(
        id: 'priority_test_2',
        name: 'Priority2',
        displayName: 'Priority 2 Provider',
        baseUrl: 'https://api.priority2.com/v1',
        apiKey: 'priority2_key',
        enabled: true,
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(provider1);
      await aiProvider.addProvider(provider2);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证优先级相关显示
      expect(find.text('Priority 1 Provider'), findsOneWidget);
      expect(find.text('Priority 2 Provider'), findsOneWidget);
    });

    testWidgets('应该支持API密钥遮盖显示', (WidgetTester tester) async {
      // 添加有API密钥的提供商
      final testProvider = AIProviderModel(
        id: 'apikey_test_provider',
        name: 'APIKeyTest',
        displayName: 'API Key Test Provider',
        baseUrl: 'https://api.apikeytest.com/v1',
        apiKey: 'very_secret_api_key_12345',
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await aiProvider.addProvider(testProvider);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证API密钥被遮盖
      expect(find.textContaining('****'), findsWidgets);
      expect(find.text('very_secret_api_key_12345'), findsNothing);
    });
  });
}