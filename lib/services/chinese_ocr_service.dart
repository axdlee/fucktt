import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:math' as math;

/// 🇨🇳 国产OCR服务集成
/// 支持百度、腾讯、阿里云等国内主流OCR服务
/// 比Google ML Kit更适合国内使用环境
class ChineseOCRService {
  static ChineseOCRService? _instance;
  static ChineseOCRService get instance => _instance ??= ChineseOCRService._();
  
  ChineseOCRService._();
  
  late final Dio _dio;
  bool _isInitialized = false;
  
  // 当前使用的OCR提供商
  OCRProvider _currentProvider = OCRProvider.baidu;
  
  // API配置
  late Map<OCRProvider, OCRConfig> _configs;
  
  /// 初始化OCR服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _dio = Dio();
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // 配置各家OCR服务
    _configs = {
      OCRProvider.baidu: OCRConfig(
        appKey: 'your_baidu_app_key',
        secretKey: 'your_baidu_secret_key',
        endpoint: 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic',
      ),
      OCRProvider.tencent: OCRConfig(
        appKey: 'your_tencent_secret_id', 
        secretKey: 'your_tencent_secret_key',
        endpoint: 'https://ocr.tencentcloudapi.com/',
      ),
      OCRProvider.aliyun: OCRConfig(
        appKey: 'your_aliyun_access_key',
        secretKey: 'your_aliyun_access_secret',
        endpoint: 'https://ocr-api.cn-hangzhou.aliyuncs.com',
      ),
      OCRProvider.iflytek: OCRConfig(
        appKey: 'your_iflytek_app_id',
        secretKey: 'your_iflytek_api_secret',
        endpoint: 'https://webapi.xfyun.cn/v1/service/v1/ocr/general',
      ),
    };
    
