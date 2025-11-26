import 'package:flutter/services.dart';
import 'dart:developer';
import '../models/behavior_model.dart';

/// 内容获取服务 - 负责从今日头条应用中获取内容
class ContentCaptureService {
  static const MethodChannel _channel = MethodChannel('value_filter/content_capture');
  
  static ContentCaptureService? _instance;
  static ContentCaptureService get instance => _instance ??= ContentCaptureService._();
  
  ContentCaptureService._();
  
  bool _isCapturing = false;
  Function(CapturedContent)? _onContentCaptured;
  
  /// 开始内容捕获
  Future<bool> startCapture() async {
    try {
      final result = await _channel.invokeMethod('startCapture');
      _isCapturing = result as bool? ?? false;
      
      if (_isCapturing) {
        _channel.setMethodCallHandler(_handleMethodCall);
      }
      
      return _isCapturing;
    } catch (e) {
      log('启动内容捕获失败: $e');
      return false;
    }
  }
  
  /// 停止内容捕获
  Future<void> stopCapture() async {
    try {
      await _channel.invokeMethod('stopCapture');
      _isCapturing = false;
      _channel.setMethodCallHandler(null);
    } catch (e) {
      log('停止内容捕获失败: $e');
    }
  }
  
  /// 检查权限
  Future<bool> checkPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkPermissions');
      return result as bool? ?? false;
    } catch (e) {
      log('检查权限失败: $e');
      return false;
    }
  }
  
  /// 请求权限
  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestPermissions');
      return result as bool? ?? false;
    } catch (e) {
      log('请求权限失败: $e');
      return false;
    }
  }
  
  /// 捕获当前屏幕
  Future<Uint8List?> captureScreen() async {
    try {
      final result = await _channel.invokeMethod('captureScreen');
      return result as Uint8List?;
    } catch (e) {
      log('屏幕捕获失败: $e');
      return null;
    }
  }
  
  /// 从图片中提取文本
  Future<String?> extractTextFromImage(Uint8List imageData) async {
    try {
      final result = await _channel.invokeMethod('extractText', {
        'imageData': imageData,
      });
      return result as String?;
    } catch (e) {
      log('文本提取失败: $e');
      return null;
    }
  }
  
  /// 分析屏幕内容
  Future<List<CapturedContent>> analyzeScreen() async {
    try {
      // 捕获屏幕
      final screenshot = await captureScreen();
      if (screenshot == null) {
        return [];
      }
      
      // 提取文本
      final text = await extractTextFromImage(screenshot);
      if (text == null || text.trim().isEmpty) {
        return [];
      }
      
      // 解析内容结构
      return _parseContent(text, screenshot);
    } catch (e) {
      log('屏幕分析失败: $e');
      return [];
    }
  }
  
  /// 设置内容捕获回调
  void setContentCaptureCallback(Function(CapturedContent) callback) {
    _onContentCaptured = callback;
  }
  
  /// 处理原生方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onContentCaptured':
        final args = call.arguments as Map<dynamic, dynamic>;
        final content = CapturedContent.fromMap(Map<String, dynamic>.from(args));
        _onContentCaptured?.call(content);
        break;
      case 'onScreenChanged':
        // 屏幕内容发生变化，可以触发新的分析
        final contents = await analyzeScreen();
        for (final content in contents) {
          _onContentCaptured?.call(content);
        }
        break;
      default:
        log('未知的方法调用: ${call.method}');
    }
  }
  
  /// 解析捕获的内容
  List<CapturedContent> _parseContent(String text, Uint8List screenshot) {
    final contents = <CapturedContent>[];
    
    // 简化的内容解析逻辑
    // 实际应用中需要更复杂的文本分析和UI元素识别
    
    // 按行分割文本
    final lines = text.split('\n');
    var currentContent = StringBuffer();
    ContentType? currentType;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // 简单的内容类型识别
      final detectedType = _detectContentType(trimmedLine);
      
      if (detectedType != currentType && currentContent.isNotEmpty) {
        // 保存当前内容块
        contents.add(CapturedContent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: currentType ?? ContentType.article,
          text: currentContent.toString().trim(),
          screenshot: screenshot,
          timestamp: DateTime.now(),
          source: 'toutiao',
        ));
        
        currentContent.clear();
      }
      
      currentType = detectedType;
      currentContent.writeln(trimmedLine);
    }
    
    // 保存最后一个内容块
    if (currentContent.isNotEmpty) {
      contents.add(CapturedContent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: currentType ?? ContentType.article,
        text: currentContent.toString().trim(),
        screenshot: screenshot,
        timestamp: DateTime.now(),
        source: 'toutiao',
      ));
    }
    
    return contents;
  }
  
  /// 检测内容类型
  ContentType _detectContentType(String text) {
    // 简化的内容类型检测逻辑
    if (text.length < 20) {
      return ContentType.article; // 可能是标题
    } else if (text.contains('评论') || text.contains('回复')) {
      return ContentType.comment;
    } else if (text.contains('作者') || text.contains('发布')) {
      return ContentType.author;
    } else {
      return ContentType.article;
    }
  }
  
  /// 获取捕获状态
  bool get isCapturing => _isCapturing;
}

/// 捕获的内容
class CapturedContent {
  final String id;
  final ContentType type;
  final String text;
  final Uint8List screenshot;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> metadata;
  
  CapturedContent({
    required this.id,
    required this.type,
    required this.text,
    required this.screenshot,
    required this.timestamp,
    required this.source,
    this.metadata = const {},
  });
  
  factory CapturedContent.fromMap(Map<String, dynamic> map) {
    return CapturedContent(
      id: map['id'] as String,
      type: ContentType.values[map['type'] as int],
      text: map['text'] as String,
      screenshot: map['screenshot'] as Uint8List,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      source: map['source'] as String,
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'text': text,
      'screenshot': screenshot,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source,
      'metadata': metadata,
    };
  }
}