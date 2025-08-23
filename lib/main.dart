import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'providers/app_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/values_provider.dart';
import 'providers/content_provider.dart';
import 'services/storage_service.dart';
import 'services/performance_service.dart';
import 'services/error_handling_service.dart';
import 'services/security_service.dart';
import 'constants/app_constants.dart';
import 'utils/app_router.dart';

void main() async {
  // 确保 Flutter 框架已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 初始化错误处理服务
    await ErrorHandlingService().initialize();
    
    // 初始化安全服务
    await SecurityService().initialize();
    
    // 初始化Hive本地存储
    await Hive.initFlutter();
    await StorageService.init();
    
    // 初始化性能服务
    final performanceService = PerformanceService();
    await performanceService.initialize();
    
    // 预加载关键数据
    await performanceService.preloadData();
    
    // 设置系统状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // 运行应用
    runApp(const ValueFilterApp());
    
  } catch (error, stackTrace) {
    // 启动错误处理
    final errorService = ErrorHandlingService();
    errorService.recordError(
      AppError(
        id: 'startup_error_${DateTime.now().millisecondsSinceEpoch}',
        type: ErrorType.system,
        severity: ErrorSeverity.critical,
        message: '应用启动失败: $error',
        stackTrace: stackTrace,
        context: {'phase': 'app_startup'},
      ),
    );
    
    // 在发布版本中，可以显示一个简单的错误页面
    runApp(ErrorApp(error: error.toString()));
  }
}

class ValueFilterApp extends StatelessWidget {
  const ValueFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 Pro设计稿尺寸
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ValuesProvider()),
            ChangeNotifierProvider(create: (_) => ContentProvider()),
          ],
          child: Consumer<AppProvider>(
            builder: (context, appProvider, _) {
              return MaterialApp.router(
                title: '价值观内容过滤器',
                debugShowCheckedModeBanner: false,
                
                // 主题配置
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: appProvider.themeMode,
                
                // 国际化
                locale: const Locale('zh', 'CN'),
                supportedLocales: const [
                  Locale('zh', 'CN'),
                  Locale('en', 'US'),
                ],
                
                // 路由配置
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'PingFang',
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'PingFang',
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
      fontFamily: 'PingFang',
    );
  }
}

/// 错误应用组件 - 当应用启动失败时显示
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '价值观内容过滤器 - 错误',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade600,
                ),
                const SizedBox(height: 24),
                Text(
                  '应用启动失败',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '抱歉，应用在启动过程中遇到了问题。',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('退出应用'),
                ),
                const SizedBox(height: 16),
                if (error.isNotEmpty)
                  ExpansionTile(
                    title: const Text('错误详情'),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}