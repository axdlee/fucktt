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
import 'constants/app_constants.dart';
import 'utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive本地存储
  await Hive.initFlutter();
  await StorageService.init();
  
  // 初始化性能服务
  await PerformanceService().initialize();
  
  // 设置系统状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ValueFilterApp());
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
      cardTheme: CardTheme(
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