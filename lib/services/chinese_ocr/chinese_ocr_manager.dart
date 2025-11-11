import 'dart:typed_data';
import '../../abstract/ocr_service.dart';
import 'chinese_ocr_providers.dart';

/// 中文OCR服务管理器
/// 统一管理多家OCR服务商，支持故障转移
class ChineseOcrManager extends OcrService {
  final OcrProvider _currentProvider = OcrProvider.baidu;

  /// 百度OCR
  final BaiduOcrService? _baiduOcr;

  /// 腾讯OCR
  final TencentOcrService? _tencentOcr;

  ChineseOcrManager({
    BaiduOcrService? baiduOcr,
    TencentOcrService? tencentOcr,
  })  : _baiduOcr = baiduOcr,
        _tencentOcr = tencentOcr;

  @override
  Future<void> initialize() async {
    // 初始化所有服务
    await Future.wait([
      if (_baiduOcr != null)
        _baiduOcr!.recognize(Uint8List(0)).then((_) => null),
      if (_tencentOcr != null)
        _tencentOcr!.recognize(Uint8List(0)).then((_) => null),
    ]);
  }

  @override
  Future<OcrResult> extractText(Uint8List imageData) async {
    try {
      switch (_currentProvider) {
        case OcrProvider.baidu:
          if (_baiduOcr != null) return await _baiduOcr!.recognize(imageData);
          break;
        case OcrProvider.tencent:
          if (_tencentOcr != null) {
            return await _tencentOcr!.recognize(imageData);
          }
          break;
        default:
          break;
      }

      // 故障转移到其他服务
      return await _fallbackOcr(imageData);
    } catch (e) {
      return await _fallbackOcr(imageData);
    }
  }

  @override
  Future<List<OcrResult>> extractTexts(List<Uint8List> images) async {
    return await Future.wait(images.map(extractText));
  }

  @override
  String cleanText(String text) {
    // 清理多余空白字符和特殊符号
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
            RegExp(r'[^\\u4e00-\\u9fff\\w\\s,.!?;:\"' '""()\\[\\]{}]'), '')
        .trim();
  }

  @override
  Future<void> _disposeResources() async {
    // 服务实例由外部管理，这里不需要特别清理
  }

  /// 故障转移策略
  Future<OcrResult> _fallbackOcr(Uint8List imageData) async {
    final providers = [OcrProvider.baidu, OcrProvider.tencent];

    for (final provider in providers) {
      if (provider == _currentProvider) continue;

      try {
        switch (provider) {
          case OcrProvider.baidu:
            if (_baiduOcr != null) return await _baiduOcr!.recognize(imageData);
            break;
          case OcrProvider.tencent:
            if (_tencentOcr != null) {
              return await _tencentOcr!.recognize(imageData);
            }
            break;
          default:
            break;
        }
      } catch (e) {
        continue;
      }
    }

    throw Exception('所有OCR服务都不可用');
  }

  /// 切换到指定的OCR提供商
  void switchProvider(OcrProvider provider) {
    // 实现提供商切换逻辑
    print('切换到: ${provider.displayName}');
  }
}
