import 'dart:typed_data';
import '../base/service_base.dart';

/// OCR服务核心接口
abstract class OcrService extends ServiceBase {
  /// 初始化OCR服务
  @override
  Future<void> initialize();

  /// 识别图片中的文本
  Future<OcrResult> extractText(Uint8List imageData);

  /// 批量识别
  Future<List<OcrResult>> extractTexts(List<Uint8List> images);

  /// 清理文本
  String cleanText(String text);
}

/// OCR结果
class OcrResult {
  final String fullText;
  final List<TextBlock> blocks;
  final double confidence;
  final String language;

  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.confidence,
    required this.language,
  });

  bool get isEmpty => fullText.trim().isEmpty;
  int get blockCount => blocks.length;
}

/// 文本块
class TextBlock {
  final String text;
  final double confidence;
  final BoundingBox bbox;

  const TextBlock({
    required this.text,
    required this.confidence,
    required this.bbox,
  });
}

/// 边界框
class BoundingBox {
  final double left, top, width, height;
  const BoundingBox(this.left, this.top, this.width, this.height);
}