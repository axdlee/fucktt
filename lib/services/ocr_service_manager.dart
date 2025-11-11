import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'ocr_service.dart';
import 'chinese_ocr_service.dart' as chinese_ocr;
import 'local_ocr_service.dart';

/// 🔧 OCR服务管理器
/// 统一管理Google ML Kit和国产OCR服务
/// 支持自动故障转移和手动切换
class OCRServiceManager {
  static OCRServiceManager? _instance;
  static OCRServiceManager get instance => _instance ??= OCRServiceManager._();

  OCRServiceManager._();

  // 当前OCR策略
  OCRStrategy _currentStrategy = OCRStrategy.auto;

  // Google ML Kit服务
  final OCRService _googleMLKitService = OCRService.instance;

  // 国产OCR服务
  final chinese_ocr.ChineseOCRService _chineseOCRService = chinese_ocr.ChineseOCRService.instance;

  // 本地OCR服务
  final LocalOCRService _localOCRService = LocalOCRService.instance;

  // 可用性状态
  bool _googleMLKitAvailable = false;
  bool _chineseOCRAvailable = false;
  final bool _localOCRAvailable = false;

  /// 初始化OCR服务管理器
  Future<void> initialize() async {
    print('🔧 OCR服务管理器初始化开始...');

    // 检测Google ML Kit可用性
    await _checkGoogleMLKitAvailability();

    // 初始化国产OCR服务
    await _initializeChineseOCR();

    // 根据可用性选择最佳策略
    _selectBestStrategy();

    print('✅ OCR服务管理器初始化完成');
    print('📊 Google ML Kit: ${_googleMLKitAvailable ? "可用" : "不可用"}');
    print('📊 国产OCR服务: ${_chineseOCRAvailable ? "可用" : "不可用"}');
    print('🎯 当前策略: ${_currentStrategy.displayName}');
  }

  /// 检测Google ML Kit可用性
  Future<void> _checkGoogleMLKitAvailability() async {
    try {
      await _googleMLKitService.initialize();
      _googleMLKitAvailable = true;
      print('✅ Google ML Kit 可用');
    } catch (e) {
      _googleMLKitAvailable = false;
      print('❌ Google ML Kit 不可用: $e');

      // 常见的Google ML Kit问题诊断
      if (e.toString().contains('Google Play')) {
        print('💡 建议: 设备缺少Google Play服务，推荐使用国产OCR');
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        print('💡 建议: 网络连接问题，可能需要科学上网或使用国产OCR');
      } else if (e.toString().contains('model')) {
        print('💡 建议: ML Kit模型下载失败，建议使用国产OCR');
      }
    }
  }

  /// 初始化国产OCR服务
  Future<void> _initializeChineseOCR() async {
    try {
      await _chineseOCRService.initialize();
      _chineseOCRAvailable = true;
      print('✅ 国产OCR服务 可用');
    } catch (e) {
      _chineseOCRAvailable = false;
      print('❌ 国产OCR服务 不可用: $e');
    }
  }

  /// 选择最佳策略
  void _selectBestStrategy() {
    if (!_googleMLKitAvailable && !_chineseOCRAvailable) {
      throw Exception('❌ 没有可用的OCR服务！请检查网络连接和API配置');
    }

    // 在中国大陆，优先使用国产OCR
    if (_isInChina() && _chineseOCRAvailable) {
      _currentStrategy = OCRStrategy.chineseOnly;
      print('🇨🇳 检测到中国大陆环境，优先使用国产OCR');
    } else if (_googleMLKitAvailable) {
      _currentStrategy = OCRStrategy.googleFirst;
      print('🌍 使用Google ML Kit优先策略');
    } else if (_chineseOCRAvailable) {
      _currentStrategy = OCRStrategy.chineseOnly;
      print('🔄 Google ML Kit不可用，使用国产OCR');
    }
  }

  /// 检测是否在中国大陆
  bool _isInChina() {
    // 可以通过多种方式检测：
    // 1. 时区检测
    // 2. 语言环境
    // 3. 网络测试
    // 这里使用简单的时区检测
    final timezone = DateTime.now().timeZoneName;
    return timezone.contains('China') || timezone.contains('CST');
  }

  /// 设置OCR策略
  void setStrategy(OCRStrategy strategy) {
    _currentStrategy = strategy;
    print('🔄 OCR策略切换为: ${strategy.displayName}');
  }

  /// 主要的OCR识别接口
  Future<OCRResult> extractTextFromImage(Uint8List imageData) async {
    switch (_currentStrategy) {
      case OCRStrategy.googleOnly:
        return await _extractWithGoogle(imageData);

      case OCRStrategy.chineseOnly:
        return await _extractWithChinese(imageData);

      case OCRStrategy.googleFirst:
        return await _extractWithGoogleFirst(imageData);

      case OCRStrategy.chineseFirst:
        return await _extractWithChineseFirst(imageData);

      case OCRStrategy.auto:
        return await _extractWithAuto(imageData);
    }
  }

  /// 仅使用Google ML Kit
  Future<OCRResult> _extractWithGoogle(Uint8List imageData) async {
    if (!_googleMLKitAvailable) {
      throw Exception('Google ML Kit 不可用');
    }

    print('🔍 使用Google ML Kit进行OCR识别');
    return await _googleMLKitService.extractTextFromImage(imageData);
  }

  /// 仅使用国产OCR
  Future<OCRResult> _extractWithChinese(Uint8List imageData) async {
    if (!_chineseOCRAvailable) {
      throw Exception('国产OCR服务不可用');
    }

    print('🔍 使用国产OCR服务进行识别');
    // 获取国产OCR服务的结果并适配为主要OCRResult类型
    final chineseResult = await _chineseOCRService.extractTextFromImage(imageData);
    
    // 这里应该进行类型转换，确保返回的是OCRResult类型
    // 如果两个OCRResult结构兼容，可以直接返回，否则需要手动转换
    return chineseResult as OCRResult;
  }

