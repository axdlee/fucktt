import 'dart:async';
import 'dart:typed_data';

import '../services/ocr_service_manager.dart';
import '../services/chinese_ocr_service.dart';

/// 🧪 OCR服务管理器演示
/// 展示Google ML Kit和国产OCR服务的切换和使用
class OCRManagerDemo {
  /// 运行完整的OCR服务演示
  static Future<void> runDemo() async {
    print('🚀 === OCR服务管理器演示开始 ===');
    print('📅 演示时间: ${DateTime.now()}');
    print('🎯 目标: 展示国产OCR服务在国内的优势');
    print('');

    final manager = OCRServiceManager.instance;

    try {
      // 第一步：初始化OCR服务管理器
      await _initializeDemo(manager);

      // 第二步：环境检测和服务状态
      await _showServiceStatus(manager);

      // 第三步：展示推荐配置
      await _showRecommendations(manager);

      // 第四步：演示策略切换
      await _demonstrateStrategySwitching(manager);

      // 第五步：模拟OCR识别测试
      await _simulateOCRRecognition(manager);

      // 第六步：性能对比测试
      await _performanceComparison(manager);

      print('🎉 === OCR服务管理器演示完成 ===');
    } catch (e) {
      print('❌ 演示过程中出现错误: $e');
    }
  }

  /// 初始化演示
  static Future<void> _initializeDemo(OCRServiceManager manager) async {
    print('📋 第一步: 初始化OCR服务管理器');
    print('');

    try {
      await manager.initialize();
      print('✅ OCR服务管理器初始化成功');
    } catch (e) {
      print('❌ 初始化失败: $e');
      rethrow;
    }

    print('');
  }

  /// 显示服务状态
  static Future<void> _showServiceStatus(OCRServiceManager manager) async {
    print('📊 第二步: 检查服务状态');
    print('');

    final status = manager.getStatus();

    print('🌍 环境检测: ${status.isInChina ? "中国大陆" : "海外"}');
    print('📈 整体状态: ${status.statusSummary}');
    print('🎯 当前策略: ${status.currentStrategy.displayName}');
    print(
        '🤖 Google ML Kit: ${status.googleMLKitAvailable ? "✅ 可用" : "❌ 不可用"}');
    print('🇨🇳 国产OCR服务: ${status.chineseOCRAvailable ? "✅ 可用" : "❌ 不可用"}');

    if (status.isInChina && !status.googleMLKitAvailable) {
      print('');
      print('💡 检测到您在国内环境，Google ML Kit不可用是正常现象');
      print('   建议使用国产OCR服务，具有以下优势：');
      print('   • 网络连接稳定');
      print('   • 中文识别准确度高');
      print('   • 无需Google Play服务');
      print('   • 支持多种国产手机');
    }

    print('');
  }

  /// 显示推荐配置
  static Future<void> _showRecommendations(OCRServiceManager manager) async {
    print('💡 第三步: 显示推荐配置');
    print('');

    final recommendation = manager.getRecommendation();

    print('🎯 推荐策略: ${recommendation.recommendedStrategy.displayName}');
    print('📝 推荐理由: ${recommendation.reason}');
    print('');
    print('🔄 备选方案:');
    for (final alternative in recommendation.alternatives) {
      print('   $alternative');
    }

    print('');
  }

  /// 演示策略切换
  static Future<void> _demonstrateStrategySwitching(
      OCRServiceManager manager) async {
    print('🔄 第四步: 演示策略切换');
    print('');

    final strategies = [
      OCRStrategy.auto,
      OCRStrategy.chineseFirst,
      OCRStrategy.chineseOnly,
    ];

    for (final strategy in strategies) {
      print('🔧 切换到策略: ${strategy.displayName}');
      manager.setStrategy(strategy);

      final status = manager.getStatus();
      print('   当前状态: ${status.currentStrategy.displayName}');
      print('');
    }
  }

  /// 模拟OCR识别测试
  static Future<void> _simulateOCRRecognition(OCRServiceManager manager) async {
    print('🔍 第五步: 模拟OCR识别测试');
    print('');

    // 模拟今日头条内容的图片数据
    final testCases = [
      {
        'name': '今日头条新闻标题',
        'expected': '科技创新助力乡村振兴发展',
        'type': '标题识别',
      },
      {
        'name': '今日头条正文内容',
        'expected': '人工智能技术在农业领域应用越来越广泛，智能农机正在改变传统农业模式。',
        'type': '正文识别',
      },
      {
        'name': '今日头条评论区',
        'expected': '这种技术真的很棒！希望能在我们这里也推广使用。',
        'type': '评论识别',
      },
    ];

    for (final testCase in testCases) {
      print('📱 测试用例: ${testCase['name']}');
      print('   类型: ${testCase['type']}');
      print('   期望结果: ${testCase['expected']}');

      try {
        // 模拟图片数据（实际应用中这里是真实的图片字节）
        final mockImageData = Uint8List.fromList([]);

        // 使用模拟的OCR结果
        final result = await _simulateOCRResult(testCase['expected'] as String);

        print('   ✅ 识别结果: ${result.fullText}');
        print('   📊 置信度: ${(result.confidence * 100).toStringAsFixed(1)}%');
        print('   🌐 语言: ${result.language}');
      } catch (e) {
        print('   ❌ 识别失败: $e');
      }

      print('');
    }
  }

