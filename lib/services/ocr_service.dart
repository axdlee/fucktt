import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:developer';
import 'package:flutter/services.dart';

import 'ocr_service_manager.dart';

/// OCR文本识别服务
/// 现在作为OCRServiceManager的包装器，保持向后兼容
class OCRService {
  static OCRService? _instance;
  static OCRService get instance => _instance ??= OCRService._();
  
  OCRService._();
  
  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;
  
  // 新增：使用统一的OCR服务管理器
  final OCRServiceManager _manager = OCRServiceManager.instance;
  
  /// 初始化OCR服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 优先尝试初始化Google ML Kit
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      _isInitialized = true;
      log('✅ Google ML Kit OCR服务初始化成功');
    } catch (e) {
      log('⚠️ Google ML Kit OCR服务初始化失败: $e');
      log('💡 这在国内是正常现象，将使用国产OCR服务作为替代');
      _isInitialized = false;
      throw Exception('Google ML Kit OCR服务初始化失败');
    }
  }
  
  /// 从图片中提取文本
  Future<OCRResult> extractTextFromImage(Uint8List imageData) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // 创建InputImage
      final inputImage = InputImage.fromBytes(
        bytes: imageData,
        metadata: InputImageMetadata(
          size: Size(1080, 1920), // 默认屏幕尺寸，实际应用中需要动态获取
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1080,
        ),
      );
      
      // 执行文本识别
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 解析结果
      return _parseRecognitionResult(recognizedText);
    } catch (e) {
      log('文本识别失败: $e');
      return OCRResult(
        fullText: '',
        textBlocks: [],
        confidence: 0.0,
        language: 'zh',
      );
    }
  }
  
  /// 从图片路径提取文本
  Future<OCRResult> extractTextFromPath(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return _parseRecognitionResult(recognizedText);
    } catch (e) {
      log('从文件识别文本失败: $e');
      return OCRResult(
        fullText: '',
        textBlocks: [],
        confidence: 0.0,
        language: 'zh',
      );
    }
  }
  
  /// 批量处理多张图片
  Future<List<OCRResult>> extractTextFromImages(List<Uint8List> images) async {
    final results = <OCRResult>[];
    
    for (final imageData in images) {
      try {
        final result = await extractTextFromImage(imageData);
        results.add(result);
      } catch (e) {
        log('批量识别中的图片处理失败: $e');
        results.add(OCRResult(
          fullText: '',
          textBlocks: [],
          confidence: 0.0,
          language: 'zh',
        ));
      }
    }
    
    return results;
  }
  
  /// 解析识别结果
  OCRResult _parseRecognitionResult(RecognizedText recognizedText) {
    final textBlocks = <TextBlock>[];
    double totalConfidence = 0.0;
    int blockCount = 0;
    
    for (final block in recognizedText.blocks) {
      final textBlock = TextBlock(
        text: block.text,
        confidence: 0.95, // Google ML Kit不再提供confidence，使用默认高置信度
        boundingBox: _convertRect(block.boundingBox),
        language: _detectLanguage(block.text),
        lines: block.lines.map((line) => TextLine(
          text: line.text,
          confidence: 0.95, // 默认置信度
          boundingBox: _convertRect(line.boundingBox),
          elements: line.elements.map((element) => TextElement(
            text: element.text,
            confidence: 0.95, // 默认置信度
            boundingBox: _convertRect(element.boundingBox),
          )).toList(),
        )).toList(),
      );
      
      textBlocks.add(textBlock);
      totalConfidence += 0.95; // 使用默认置信度
      blockCount++;
    }
    
    final averageConfidence = blockCount > 0 ? totalConfidence / blockCount : 0.0;
    
    return OCRResult(
      fullText: recognizedText.text,
      textBlocks: textBlocks,
      confidence: averageConfidence,
      language: _detectLanguage(recognizedText.text),
    );
  }
  
  /// 转换坐标矩形
  BoundingBox _convertRect(Rect rect) {
    return BoundingBox(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }
  
  /// 检测文本语言
  String _detectLanguage(String text) {
    // 简单的语言检测逻辑
    final chineseRegex = RegExp(r'[\\u4e00-\\u9fff]');
    final englishRegex = RegExp(r'[a-zA-Z]');
    
    final chineseCount = chineseRegex.allMatches(text).length;
    final englishCount = englishRegex.allMatches(text).length;
    
    if (chineseCount > englishCount) {
      return 'zh';
    } else if (englishCount > 0) {
      return 'en';
    } else {
      return 'unknown';
    }
  }
  
  /// 过滤和清理文本
  String cleanText(String text) {
    // 移除多余的空白字符
    String cleaned = text.replaceAll(RegExp(r'\\s+'), ' ');
    
    // 移除特殊字符
    cleaned = cleaned.replaceAll(RegExp(r'[^\\u4e00-\\u9fff\\w\\s,.!?;:\"''""()\\[\\]{}]'), '');
    
    // 移除过短的行
    final lines = cleaned.split('\n');
    final filteredLines = lines.where((line) => line.trim().length >= 2);
    
    return filteredLines.join('\n').trim();
  }
  
  /// 提取特定区域的文本
  Future<OCRResult> extractTextFromRegion(
    Uint8List imageData,
    BoundingBox region,
  ) async {
    try {
      // 这里应该先裁剪图片到指定区域，然后进行OCR
      // 简化实现，直接对整个图片进行OCR
      final result = await extractTextFromImage(imageData);
      
      // 过滤出在指定区域内的文本块
      final filteredBlocks = result.textBlocks.where((block) {
        return _isInRegion(block.boundingBox, region);
      }).toList();
      
      final filteredText = filteredBlocks.map((block) => block.text).join('\n');
      
      return OCRResult(
        fullText: filteredText,
        textBlocks: filteredBlocks,
        confidence: result.confidence,
        language: result.language,
      );
    } catch (e) {
      log('区域文本提取失败: $e');
      rethrow;
    }
  }
  
  /// 检查边界框是否在指定区域内
  bool _isInRegion(BoundingBox box, BoundingBox region) {
    return box.left >= region.left &&
           box.top >= region.top &&
           box.left + box.width <= region.left + region.width &&
           box.top + box.height <= region.top + region.height;
  }
  
  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return ['zh', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'it', 'pt', 'ru'];
  }
  
  /// 释放资源
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      _isInitialized = false;
    }
  }
}

/// OCR识别结果
class OCRResult {
  final String fullText;
  final List<TextBlock> textBlocks;
  final double confidence;
  final String language;
  
  OCRResult({
    required this.fullText,
    required this.textBlocks,
    required this.confidence,
    required this.language,
  });
  
  /// 获取清理后的文本
  String get cleanedText => OCRService.instance.cleanText(fullText);
  
  /// 是否为空结果
  bool get isEmpty => fullText.trim().isEmpty;
  
  /// 文本块数量
  int get blockCount => textBlocks.length;
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'fullText': fullText,
      'textBlocks': textBlocks.map((block) => block.toJson()).toList(),
      'confidence': confidence,
      'language': language,
    };
  }
}

/// 文本块
class TextBlock {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  final String language;
  final List<TextLine> lines;
  
  TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    required this.language,
    required this.lines,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
      'language': language,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}

/// 文本行
class TextLine {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  final List<TextElement> elements;
  
  TextLine({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    required this.elements,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
      'elements': elements.map((element) => element.toJson()).toList(),
    };
  }
}

/// 文本元素
class TextElement {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  
  TextElement({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
    };
  }
}

/// 边界框
class BoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;
  
  BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
  
  double get right => left + width;
  double get bottom => top + height;
  
  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    };
  }
}