import 'package:flutter/material.dart';

class AppConstants {
  // 应用信息
  static const String appName = '价值观内容过滤器';
  static const String appVersion = '1.0.0';
  
  // 主色调 - 符合中国用户审美的蓝色系
  static const Color primaryColor = Color(0xFF1890FF);
  static const Color secondaryColor = Color(0xFF722ED1);
  static const Color accentColor = Color(0xFF13C2C2);
  
  // 功能色彩
  static const Color successColor = Color(0xFF52C41A);
  static const Color warningColor = Color(0xFFFAAD14);
  static const Color errorColor = Color(0xFFF5222D);
  static const Color infoColor = Color(0xFF1890FF);
  
  // 中性色
  static const Color textPrimaryColor = Color(0xFF262626);
  static const Color textSecondaryColor = Color(0xFF595959);
  static const Color textTertiaryColor = Color(0xFF8C8C8C);
  static const Color textQuaternaryColor = Color(0xFFBFBFBF);
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFF0F0F0);
  
  // 尺寸常量
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // 存储键
  static const String keyUserConfig = 'user_config';
  static const String keyAIProviders = 'ai_providers';
  static const String keyValueTemplates = 'value_templates';
  static const String keyPromptTemplates = 'prompt_templates';
  static const String keyBehaviorLogs = 'behavior_logs';
  static const String keyContentCache = 'content_cache';
  
  // AI接口配置
  static const Map<String, String> supportedAIProviders = {
    'openai': 'OpenAI',
    'deepseek': 'DeepSeek',
    'siliconflow': 'SiliconFlow',
    'anthropic': 'Anthropic',
    'google': 'Google Gemini',
    'alibaba': '通义千问',
    'baidu': '文心一言',
    'custom': '自定义接口',
  };
  
  // 默认AI模型配置
  static const Map<String, List<String>> defaultModels = {
    'openai': ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'],
    'deepseek': ['deepseek-chat', 'deepseek-coder'],
    'siliconflow': ['deepseek-ai/DeepSeek-V2.5', 'Qwen/Qwen2.5-7B-Instruct', 'meta-llama/Meta-Llama-3.1-8B-Instruct'],
    'anthropic': ['claude-3-haiku', 'claude-3-sonnet', 'claude-3-opus'],
    'google': ['gemini-pro', 'gemini-pro-vision'],
    'alibaba': ['qwen-turbo', 'qwen-plus', 'qwen-max'],
    'baidu': ['ernie-bot', 'ernie-bot-turbo', 'ernie-bot-4'],
  };
  
  // 价值观模板类别
  static const List<String> valueCategories = [
    '政治立场',
    '社会价值',
    '经济观念',
    '文化认同',
    '环保意识',
    '生活方式',
    '道德观念',
    '教育理念',
    '自定义类别',
  ];
  
  // 内容类型
  static const List<String> contentTypes = [
    '文章标题',
    '文章内容',
    '用户评论',
    '作者信息',
    '推荐理由',
  ];
  
  // 过滤动作
  static const List<String> filterActions = [
    '正常显示',
    '模糊显示',
    '标记提醒',
    '完全屏蔽',
    '询问用户',
  ];
}

// 应用路由路径
class AppRoutes {
  static const String home = '/';
  static const String values = '/values';
  static const String aiConfig = '/ai-config';
  static const String ocrConfig = '/ocr-config';
  static const String prompts = '/prompts';
  static const String settings = '/settings';
  static const String filterHistory = '/filter-history';
  static const String about = '/about';
  static const String feedback = '/feedback';
  static const String test = '/test';
  static const String filterSimulation = '/filter-simulation';
}

// 权限类型
enum PermissionType {
  accessibility,
  overlay,
  notification,
  storage,
  camera,
}

// AI服务商类型
enum AIProviderType {
  openai,
  deepseek,
  anthropic,
  google,
  alibaba,
  baidu,
  custom,
}

// 价值观匹配度
enum ValueMatchLevel {
  high,      // 高度匹配
  medium,    // 中等匹配
  low,       // 低匹配
  conflict,  // 价值观冲突
}

// 内容过滤级别
enum FilterLevel {
  strict,    // 严格模式
  balanced,  // 平衡模式
  relaxed,   // 宽松模式
  custom,    // 自定义模式
}

/// UI颜色常量类
class AppColors {
  static const Color primary = Color(0xFF1890FF);
  static const Color secondary = Color(0xFF722ED1);
  static const Color accent = Color(0xFF13C2C2);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFF5222D);
  static const Color info = Color(0xFF1890FF);
}

/// UI尺寸常量类
class AppSizes {
  static const double padding = 16.0;
  static const double spacing = 8.0;
  static const double borderRadius = 8.0;
}