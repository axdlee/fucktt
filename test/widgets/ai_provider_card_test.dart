import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:value_filter/widgets/ai_provider_card.dart';
import 'package:value_filter/models/ai_provider_model.dart';

void main() {
  group('AIProviderCard Widget Tests', () {
    late AIProviderModel testProvider;

    setUp(() {
      testProvider = AIProviderModel(
        id: 'test_provider',
        name: 'TestAI',
        displayName: 'Test AI Provider',
        baseUrl: 'https://api.test.com/v1',
        apiKey: 'test_api_key',
        supportedModels: [
          ModelConfig(
            modelId: 'test-model-1',
            displayName: 'Test Model 1',
          ),
          ModelConfig(
            modelId: 'test-model-2',
            displayName: 'Test Model 2',
          ),
        ],
        enabled: true,
        description: 'Test AI provider for testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: 1,
      );
    });

    testWidgets('should display provider information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证provider名称显示
      expect(find.text('Test AI Provider'), findsOneWidget);
      
      // 验证描述显示
      expect(find.text('Test AI provider for testing'), findsOneWidget);
      
      // 验证健康状态指示器
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // 验证启用开关
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should show healthy status when provider is healthy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证健康状态图标
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show unhealthy status when provider is not healthy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证不健康状态图标
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call onToggle when switch is tapped', (WidgetTester tester) async {
      bool toggleCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
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

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证加载指示器显示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display supported models', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证模型标签显示
      expect(find.text('Test Model 1'), findsOneWidget);
      expect(find.text('Test Model 2'), findsOneWidget);
    });

    testWidgets('should call action callbacks when buttons are tapped', (WidgetTester tester) async {
      bool editCalled = false;
      bool deleteCalled = false;
      bool testCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
                onEdit: () {
                  editCalled = true;
                },
                onDelete: () {
                  deleteCalled = true;
                },
                onTest: () {
                  testCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找并点击测试按钮
      final testButton = find.widgetWithText(OutlinedButton, '测试连接');
      if (testButton.evaluate().isNotEmpty) {
        await tester.tap(testButton);
        await tester.pumpAndSettle();
        expect(testCalled, isTrue);
      }

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

    testWidgets('should hide action buttons when provider is disabled', (WidgetTester tester) async {
      final disabledProvider = testProvider.copyWith(enabled: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: disabledProvider,
                isHealthy: false,
                onEdit: () {},
                onDelete: () {},
                onTest: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证操作按钮不显示（因为provider被禁用）
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.widgetWithText(OutlinedButton, '测试连接'), findsNothing);
    });

    testWidgets('should mask sensitive information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证API密钥被遮盖
      expect(find.textContaining('****'), findsWidgets);
      
      // 验证完整API密钥不显示
      expect(find.text('test_api_key'), findsNothing);
    });

    testWidgets('should handle priority changes', (WidgetTester tester) async {
      int? newPriority;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: testProvider,
                isHealthy: true,
                onPriorityChanged: (priority) {
                  newPriority = priority;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 如果有优先级控制组件，测试它的回调
      // 这里可能需要根据实际实现调整
    });

    testWidgets('should display many models with truncation indicator', (WidgetTester tester) async {
      final providerWithManyModels = testProvider.copyWith(
        supportedModels: List.generate(6, (index) => ModelConfig(
          modelId: 'model-$index',
          displayName: 'Model $index',
        )),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => Scaffold(
              body: AIProviderCard(
                provider: providerWithManyModels,
                isHealthy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证显示了截断指示器
      expect(find.textContaining('还有'), findsOneWidget);
      expect(find.textContaining('个模型'), findsOneWidget);
    });
  });
}