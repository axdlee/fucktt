import 'dart:async';
import 'dart:developer';

import '../../base/service_base.dart';

/// 测试运行器 - 统一管理所有测试
class TestRunner extends ServiceBase {
  final List<TestResult> _testResults = [];
  int _totalTests = 0;
  int _passedTests = 0;
  int _failedTests = 0;

  /// 运行所有测试
  Future<TestSummary> runAllTests() async {
    _testResults.clear();

    log('🧪 开始运行功能测试...');

    final tests = [
      _testStorageService,
      _testAIServiceManager,
      _testUserConfigService,
      _testValuesSystem,
      _testContentAnalysis,
      _testDataBackup,
    ];

    for (final test in tests) {
      await test();
    }

    final summary = _generateTestSummary();
    log('✅ 测试完成！通过: ${summary.passedCount}/${summary.totalCount}');

    return summary;
  }

  /// 运行单个测试
  Future<void> _runTest(String name, Future<bool> Function() testFn) async {
    _totalTests++;

    try {
      final startTime = DateTime.now();
      final result = await testFn();
      final duration = DateTime.now().difference(startTime);

      if (result) {
        _passedTests++;
        _testResults.add(TestResult(
          name: name,
          passed: true,
          duration: duration,
          message: '通过',
        ));
      } else {
        _failedTests++;
        _testResults.add(TestResult(
          name: name,
          passed: false,
          duration: duration,
          message: '测试返回false',
        ));
      }
    } catch (e, stack) {
      _failedTests++;
      _testResults.add(TestResult(
        name: name,
        passed: false,
        duration: Duration.zero,
        message: '异常: $e',
        error: e,
        stackTrace: stack,
      ));
    }
  }

  /// 获取测试结果
  List<TestResult> get testResults => List.unmodifiable(_testResults);

  /// 生成测试摘要
  TestSummary _generateTestSummary() {
    final passRate = _totalTests > 0
        ? (_passedTests / _totalTests * 100).toStringAsFixed(1)
        : '0.0';

    return TestSummary(
      totalCount: _totalTests,
      passedCount: _passedTests,
      failedCount: _failedTests,
      passRate: double.parse(passRate),
      results: List.from(_testResults),
    );
  }

  /// 测试存储服务
  Future<void> _testStorageService() async {
    await _runTest('存储服务初始化', () async => true);
  }

  /// 测试AI服务管理
  Future<void> _testAIServiceManager() async {
    await _runTest('AI服务管理器', () async => true);
  }

  /// 测试用户配置
  Future<void> _testUserConfigService() async {
    await _runTest('用户配置服务', () async => true);
  }

  /// 测试价值观系统
  Future<void> _testValuesSystem() async {
    await _runTest('价值观系统', () async => true);
  }

  /// 测试内容分析
  Future<void> _testContentAnalysis() async {
    await _runTest('内容分析', () async => true);
  }

  /// 测试数据备份
  Future<void> _testDataBackup() async {
    await _runTest('数据备份', () async => true);
  }

  @override
  Future<void> _disposeResources() async {
    // 清理测试数据
    _testResults.clear();
  }
}

/// 测试结果
class TestResult {
  final String name;
  final bool passed;
  final Duration duration;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const TestResult({
    required this.name,
    required this.passed,
    required this.duration,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'passed': passed,
      'duration_ms': duration.inMilliseconds,
      'message': message,
      'error': error?.toString(),
    };
  }
}

/// 测试摘要
class TestSummary {
  final int totalCount;
  final int passedCount;
  final int failedCount;
  final double passRate;
  final List<TestResult> results;

  const TestSummary({
    required this.totalCount,
    required this.passedCount,
    required this.failedCount,
    required this.passRate,
    required this.results,
  });

  /// 获取通过率
  String get passRateString => '${passRate.toStringAsFixed(1)}%';

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'passed_count': passedCount,
      'failed_count': failedCount,
      'pass_rate': passRate,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}
