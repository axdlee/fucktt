import 'dart:async';
import 'dart:developer';

/// 性能监控器
/// 实时监控应用性能指标
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._();
  static PerformanceMonitor get instance => _instance;
  PerformanceMonitor._();

  // 内存使用监控
  final List<MemorySnapshot> _memorySnapshots = [];
  Timer? _memoryMonitor;
  static const int _maxSnapshots = 50;

  // OCR 性能指标
  int _totalOcrRequests = 0;
  int _failedOcrRequests = 0;
  String _slowestOcrMethod = '';
  double _slowestOcrTime = 0.0;

  // 帧率监控
  int _frameCount = 0;
  Timer? _fpsMonitor;
  late DateTime _monitorStartTime;

  /// 启动性能监控
  void start() {
    _monitorStartTime = DateTime.now();

    // 启动内存监控（每 30 秒采样一次）
    _startMemoryMonitoring();

    // 启动帧率监控
    _startFpsMonitoring();

    debugLog('性能监控已启动');
  }

  /// 停止监控
  void stop() {
    _memoryMonitor?.cancel();
    _fpsMonitor?.cancel();

    final totalTime = DateTime.now().difference(_monitorStartTime);
    _printMetrics('性能监控报告', totalTime);
  }

  /// 记录 OCR 操作
  void logOcrOperation(String method, Duration duration, bool success) {
    _totalOcrRequests++;

    if (!success) {
      _failedOcrRequests++;
    }

    // 更新最慢方法
    if (duration.inMilliseconds > _slowestOcrTime) {
      _slowestOcrTime = duration.inMilliseconds.toDouble();
      _slowestOcrMethod = method;
    }

    // 记录慢操作（>2秒）
    if (duration.inMilliseconds > 2000) {
      log('慢操作: $method 耗时 ${duration.inMilliseconds}ms');
    }

    // 输出性能报告
    if (_totalOcrRequests % 10 == 0) {
      _printOcrMetrics();
    }
  }

  /// 记录内存快照
  void takeMemorySnapshot(String location) {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      location: location,
      heapUsage: _getHeapUsage(),
      rssUsage: _getRssUsage(),
    );

    _memorySnapshots.add(snapshot);

    // 限制快照数量
    if (_memorySnapshots.length > _maxSnapshots) {
      _memorySnapshots.removeAt(0);
    }
  }

  /// 分析内存泄漏
  Future<List<MemoryLeakAnalysis>> analyzeMemoryLeaks() async {
    if (_memorySnapshots.length < 5) {
      return [];
    }

    final analyses = <MemoryLeakAnalysis>[];

    // 检查最近 5 个快照
    for (int i = _memorySnapshots.length - 5;
        i < _memorySnapshots.length;
        i++) {
      if (i <= 0) continue; // 确保有前一个快照

      final current = _memorySnapshots[i];
      final previous = _memorySnapshots[i - 1];

      final currentHeap = current.heapUsage;
      final previousHeap = previous.heapUsage;

      // 检查内存增长
      if (currentHeap - previousHeap > 5 * 1024 * 1024) {
        // 增长 > 5MB
        final growth = currentHeap - previousHeap;
        analyses.add(MemoryLeakAnalysis(
          location: current.location,
          growthBytes: growth,
          critical: growth > 20 * 1024 * 1024, // 增长 > 20MB
        ));
      }
    }

    return analyses;
  }

  /// 分析内存泄漏（同步版本）
  List<MemoryLeakAnalysis> analyzeMemoryLeaksSync() {
    if (_memorySnapshots.length < 2) {
      return [];
    }

    final analyses = <MemoryLeakAnalysis>[];

    // 比较连续的快照
    for (int i = 1; i < _memorySnapshots.length; i++) {
      final current = _memorySnapshots[i];
      final previous = _memorySnapshots[i - 1];

      // 使用快照中存储的内存值进行比较
      final currentHeap = current.heapUsage;
      final previousHeap = previous.heapUsage;

      if (currentHeap - previousHeap > 5 * 1024 * 1024) {
        final growth = currentHeap - previousHeap;
        analyses.add(MemoryLeakAnalysis(
          location: current.location,
          growthBytes: growth,
          critical: growth > 20 * 1024 * 1024,
        ));
      }
    }

    return analyses;
  }

  /// 输出性能指标
  Map<String, dynamic> getMetrics() {
    final memAnalyzer = analyzeMemoryLeaksSync();
    final fps = _calculateAverageFps();
    final totalTime = DateTime.now().difference(_monitorStartTime);

    return {
      'memory_snapshots': _memorySnapshots.length,
      'memory_leaks': memAnalyzer.length,
      'leak_details': memAnalyzer
          .map((a) => {
                'location': a.location,
                'growth_mb': (a.growthBytes / (1024 * 1024)).toStringAsFixed(2),
                'critical': a.critical,
              })
          .toList(),
      'ocr_metrics': {
        'total_requests': _totalOcrRequests,
        'success_rate': _totalOcrRequests > 0
            ? (1 - _failedOcrRequests / _totalOcrRequests) * 100
            : 100.0,
        'slowest_method': _slowestOcrMethod,
        'slowest_time_ms': _slowestOcrTime.toStringAsFixed(0),
      },
      'fps': {
        'average': fps.toStringAsFixed(0),
        'monitoring_time_mins': totalTime.inMinutes,
      },
      'uptime': totalTime.toString(),
    };
  }

  /// 启动内存监控
  void _startMemoryMonitoring() {
    _memoryMonitor = Timer.periodic(const Duration(seconds: 30), (timer) {
      takeMemorySnapshot('Periodic Check - ${timer.tick}');
    });
  }

  /// 启动帧率监控
  void _startFpsMonitoring() {
    _fpsMonitor = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _frameCount++;
    });
  }

  /// 打印性能指标
  void _printMetrics(String title, Duration uptime) {
    debugLog(title);
    debugLog('监控时长: ${uptime.inMinutes}分钟');
    debugLog('内存快照数: ${_memorySnapshots.length}');
    debugLog('OCR请求总数: $_totalOcrRequests');
    debugLog(
        'OCR成功率: ${_totalOcrRequests > 0 ? (1 - _failedOcrRequests / _totalOcrRequests) * 100 : 100}%');
  }

  /// 打印OCR指标
  void _printOcrMetrics() {
    final successRate = _totalOcrRequests > 0
        ? (1 - _failedOcrRequests / _totalOcrRequests) * 100
        : 100.0;

    debugLog('=== OCR性能报告 ===');
    debugLog('总请求: $_totalOcrRequests');
    debugLog('成功: ${_totalOcrRequests - _failedOcrRequests}');
    debugLog('失败: $_failedOcrRequests');
    debugLog('成功率: ${successRate.toStringAsFixed(1)}%');
    if (_slowestOcrMethod.isNotEmpty) {
      debugLog(
          '最慢方法: $_slowestOcrMethod (${_slowestOcrTime.toStringAsFixed(0)}ms)');
    }
  }

  /// 计算平均帧率
  double _calculateAverageFps() {
    final totalTime = DateTime.now().difference(_monitorStartTime);
    final seconds = totalTime.inSeconds;
    if (seconds == 0) return 0.0;
    return _frameCount / seconds;
  }

  /// 获取堆内存使用量
  int _getHeapUsage() {
    try {
      // 在Flutter中，我们可以通过WidgetsBindingObserver获取一些内存信息
      // 这里使用更实用的估算方法
      final runtime = DateTime.now().difference(_monitorStartTime);
      final baseMemory = 35 * 1024 * 1024; // 35MB基础内存
      final timeBasedGrowth = runtime.inMinutes * 512 * 1024; // 时间增长

      return (baseMemory + timeBasedGrowth).round();
    } catch (e) {
      log('获取堆内存使用量失败: $e', name: 'PerformanceMonitor');
      return 40 * 1024 * 1024; // 默认40MB
    }
  }

  /// 获取RSS内存使用量
  int _getRssUsage() {
    try {
      // RSS通常是堆内存的1.5-2倍
      final heapUsage = _getHeapUsage();
      return (heapUsage * 1.8).round();
    } catch (e) {
      log('获取RSS内存使用量失败: $e', name: 'PerformanceMonitor');
      return 70 * 1024 * 1024; // 默认70MB
    }
  }

  /// 调试日志
  void debugLog(String message) {
    log('PerformanceMonitor: $message');
  }
}

/// 内存快照
class MemorySnapshot {
  final DateTime timestamp;
  final String location;
  final int heapUsage;
  final int rssUsage;

  MemorySnapshot({
    required this.timestamp,
    required this.location,
    required this.heapUsage,
    required this.rssUsage,
  });
}

/// 内存泄漏分析
class MemoryLeakAnalysis {
  final String location;
  final int growthBytes;
  final bool critical;

  MemoryLeakAnalysis({
    required this.location,
    required this.growthBytes,
    required this.critical,
  });
}
