import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';

import 'package:value_filter/services/chinese_ocr/chinese_ocr_manager.dart';
import 'package:value_filter/services/chinese_ocr/chinese_ocr_providers.dart';
import 'package:value_filter/abstract/ocr_service.dart';
import 'chinese_ocr_manager_test.mocks.dart';

// 生成测试文件

void main() {
  group('ChineseOcrManager', () {
    late ChineseOcrManager ocrManager;
    late MockBaiduOcrService mockBaiduOcr;
    late MockTencentOcrService mockTencentOcr;

    setUp(() {
      mockBaiduOcr = MockBaiduOcrService();
      mockTencentOcr = MockTencentOcrService();
      ocrManager = ChineseOcrManager(
        baiduOcr: mockBaiduOcr,
        tencentOcr: mockTencentOcr,
      );
    });

    test('初始化服务', () async {
      // 模拟百度OCR服务初始化成功
      when(mockBaiduOcr.recognize(argThat(isNotNull)))
          .thenAnswer((_) async => _createMockOcrResult());

      await ocrManager.initialize();

      verify(mockBaiduOcr.recognize(argThat(isNotNull))).called(1);
    });

    test('识别文本 - 百度OCR', () async {
      final mockResult = _createMockOcrResult();
      when(mockBaiduOcr.recognize(argThat(isNotNull)))
          .thenAnswer((_) async => mockResult);

      final result = await ocrManager.extractText(Uint8List(0));

      expect(result.fullText, equals('测试文本'));
      expect(result.confidence, equals(0.95));
      expect(result.language, equals('zh'));
    });

    test('故障转移 - 百度失败时使用腾讯', () async {
      when(mockBaiduOcr.recognize(argThat(isNotNull)))
          .thenThrow(Exception('百度OCR失败'));

      final mockResult = _createMockOcrResult();
      when(mockTencentOcr.recognize(argThat(isNotNull)))
          .thenAnswer((_) async => mockResult);

      final result = await ocrManager.extractText(Uint8List(0));

      verify(mockBaiduOcr.recognize(argThat(isNotNull))).called(1);
      verify(mockTencentOcr.recognize(argThat(isNotNull))).called(1);
      expect(result.fullText, equals('测试文本'));
    });

    test('所有OCR服务都失败时抛出异常', () async {
      when(mockBaiduOcr.recognize(argThat(isNotNull)))
          .thenThrow(Exception('百度OCR失败'));
      when(mockTencentOcr.recognize(argThat(isNotNull)))
          .thenThrow(Exception('腾讯OCR失败'));

      expect(
        () => ocrManager.extractText(Uint8List(0)),
        throwsA(isA<Exception>()),
      );
    });

    test('批量识别文本', () async {
      final mockResult = _createMockOcrResult();
      when(mockBaiduOcr.recognize(argThat(isNotNull)))
          .thenAnswer((_) async => mockResult);

      final images = [Uint8List(0), Uint8List(1), Uint8List(2)];
      final results = await ocrManager.extractTexts(images);

      expect(results.length, equals(3));
      expect(results[0].fullText, equals('测试文本'));
    });

    test('清理文本', () {
      final dirtyText = '  测试   文本  \n\n  ';
      final cleanText = ocrManager.cleanText(dirtyText);

      expect(cleanText, equals('测试文本'));
    });

    test('切换OCR提供商', () {
      ocrManager.switchProvider(OcrProvider.tencent);

      // 验证切换逻辑（具体实现根据实际需求调整）
      // 这里只是示例，实际测试需要根据具体逻辑调整
    });
  });
}

/// 创建模拟OCR结果
OcrResult _createMockOcrResult() {
  return const OcrResult(
    fullText: '测试文本',
    blocks: [],
    confidence: 0.95,
    language: 'zh',
  );
}