  /// 性能对比测试
  static Future<void> _performanceComparison(OCRServiceManager manager) async {
    print('⚡ 第六步: 性能对比测试');
    print('');

    final testText = '价值观内容过滤器测试文本';

    // 测试不同策略的性能
    final strategies = [
      OCRStrategy.chineseFirst,
      OCRStrategy.auto,
    ];

    for (final strategy in strategies) {
      print('🧪 测试策略: ${strategy.displayName}');
      manager.setStrategy(strategy);

      final stopwatch = Stopwatch()..start();

      try {
        final result = await _simulateOCRResult(testText);
        stopwatch.stop();

        final duration = stopwatch.elapsedMilliseconds;
        print('   ⏱️ 识别耗时: ${duration}ms');
        print('   📊 置信度: ${(result.confidence * 100).toStringAsFixed(1)}%');
        print('   ✅ 状态: 成功');

        // 性能评级
        if (duration < 1000) {
          print('   🏆 性能评级: 优秀 (< 1秒)');
        } else if (duration < 3000) {
          print('   🥇 性能评级: 良好 (1-3秒)');
        } else {
          print('   🥉 性能评级: 一般 (> 3秒)');
        }
      } catch (e) {
        stopwatch.stop();
        print('   ❌ 识别失败: $e');
        print('   ⏱️ 失败耗时: ${stopwatch.elapsedMilliseconds}ms');
      }

      print('');
    }
  }

  /// 模拟OCR识别结果
  static Future<OCRResult> _simulateOCRResult(String text) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 500 + (text.length * 10)));

    // 模拟识别置信度（基于文本长度和复杂度）
    double confidence = 0.85;
    if (text.contains(RegExp(r'[0-9]'))) confidence += 0.05; // 包含数字
    if (text.contains(RegExp(r'[a-zA-Z]'))) confidence += 0.03; // 包含英文
    if (text.length > 20) confidence += 0.02; // 长文本
    confidence = confidence > 1.0 ? 1.0 : confidence;

    return OCRResult(
      fullText: text,
      textBlocks: [
        TextBlock(
          text: text,
          confidence: confidence,
          boundingBox: BoundingBox(
            left: 10,
            top: 10,
            width: text.length * 12.0,
            height: 24,
          ),
          language: 'zh',
          lines: [
            TextLine(
              text: text,
              confidence: confidence,
              boundingBox: BoundingBox(
                left: 10,
                top: 10,
                width: text.length * 12.0,
                height: 24,
              ),
              elements: [],
            ),
          ],
        ),
      ],
      confidence: confidence,
      language: text.contains(RegExp(r'[a-zA-Z]')) ? 'zh-en' : 'zh',
    );
  }

  /// 显示国产OCR服务优势说明
  static void showChineseOCRAdvantages() {
    print('🇨🇳 === 国产OCR服务优势说明 ===');
    print('');

    print('🚀 **为什么推荐在国内使用国产OCR服务？**');
    print('');

    print('❌ **Google ML Kit在国内的问题：**');
    print('   • 需要Google Play服务支持');
    print('   • 网络连接不稳定（被墙）');
    print('   • 模型下载经常失败');
    print('   • 华为、小米等国产手机兼容性差');
    print('   • 首次使用需要下载额外数据包');
    print('');

    print('✅ **国产OCR服务的优势：**');
    print('   • 🌐 网络稳定：国内服务器，连接速度快');
    print('   • 🎯 中文优化：专门针对中文优化的识别算法');
    print('   • 💰 成本友好：大部分提供免费额度');
    print('   • 🔧 易于集成：RESTful API，无需额外SDK');
    print('   • 📱 兼容性好：支持所有Android设备');
    print('   • 🛡️ 数据安全：符合国内数据安全规范');
    print('');

    print('🏆 **推荐的国产OCR服务商：**');
    print('');

    print('1️⃣ **百度OCR**');
    print('   • 免费额度：每月1000次');
    print('   • 优势：识别准确度高，接口稳定');
    print('   • 适用场景：个人开发者、小型项目');
    print('');

    print('2️⃣ **腾讯OCR**');
    print('   • 免费额度：每月1000次');
    print('   • 优势：企业级稳定性，技术支持好');
    print('   • 适用场景：商业项目、大型应用');
    print('');

    print('3️⃣ **阿里云OCR**');
    print('   • 免费额度：每月500次');
    print('   • 优势：识别速度快，API功能丰富');
    print('   • 适用场景：高并发、多样化需求');
    print('');

    print('4️⃣ **科大讯飞OCR**');
    print('   • 免费额度：每日500次');
    print('   • 优势：本土化程度高，中文处理优秀');
    print('   • 适用场景：教育、政府项目');
    print('');

    print('💡 **使用建议：**');
    print('   • 开发阶段：使用百度OCR（免费额度最多）');
    print('   • 生产环境：根据QPS选择腾讯或阿里云');
    print('   • 备用方案：配置多个服务商，自动故障转移');
    print('   • 成本控制：合理使用缓存，避免重复识别');
    print('');
  }
}

/// 主函数 - 运行OCR演示
void main() async {
  await OCRManagerDemo.runDemo();
  print('');
  OCRManagerDemo.showChineseOCRAdvantages();
}
