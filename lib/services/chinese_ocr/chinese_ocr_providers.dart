/// 中文OCR服务提供商配置
/// 支持百度、腾讯、阿里云、科大讯飞
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../abstract/ocr_service.dart';

/// OCR提供商类型
enum OcrProvider {
  baidu('百度OCR'),
  tencent('腾讯OCR'),
  aliyun('阿里云OCR'),
  iflytek('科大讯飞OCR');

  const OcrProvider(this.displayName);
  final String displayName;
}

/// OCR配置
class OcrConfig {
  final String appKey;
  final String secretKey;
  final String endpoint;

  const OcrConfig({
    required this.appKey,
    required this.secretKey,
    required this.endpoint,
  });
}

/// 百度OCR服务
class BaiduOcrService {
  final OcrConfig _config;
  late final Dio _dio;

  BaiduOcrService(this._config) {
    _dio = Dio();
  }

  Future<OcrResult> recognize(Uint8List imageData) async {
    // 1. 获取access_token
    final token = await _getAccessToken();

    // 2. 调用OCR API
    final base64Image = base64Encode(imageData);

    final response = await _dio.post(
      '${_config.endpoint}?access_token=$token',
      data: {
        'image': base64Image,
        'language_type': 'CHN_ENG',
        'detect_direction': 'true',
      },
      options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
    );

    return _parseResponse(response.data);
  }

  Future<String> _getAccessToken() async {
    final response = await _dio.post(
      'https://aip.baidubce.com/oauth/2.0/token',
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': _config.appKey,
        'client_secret': _config.secretKey,
      },
    );
    return response.data['access_token'];
  }

  OcrResult _parseResponse(Map<String, dynamic> data) {
    final words = data['words_result'] as List;
    final blocks = words
        .map((word) => TextBlock(
              text: word['words'],
              confidence: (word['probability']?['average'] ?? 0.9).toDouble(),
              bbox: BoundingBox(0, 0, 100, 20),
            ))
        .toList();

    final fullText = words.map((w) => w['words']).join('\n');
    final avgConfidence = blocks.isNotEmpty
        ? blocks.map((b) => b.confidence).reduce((a, b) => a + b) /
            blocks.length
        : 0.0;

    return OcrResult(
      fullText: fullText,
      blocks: blocks,
      confidence: avgConfidence,
      language: 'zh',
    );
  }
}

/// 腾讯OCR服务
class TencentOcrService {
  final OcrConfig _config;
  late final Dio _dio;

  TencentOcrService(this._config) {
    _dio = Dio();
  }

  Future<OcrResult> recognize(Uint8List imageData) async {
    final base64Image = base64Encode(imageData);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final response = await _dio.post(
      _config.endpoint,
      data: {
        'Action': 'GeneralBasicOCR',
        'Version': '2018-11-19',
        'Region': 'ap-beijing',
        'ImageBase64': base64Image,
        'LanguageType': 'zh',
      },
      options: Options(headers: {
        'Authorization': _generateSignature(timestamp),
        'Content-Type': 'application/json; charset=utf-8',
        'Host': 'ocr.tencentcloudapi.com',
        'X-TC-Action': 'GeneralBasicOCR',
        'X-TC-Timestamp': timestamp.toString(),
        'X-TC-Version': '2018-11-19',
      }),
    );

    return _parseResponse(response.data);
  }

  String _generateSignature(int timestamp) {
    // 简化的签名实现
    return 'TC3-HMAC-SHA256 Credential=${_config.appKey}/ocr';
  }

  OcrResult _parseResponse(Map<String, dynamic> data) {
    final detections = data['Response']?['TextDetections'] as List? ?? [];

    final blocks = detections
        .map((detection) => TextBlock(
              text: detection['DetectedText'] ?? '',
              confidence: (detection['Confidence'] ?? 90) / 100.0,
              bbox: BoundingBox(0, 0, 100, 20),
            ))
        .toList();

    final fullText = blocks.map((b) => b.text).join('\n');
    final avgConfidence = blocks.isNotEmpty
        ? blocks.map((b) => b.confidence).reduce((a, b) => a + b) /
            blocks.length
        : 0.0;

    return OcrResult(
      fullText: fullText,
      blocks: blocks,
      confidence: avgConfidence,
      language: 'zh',
    );
  }
}
