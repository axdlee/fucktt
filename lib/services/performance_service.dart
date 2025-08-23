import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';

/// 性能优化服务 - 提升应用性能和响应速度
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  // 性能监控数据
  final List<PerformanceMetric> _metrics = [];
  Timer? _monitorTimer;
  bool _isMonitoring = false;
  
  // 缓存策略
  final Map<String, CacheItem> _memoryCache = {};
  static const int maxCacheSize = 100;
  static const Duration defaultCacheDuration = Duration(minutes: 10);
  
  // 异步任务队列
  final List<Future> _pendingTasks = [];
  
  /// 初始化性能服务
  Future<void> initialize() async {
    await _setupPerformanceMonitoring();
    await _optimizeSystemSettings();
    _startMemoryCleaner();
  }
  
  /// 设置性能监控
  Future<void> _setupPerformanceMonitoring() async {
    if (kDebugMode) {
      _isMonitoring = true;
      _monitorTimer = Timer.periodic(
        const Duration(seconds: 5),
        _collectPerformanceMetrics,
      );
    }
  }
  
  /// 收集性能指标
  void _collectPerformanceMetrics(Timer timer) {
    final now = DateTime.now();
    final memory = _getMemoryUsage();
    final cacheSize = _memoryCache.length;
    
    final metric = PerformanceMetric(
      timestamp: now,
      memoryUsageMB: memory,
      cacheItemCount: cacheSize,
      pendingTaskCount: _pendingTasks.length,
    );
    
    _metrics.add(metric);
    
    // 只保留最近100条记录
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
    
    // 检查性能警告
    _checkPerformanceWarnings(metric);
  }
  
  /// 获取内存使用情况 (简化实现)
  double _getMemoryUsage() {
    // 在实际应用中，可以使用平台特定的API获取真实内存使用情况
    // 这里使用缓存大小作为简化指标
    return _memoryCache.length * 0.1; // 假设每个缓存项占用0.1MB
  }
  
  /// 检查性能警告
  void _checkPerformanceWarnings(PerformanceMetric metric) {
    final warnings = <String>[];
    
    if (metric.memoryUsageMB > 50) {
      warnings.add('内存使用过高: ${metric.memoryUsageMB.toStringAsFixed(1)}MB');
    }
    
    if (metric.cacheItemCount > maxCacheSize * 0.8) {
      warnings.add('缓存项过多: ${metric.cacheItemCount}');
      _cleanupCache();
    }
    
    if (metric.pendingTaskCount > 10) {
      warnings.add('待处理任务过多: ${metric.pendingTaskCount}');
    }
    
    if (warnings.isNotEmpty && kDebugMode) {
      print('⚠️ 性能警告: ${warnings.join(', ')}');
    }
  }
  
  /// 优化系统设置
  Future<void> _optimizeSystemSettings() async {
    try {
      // 设置系统UI样式
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      
      // 优化屏幕方向
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
    } catch (e) {
      if (kDebugMode) {
        print('系统设置优化失败: $e');
      }
    }
  }
  
  /// 启动内存清理器
  void _startMemoryCleaner() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupCache();
      _cleanupPendingTasks();
    });
  }
  
  /// 清理缓存
  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _memoryCache.forEach((key, item) {
      if (now.difference(item.createdAt) > item.duration) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
    
    // 如果缓存仍然过大，删除最老的项目
    if (_memoryCache.length > maxCacheSize) {
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final itemsToRemove = _memoryCache.length - maxCacheSize;
      for (int i = 0; i < itemsToRemove; i++) {
        _memoryCache.remove(sortedEntries[i].key);
      }
    }
    
    if (kDebugMode) {
      print('🧹 缓存清理完成，当前缓存项: ${_memoryCache.length}');
    }
  }
  
  /// 清理待处理任务
  void _cleanupPendingTasks() {
    // 简化实现：清理超时任务
    if (_pendingTasks.length > 50) {
      final tasksToKeep = _pendingTasks.take(25).toList();
      _pendingTasks.clear();
      _pendingTasks.addAll(tasksToKeep);
    }
  }
  
  /// 缓存数据
  void cacheData<T>(String key, T data, {Duration? duration}) {
    _memoryCache[key] = CacheItem(
      data: data,
      createdAt: DateTime.now(),
      duration: duration ?? defaultCacheDuration,
    );
  }
  
  /// 获取缓存数据
  T? getCachedData<T>(String key) {
    final item = _memoryCache[key];
    if (item == null) return null;
    
    final now = DateTime.now();
    if (now.difference(item.createdAt) > item.duration) {
      _memoryCache.remove(key);
      return null;
    }
    
    return item.data as T?;
  }
  
  /// 预加载数据
  Future<void> preloadData() async {
    try {
      // 预加载用户配置
      _addTask(_preloadUserConfig());
      
      // 预加载AI服务配置
      _addTask(_preloadAIProviders());
      
      // 预加载价值观模板
      _addTask(_preloadValuesTemplates());
      
      await Future.wait(_pendingTasks.take(3));
      
      if (kDebugMode) {
        print('📦 数据预加载完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 数据预加载失败: $e');
      }
    }
  }
  
  /// 添加异步任务
  void _addTask(Future task) {
    _pendingTasks.add(task);
    task.whenComplete(() => _pendingTasks.remove(task));
  }
  
  /// 预加载用户配置
  Future<void> _preloadUserConfig() async {
    try {
      final box = StorageService.userConfigBox;
      final configs = box.values.toList();
      cacheData('user_configs', configs);
    } catch (e) {
      if (kDebugMode) {
        print('预加载用户配置失败: $e');
      }
    }
  }
  
  /// 预加载AI服务商
  Future<void> _preloadAIProviders() async {
    try {
      final box = StorageService.aiProviderBox;
      final providers = box.values.toList();
      cacheData('ai_providers', providers);
    } catch (e) {
      if (kDebugMode) {
        print('预加载AI服务商失败: $e');
      }
    }
  }
  
  /// 预加载价值观模板
  Future<void> _preloadValuesTemplates() async {
    try {
      final box = StorageService.valueTemplateBox;
      final templates = box.values.toList();
      cacheData('values_templates', templates);
    } catch (e) {
      if (kDebugMode) {
        print('预加载价值观模板失败: $e');
      }
    }
  }
  
  /// 在隔离线程中执行耗时任务
  static Future<R> runInIsolate<T, R>(
    ComputeCallback<T, R> callback,
    T message,
  ) async {
    try {
      return await compute(callback, message);
    } catch (e) {
      if (kDebugMode) {
        print('隔离线程任务执行失败: $e');
      }
      rethrow;
    }
  }
  
  /// 批量处理任务
  static Future<List<R>> batchProcess<T, R>(
    List<T> items,
    Future<R> Function(T) processor, {
    int batchSize = 10,
  }) async {
    final results = <R>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);
      
      final batchResults = await Future.wait(
        batch.map(processor),
      );
      
      results.addAll(batchResults);
      
      // 添加小延迟避免阻塞UI
      if (i + batchSize < items.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
    
    return results;
  }
  
  /// 获取性能报告
  PerformanceReport getPerformanceReport() {
    if (_metrics.isEmpty) {
      return PerformanceReport.empty();
    }
    
    final averageMemory = _metrics.map((m) => m.memoryUsageMB).reduce((a, b) => a + b) / _metrics.length;
    final maxMemory = _metrics.map((m) => m.memoryUsageMB).reduce((a, b) => a > b ? a : b);
    final averageCacheSize = _metrics.map((m) => m.cacheItemCount).reduce((a, b) => a + b) / _metrics.length;
    
    return PerformanceReport(
      averageMemoryUsage: averageMemory,
      maxMemoryUsage: maxMemory,
      averageCacheSize: averageCacheSize,
      totalMetrics: _metrics.length,
      currentCacheSize: _memoryCache.length,
      pendingTasks: _pendingTasks.length,
    );
  }
  
  /// 清理所有缓存
  void clearAllCache() {
    _memoryCache.clear();
    if (kDebugMode) {
      print('🗑️ 所有缓存已清空');
    }
  }
  
  /// 停止性能监控
  void dispose() {
    _monitorTimer?.cancel();
    _isMonitoring = false;
    clearAllCache();
  }
}