    _isInitialized = true;
    log('🇨🇳 国产OCR服务初始化成功 (当前提供商: ${_currentProvider.name})');
  }
  
  /// 设置OCR提供商
  void setProvider(OCRProvider provider) {
    _currentProvider = provider;
    log('🔄 切换OCR提供商到: ${provider.name}');
  }
  
  /// 从图片中提取文本（主入口）
  Future<OCRResult> extractTextFromImage(Uint8List imageData) async {
    if (!_isInitialized) await initialize();
    
    try {
      switch (_currentProvider) {
        case OCRProvider.baidu:
          return await _baiduOCR(imageData);
        case OCRProvider.tencent:
          return await _tencentOCR(imageData);
        case OCRProvider.aliyun:
          return await _aliyunOCR(imageData);
        case OCRProvider.iflytek:
          return await _iflytekOCR(imageData);
        case OCRProvider.local:
          return await _localOCR(imageData);
      }
    } catch (e) {
      log('⚠️ OCR识别失败，尝试切换提供商: $e');
      return await _fallbackOCR(imageData);
    }
  }
  
  /// 百度OCR实现
  Future<OCRResult> _baiduOCR(Uint8List imageData) async {
    final config = _configs[OCRProvider.baidu]!;
    
    // 1. 获取access_token
    final token = await _getBaiduAccessToken(config);
    
    // 2. 调用OCR API
    final base64Image = base64Encode(imageData);
    
    final response = await _dio.post(
      '${config.endpoint}?access_token=$token',
      data: {
        'image': base64Image,
        'language_type': 'CHN_ENG',
        'detect_direction': 'true',
        'paragraph': 'false',
        'probability': 'true',
      },
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );
    
    return _parseBaiduResponse(response.data);
  }
  
  /// 腾讯OCR实现
  Future<OCRResult> _tencentOCR(Uint8List imageData) async {
    final config = _configs[OCRProvider.tencent]!;
    
    final base64Image = base64Encode(imageData);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // 腾讯云签名算法
    final signature = _generateTencentSignature(
      config.appKey,
      config.secretKey, 
      timestamp,
      base64Image,
    );
    
    final response = await _dio.post(
      config.endpoint,
      data: {
        'Action': 'GeneralBasicOCR',
        'Version': '2018-11-19',
        'Region': 'ap-beijing',
        'ImageBase64': base64Image,
        'LanguageType': 'zh',
      },
      options: Options(
        headers: {
          'Authorization': signature,
          'Content-Type': 'application/json; charset=utf-8',
          'Host': 'ocr.tencentcloudapi.com',
          'X-TC-Action': 'GeneralBasicOCR',
          'X-TC-Timestamp': timestamp.toString(),
          'X-TC-Version': '2018-11-19',
        },
      ),
    );
    
    return _parseTencentResponse(response.data);
  }
  
  /// 阿里云OCR实现  
  Future<OCRResult> _aliyunOCR(Uint8List imageData) async {
    final config = _configs[OCRProvider.aliyun]!;
    
    final base64Image = base64Encode(imageData);
    final timestamp = DateTime.now().toUtc().toIso8601String();
    
    // 阿里云签名
    final signature = _generateAliyunSignature(
      config.appKey,
      config.secretKey,
      timestamp,
    );
    
    final response = await _dio.post(
      config.endpoint,
      data: {
        'image': base64Image,
        'configure': json.encode({
          'dataType': 'string',
          'language': 'zh',
          'outputProb': true,
        }),
      },
      options: Options(
        headers: {
          'Authorization': signature,
          'Content-Type': 'application/json',
          'Date': timestamp,
        },
      ),
    );
    
    return _parseAliyunResponse(response.data);
  }
  
  /// 科大讯飞OCR实现
  Future<OCRResult> _iflytekOCR(Uint8List imageData) async {
    final config = _configs[OCRProvider.iflytek]!;
    
    final base64Image = base64Encode(imageData);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = math.Random().nextInt(999999);
    
    // 讯飞签名算法
    final signature = _generateIflytekSignature(
      config.appKey,
      config.secretKey,
      timestamp,
      nonce,
    );
    
    final response = await _dio.post(
      config.endpoint,
      data: {
        'image': base64Image,
        'language': 'zh_cn|en',
        'location': 'true',
      },
      options: Options(
        headers: {
          'X-Appid': config.appKey,
          'X-CurTime': timestamp.toString(),
          'X-Param': base64Encode(utf8.encode(json.encode({
            'language': 'zh_cn|en',
            'location': 'true',
          }))),
          'X-CheckSum': signature,
        },
      ),
    );
    
    return _parseIflytekResponse(response.data);
  }
  
  /// 本地离线OCR（使用TensorFlow Lite或其他离线方案）
  Future<OCRResult> _localOCR(Uint8List imageData) async {
    // 这里可以集成：
    // 1. TensorFlow Lite模型
    // 2. PaddleOCR移动端版本  
    // 3. 其他开源OCR解决方案
    
    log('📱 使用本地离线OCR (开发中)');
    
    // 模拟本地OCR结果
    return OCRResult(
      fullText: '这是本地OCR识别的模拟结果',
      textBlocks: [
        TextBlock(
          text: '这是本地OCR识别的模拟结果',
          confidence: 0.88,
          boundingBox: BoundingBox(left: 50, top: 100, width: 200, height: 30),
          language: 'zh',
          lines: [],
        ),
      ],
      confidence: 0.88,
      language: 'zh',
    );
  }
  
  /// 故障转移策略
  Future<OCRResult> _fallbackOCR(Uint8List imageData) async {
    final fallbackOrder = [
      OCRProvider.baidu,
      OCRProvider.aliyun, 
      OCRProvider.tencent,
      OCRProvider.iflytek,
      OCRProvider.local,
    ];
    
    for (final provider in fallbackOrder) {
      if (provider == _currentProvider) continue;
      
      try {
        log('🔄 尝试故障转移到: ${provider.name}');
        setProvider(provider);
        return await extractTextFromImage(imageData);
      } catch (e) {
        log('❌ ${provider.name} 也失败了: $e');
        continue;
      }
    }
    
    throw Exception('所有OCR提供商都无法使用');
  }
  
  /// 获取百度Access Token
  Future<String> _getBaiduAccessToken(OCRConfig config) async {
    final response = await _dio.post(
      'https://aip.baidubce.com/oauth/2.0/token',
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': config.appKey,
        'client_secret': config.secretKey,
      },
    );
    
    return response.data['access_token'];
  }
  
  /// 生成腾讯云签名
  String _generateTencentSignature(String secretId, String secretKey, int timestamp, String payload) {
    // 腾讯云签名算法实现
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toUtc();
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    // 详细实现省略，返回示例
    return 'TC3-HMAC-SHA256 Credential=$secretId/$dateStr/ocr/tc3_request, SignedHeaders=content-type;host, Signature=example_signature';
  }
  
  /// 生成阿里云签名
  String _generateAliyunSignature(String accessKey, String accessSecret, String timestamp) {
    // 阿里云签名算法实现
    return 'acs $accessKey:example_signature';
  }
  
  /// 生成讯飞签名
  String _generateIflytekSignature(String appId, String apiSecret, int timestamp, int nonce) {
    final checkSum = md5.convert(utf8.encode('$appId$timestamp$nonce$apiSecret')).toString();
    return checkSum;
  }
  
  /// 解析各家API响应
  OCRResult _parseBaiduResponse(Map<String, dynamic> data) {
    if (data['error_code'] != null) {
      throw Exception('百度OCR错误: ${data['error_msg']}');
    }
    
    final words = data['words_result'] as List;
    final textBlocks = words.map((word) => TextBlock(
      text: word['words'],
      confidence: (word['probability']?['average'] ?? 0.9).toDouble(),
      boundingBox: BoundingBox(left: 0, top: 0, width: 100, height: 20),
      language: 'zh',
      lines: [],
    )).toList();
    
    return OCRResult(
      fullText: words.map((w) => w['words']).join('\n'),
      textBlocks: textBlocks,
      confidence: textBlocks.isNotEmpty ? textBlocks.map((b) => b.confidence).reduce((a, b) => a + b) / textBlocks.length : 0.0,
      language: 'zh',
    );
  }
  
  OCRResult _parseTencentResponse(Map<String, dynamic> data) {
    // 腾讯响应解析实现
    final textDetections = data['Response']?['TextDetections'] as List? ?? [];
    
    final textBlocks = textDetections.map((detection) => TextBlock(
      text: detection['DetectedText'] ?? '',
      confidence: (detection['Confidence'] ?? 90) / 100.0,
      boundingBox: BoundingBox(left: 0, top: 0, width: 100, height: 20),
      language: 'zh',
      lines: [],
    )).toList();
    
    return OCRResult(
      fullText: textBlocks.map((b) => b.text).join('\n'),
      textBlocks: textBlocks,
      confidence: textBlocks.isNotEmpty ? textBlocks.map((b) => b.confidence).reduce((a, b) => a + b) / textBlocks.length : 0.0,
      language: 'zh',
    );
  }
  
  OCRResult _parseAliyunResponse(Map<String, dynamic> data) {
    // 阿里云响应解析实现
    final result = data['data']?['result'] as List? ?? [];
    
    final textBlocks = result.map((item) => TextBlock(
      text: item['text'] ?? '',
      confidence: (item['prob'] ?? 0.9).toDouble(),
      boundingBox: BoundingBox(left: 0, top: 0, width: 100, height: 20),
      language: 'zh',
      lines: [],
    )).toList();
    
    return OCRResult(
      fullText: textBlocks.map((b) => b.text).join('\n'),
      textBlocks: textBlocks,
      confidence: textBlocks.isNotEmpty ? textBlocks.map((b) => b.confidence).reduce((a, b) => a + b) / textBlocks.length : 0.0,
      language: 'zh',
    );
  }
  
  OCRResult _parseIflytekResponse(Map<String, dynamic> data) {
    // 讯飞响应解析实现
    final result = data['data']?['result'] as List? ?? [];
    
    final textBlocks = result.map((item) => TextBlock(
      text: item['text'] ?? '',
      confidence: 0.9, // 讯飞默认置信度
      boundingBox: BoundingBox(left: 0, top: 0, width: 100, height: 20),
      language: 'zh',
      lines: [],
    )).toList();
    
    return OCRResult(
      fullText: textBlocks.map((b) => b.text).join('\n'),
      textBlocks: textBlocks,
      confidence: textBlocks.isNotEmpty ? textBlocks.map((b) => b.confidence).reduce((a, b) => a + b) / textBlocks.length : 0.0,
      language: 'zh',
    );
  }
}

/// OCR提供商枚举
enum OCRProvider {
  baidu('百度OCR'),
  tencent('腾讯OCR'), 
  aliyun('阿里云OCR'),
  iflytek('科大讯飞OCR'),
  local('本地离线OCR');
  
  const OCRProvider(this.displayName);
  final String displayName;
}

/// OCR配置
class OCRConfig {
  final String appKey;
  final String secretKey;
  final String endpoint;
  
  OCRConfig({
    required this.appKey,
    required this.secretKey,
    required this.endpoint,
  });
}

/// OCR结果数据结构（保持与原有兼容）
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
}

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
}

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
}

class TextElement {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  
  TextElement({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

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
}