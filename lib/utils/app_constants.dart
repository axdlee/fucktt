/// 应用常量定义
/// 统一管理应用中使用的所有常量
library;

import 'package:flutter/widgets.dart';

/// 时间相关常量
class TimeConstants {
  static const int millisecond = 1;
  static const int second = 1000;
  static const int minute = 60 * second;
  static const int hour = 60 * minute;
  static const int day = 24 * hour;
}

/// 存储相关常量
class StorageConstants {
  static const String userConfigBox = 'user_config';
  static const String aiProviderBox = 'ai_provider';
  static const String valueTemplateBox = 'value_template';
  static const String promptTemplateBox = 'prompt_template';
  static const String behaviorLogBox = 'behavior_log';

  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxBackupFiles = 10;
}

/// 网络相关常量
class NetworkConstants {
  static const int connectTimeout = 15 * TimeConstants.second;
  static const int receiveTimeout = 30 * TimeConstants.second;
  static const int sendTimeout = 15 * TimeConstants.second;

  static const int maxRetries = 3;
  static const int retryDelay = 1000; // ms
}

/// OCR相关常量
class OcrConstants {
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const double minConfidence = 0.7;
  static const String defaultLanguage = 'zh';

  static const List<String> supportedLanguages = [
    'zh', // 中文
    'en', // 英文
    'ja', // 日文
    'ko', // 韩文
  ];
}

/// 动画相关常量
class AnimationConstants {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.bounceOut;
}

/// 文本相关常量
class TextConstants {
  static const int maxTitleLength = 100;
  static const int maxContentLength = 10000;
  static const int maxCommentLength = 500;

  static const String emptyText = '';
  static const String loadingText = '加载中...';
  static const String errorText = '出现错误';
  static const String noDataText = '暂无数据';
}

/// 颜色相关常量
class ColorConstants {
  static const int primaryValue = 0xFF1976D2;
  static const int accentValue = 0xFF2196F3;
  static const int backgroundValue = 0xFFFAFAFA;
  static const int surfaceValue = 0xFFFFFFFF;

  static const int successValue = 0xFF4CAF50;
  static const int warningValue = 0xFFFF9800;
  static const int errorValue = 0xFFF44336;
}

/// 间距相关常量
class SpacingConstants {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// 圆角相关常量
class BorderRadiusConstants {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double extraLarge = 16.0;
}

/// 阴影相关常量
class ElevationConstants {
  static const double none = 0.0;
  static const double small = 1.0;
  static const double medium = 4.0;
  static const double large = 8.0;
  static const double extraLarge = 16.0;
}
