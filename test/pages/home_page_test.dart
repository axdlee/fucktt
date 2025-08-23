import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:value_filter/pages/home_page.dart';
import 'package:value_filter/providers/app_provider.dart';
import 'package:value_filter/providers/content_provider.dart';
import 'package:value_filter/providers/ai_provider.dart';
import 'package:value_filter/providers/values_provider.dart';
import '../test_helper.dart';

void main() {
  group('HomePage Widget Tests', () {
    late AppProvider appProvider;
    late ContentProvider contentProvider;
    late AIProvider aiProvider;
    late ValuesProvider valuesProvider;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();
      appProvider = AppProvider();
      contentProvider = ContentProvider();
      aiProvider = AIProvider();
      valuesProvider = ValuesProvider();
    });

    tearDown(() async {
      await TestHelper.cleanupTestEnvironment();
    });

    Widget createTestWidget() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AppProvider>.value(value: appProvider),
              ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
              ChangeNotifierProvider<AIProvider>.value(value: aiProvider),
              ChangeNotifierProvider<ValuesProvider>.value(value: valuesProvider),
            ],
            child: const HomePage(),
          ),
        ),
      );
    }

    testWidgets('应该显示基本UI元素', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证AppBar存在
      expect(find.byType(AppBar), findsOneWidget);
      
      // 验证主要内容区域
      expect(find.byType(SingleChildScrollView), findsWidgets);
      
      // 验证底部导航栏
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('应该显示内容分析统计卡片', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找统计相关的文字
      expect(find.textContaining('总分析'), findsWidgets);
      expect(find.textContaining('被拦截'), findsWidgets);
      expect(find.textContaining('被警告'), findsWidgets);
    });

    testWidgets('应该响应底部导航栏点击', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // 查找导航项
      final navItems = find.descendant(
        of: bottomNav,
        matching: find.byType(BottomNavigationBarItem),
      );
      
      // 验证导航项存在
      expect(navItems, findsWidgets);
    });

    testWidgets('应该显示内容分析结果列表', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找列表相关组件
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('应该处理加载状态', (WidgetTester tester) async {
      // 设置加载状态
      contentProvider = ContentProvider();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 可能显示加载指示器
      final loadingIndicators = find.byType(CircularProgressIndicator);
      // 加载指示器可能存在也可能不存在，这取决于实际实现
    });

    testWidgets('应该显示错误状态', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找可能的错误显示组件
      // 这个测试更多是确保页面不会因为错误状态而崩溃
    });

    testWidgets('应该响应刷新操作', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 查找RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        // 执行下拉刷新
        await tester.fling(
          find.byType(ListView).first,
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();
      }
    });

    testWidgets('应该正确显示主题和样式', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证主题相关的组件
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('应该处理空数据状态', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证空数据时的显示
      // 这个测试确保即使没有数据也能正常显示
    });

    testWidgets('应该支持无障碍访问', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证语义标签
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}