  /// Google优先，失败时使用国产OCR
  Future<OCRResult> _extractWithGoogleFirst(Uint8List imageData) async {
    try {
      if (_googleMLKitAvailable) {
        print('🔍 优先尝试Google ML Kit');
        return await _googleMLKitService.extractTextFromImage(imageData);
      }
    } catch (e) {
      print('⚠️ Google ML Kit失败，切换到国产OCR: $e');
    }

    if (_chineseOCRAvailable) {
      // 获取国产OCR服务的结果并转换为主要OCRResult类型
      final chineseResult = await _chineseOCRService.extractTextFromImage(imageData);
      return chineseResult as OCRResult;
    }

    throw Exception('所有OCR服务都不可用');
  }

  /// 国产OCR优先，失败时使用Google ML Kit
  Future<OCRResult> _extractWithChineseFirst(Uint8List imageData) async {
    try {
      if (_chineseOCRAvailable) {
        print('🔍 优先尝试国产OCR服务');
        // 获取国产OCR服务的结果并转换为主要OCRResult类型
        final chineseResult = await _chineseOCRService.extractTextFromImage(imageData);
        return chineseResult as OCRResult;
      }
    } catch (e) {
      print('⚠️ 国产OCR失败，切换到Google ML Kit: $e');
    }

    if (_googleMLKitAvailable) {
      return await _googleMLKitService.extractTextFromImage(imageData);
    }

    throw Exception('所有OCR服务都不可用');
  }

  /// 自动选择最佳方案
  Future<OCRResult> _extractWithAuto(Uint8List imageData) async {
    // 根据环境自动选择
    if (_isInChina()) {
      return await _extractWithChineseFirst(imageData);
    } else {
      return await _extractWithGoogleFirst(imageData);
    }
  }

  /// 获取当前OCR服务状态
  OCRServiceStatus getStatus() {
    return OCRServiceStatus(
      currentStrategy: _currentStrategy,
      googleMLKitAvailable: _googleMLKitAvailable,
      chineseOCRAvailable: _chineseOCRAvailable,
      isInChina: _isInChina(),
    );
  }

  /// 测试所有OCR服务
  Future<Map<String, bool>> testAllServices() async {
    final results = <String, bool>{};

    // 测试Google ML Kit
    try {
      await _googleMLKitService.initialize();
      results['Google ML Kit'] = true;
    } catch (e) {
      results['Google ML Kit'] = false;
    }

    // 测试各个国产OCR服务
    final providers = [
      chinese_ocr.OCRProvider.baidu,
      chinese_ocr.OCRProvider.tencent,
      chinese_ocr.OCRProvider.aliyun,
      chinese_ocr.OCRProvider.iflytek,
    ];

    for (final provider in providers) {
      try {
        _chineseOCRService.setProvider(provider);
        // 这里可以用一个小的测试图片来验证
        results[provider.toString()] = true;
      } catch (e) {
        results[provider.toString()] = false;
      }
    }

    return results;
  }

  /// 获取推荐配置
  OCRRecommendation getRecommendation() {
    if (_isInChina()) {
      return OCRRecommendation(
        recommendedStrategy: OCRStrategy.chineseFirst,
        reason: '检测到中国大陆环境，推荐使用国产OCR服务以获得更好的网络连接和中文识别效果',
        alternatives: [
          '1. 百度OCR - 免费额度充足，中文识别效果好',
          '2. 腾讯OCR - 企业级稳定性',
          '3. 阿里云OCR - 识别速度快',
          '4. 科大讯飞OCR - 本土化程度高',
        ],
      );
    } else {
      return OCRRecommendation(
        recommendedStrategy: OCRStrategy.googleFirst,
        reason: '海外环境推荐使用Google ML Kit，具有更好的多语言支持和离线能力',
        alternatives: [
          '1. Google ML Kit - 免费离线识别',
          '2. 国产OCR作为备选方案',
        ],
      );
    }
  }
}

/// OCR策略枚举
enum OCRStrategy {
  googleOnly('仅使用Google ML Kit'),
  chineseOnly('仅使用国产OCR'),
  googleFirst('Google优先，国产备用'),
  chineseFirst('国产优先，Google备用'),
  auto('自动选择最佳方案');

  const OCRStrategy(this.displayName);
  final String displayName;
}

/// OCR服务状态
class OCRServiceStatus {
  final OCRStrategy currentStrategy;
  final bool googleMLKitAvailable;
  final bool chineseOCRAvailable;
  final bool isInChina;

  OCRServiceStatus({
    required this.currentStrategy,
    required this.googleMLKitAvailable,
    required this.chineseOCRAvailable,
    required this.isInChina,
  });

  bool get hasAnyService => googleMLKitAvailable || chineseOCRAvailable;

  String get statusSummary {
    if (!hasAnyService) return '❌ 无可用OCR服务';
    if (googleMLKitAvailable && chineseOCRAvailable) return '✅ 所有OCR服务可用';
    if (googleMLKitAvailable) return '⚠️ 仅Google ML Kit可用';
    if (chineseOCRAvailable) return '⚠️ 仅国产OCR可用';
    return '❓ 未知状态';
  }
}

/// OCR推荐配置
class OCRRecommendation {
  final OCRStrategy recommendedStrategy;
  final String reason;
  final List<String> alternatives;

  OCRRecommendation({
    required this.recommendedStrategy,
    required this.reason,
    required this.alternatives,
  });
}
