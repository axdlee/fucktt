import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/values_config_page.dart';
import '../pages/ai_config_page.dart';
import '../pages/test_page.dart';
import '../pages/filter_simulation_page.dart';
import '../pages/prompt_management_page.dart';
import '../pages/filter_history_page.dart';
import '../pages/settings_page.dart';
import '../pages/about_page.dart';
import '../pages/ocr_config_page.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // 主页
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // 价值观配置页面
      GoRoute(
        path: AppRoutes.values,
        name: 'values',
        builder: (context, state) => const ValuesConfigPage(),
      ),
      
      // AI服务配置页面
      GoRoute(
        path: AppRoutes.aiConfig,
        name: 'ai-config',
        builder: (context, state) => const AIConfigPage(),
      ),
      
      // Prompt管理页面
      GoRoute(
        path: AppRoutes.prompts,
        name: 'prompts',
        builder: (context, state) => const PromptManagementPage(),
      ),
      
      // 过滤历史页面
      GoRoute(
        path: AppRoutes.filterHistory,
        name: 'filter-history',
        builder: (context, state) => const FilterHistoryPage(),
      ),
      
      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      // 关于页面
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      
      // 功能测试页面
      GoRoute(
        path: AppRoutes.test,
        name: 'test',
        builder: (context, state) => const TestPage(),
      ),
      
      // 价值观过滤模拟测试页面
      GoRoute(
        path: AppRoutes.filterSimulation,
        name: 'filter-simulation',
        builder: (context, state) => const FilterSimulationPage(),
      ),
      
      // OCR服务配置页面
      GoRoute(
        path: AppRoutes.ocrConfig,
        name: 'ocr-config',
        builder: (context, state) => const OCRConfigPage(),
      ),
    ],
    
    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到: ${state.error.toString()}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}