/// 性能指标模型
class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsageMB;
  final int cacheItemCount;
  final int pendingTaskCount;
  
  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsageMB,
    required this.cacheItemCount,
    required this.pendingTaskCount,
  });
}

/// 缓存项模型
class CacheItem {
  final dynamic data;
  final DateTime createdAt;
  final Duration duration;
  
  CacheItem({
    required this.data,
    required this.createdAt,
    required this.duration,
  });
}

/// 性能报告模型
class PerformanceReport {
  final double averageMemoryUsage;
  final double maxMemoryUsage;
  final double averageCacheSize;
  final int totalMetrics;
  final int currentCacheSize;
  final int pendingTasks;
  
  PerformanceReport({
    required this.averageMemoryUsage,
    required this.maxMemoryUsage,
    required this.averageCacheSize,
    required this.totalMetrics,
    required this.currentCacheSize,
    required this.pendingTasks,
  });
  
  factory PerformanceReport.empty() {
    return PerformanceReport(
      averageMemoryUsage: 0,
      maxMemoryUsage: 0,
      averageCacheSize: 0,
      totalMetrics: 0,
      currentCacheSize: 0,
      pendingTasks: 0,
    );
  }
  
  @override
  String toString() {
    return '''
性能报告:
- 平均内存使用: ${averageMemoryUsage.toStringAsFixed(2)}MB
- 峰值内存使用: ${maxMemoryUsage.toStringAsFixed(2)}MB
- 平均缓存大小: ${averageCacheSize.toStringAsFixed(1)}
- 当前缓存大小: $currentCacheSize
- 待处理任务: $pendingTasks
- 总监控次数: $totalMetrics
''';
  }
}