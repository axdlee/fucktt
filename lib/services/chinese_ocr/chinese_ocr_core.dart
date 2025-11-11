import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../../abstract/ocr_service.dart';

/// 中文OCR服务核心类 - 集成多家国产OCR服务
/// 支持百度、腾讯、阿里云、科大讯飞等
class ChineseOcrCore extends OcrService {
  late final Dio _dio;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _isInitialized = true;
  }

  @override
  Future<OcrResult> extractText(Uint8List imageData) async {
    // 实际实现会调用具体服务商API
    throw UnimplementedError();
  }

  @override
  Future<List<OcrResult>> extractTexts(List<Uint8List> images) async {
    // 并行处理多张图片
    return await Future.wait(images.map(extractText));
  }

  @override
  String cleanText(String text) {
    // 清理多余空白字符
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Future<void> _disposeResources() async {
    _dio.close();
  }
}
