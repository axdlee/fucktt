import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// 错误类型枚举
enum ErrorType {
  network,
  storage,
  ai,
  validation,
  permission,
  system,
  unknown,
}

/// 错误严重级别
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// 应用错误模型
class AppError {
  final String id;
  final ErrorType type;
  final ErrorSeverity severity;
  final String message;
  final String? details;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  AppError({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.details,
    this.stackTrace,
    DateTime? timestamp,
    this.context = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'stackTrace': stackTrace?.toString(),
    };
  }

  factory AppError.fromJson(Map<String, dynamic> json) {
    return AppError(
      id: json['id'],
      type: ErrorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ErrorType.unknown,
      ),
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
      message: json['message'],
      details: json['details'],
      timestamp: DateTime.parse(json['timestamp']),
      context: Map<String, dynamic>.from(json['context'] ?? {}),
    );
  }
}

/// 错误处理和异常管理服务
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final List<AppError> _errorHistory = [];
  final StreamController<AppError> _errorStreamController = StreamController.broadcast();
  
  static const int maxErrorHistory = 500;
  static const String storageKey = 'error_logs';

  /// 错误流，用于监听新错误
  Stream<AppError> get errorStream => _errorStreamController.stream;

  /// 初始化错误处理服务
  Future<void> initialize() async {
    // 设置全局错误处理
    FlutterError.onError = _handleFlutterError;
    
    // 设置Zone错误处理
    runZonedGuarded(() {
      // 应用启动代码会在这里执行
    }, _handleZoneError);

    // 加载历史错误日志
    await _loadErrorHistory();

    if (kDebugMode) {
      print('🛡️ 错误处理服务已初始化');
    }
  }

  /// 处理Flutter框架错误
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      id: _generateErrorId(),
      type: ErrorType.system,
      severity: ErrorSeverity.high,
      message: details.exception.toString(),
      details: details.summary.toString(),
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    recordError(error);

    // 在debug模式下打印到控制台
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// 处理Zone错误
  void _handleZoneError(Object error, StackTrace stackTrace) {
    final appError = AppError(
      id: _generateErrorId(),
      type: ErrorType.system,
      severity: ErrorSeverity.critical,
      message: error.toString(),
      stackTrace: stackTrace,
      context: {
        'source': 'Zone',
      },
    );

    recordError(appError);
  }

  /// 记录错误
  void recordError(AppError error) {
    _errorHistory.add(error);
    _errorStreamController.add(error);

    // 限制错误历史长度
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeAt(0);
    }

    // 保存到本地存储
    _saveErrorToStorage(error);

    // 根据严重程度处理
    _handleErrorBySeverity(error);

    if (kDebugMode) {
      print('❌ 错误记录: [${error.type.name}] ${error.message}');
    }
  }

  /// 记录网络错误
  void recordNetworkError(String message, {
    String? details,
    int? statusCode,
    String? url,
  }) {
    final error = AppError(
      id: _generateErrorId(),
      type: ErrorType.network,
      severity: _getNetworkErrorSeverity(statusCode),
      message: message,
      details: details,
      context: {
        'statusCode': statusCode,
        'url': url,
      },
    );

    recordError(error);
  }

  /// 记录AI服务错误
  void recordAIError(String message, {
    String? providerId,
    String? model,
    String? details,
  }) {
    final error = AppError(
      id: _generateErrorId(),
      type: ErrorType.ai,
      severity: ErrorSeverity.medium,
      message: message,
      details: details,
      context: {
        'providerId': providerId,
        'model': model,
      },
    );

    recordError(error);
  }

  /// 记录存储错误
  void recordStorageError(String message, {
    String? operation,
    String? key,
    String? details,
  }) {
    final error = AppError(
      id: _generateErrorId(),
      type: ErrorType.storage,
      severity: ErrorSeverity.high,
      message: message,
      details: details,
      context: {
        'operation': operation,
        'key': key,
      },
    );

    recordError(error);
  }

  /// 记录验证错误
  void recordValidationError(String message, {
    String? field,
    dynamic value,
    String? details,
  }) {
    final error = AppError(
      id: _generateErrorId(),
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      message: message,
      details: details,
      context: {
        'field': field,
        'value': value?.toString(),
      },
    );

    recordError(error);
  }

  /// 处理异常并返回用户友好的错误信息
  String handleException(dynamic exception, {String? operation}) {
    String userMessage;
    ErrorType errorType;
    ErrorSeverity severity;

    if (exception is SocketException) {
      userMessage = '网络连接失败，请检查网络设置';
      errorType = ErrorType.network;
      severity = ErrorSeverity.medium;
    } else if (exception is TimeoutException) {
      userMessage = '操作超时，请稍后重试';
      errorType = ErrorType.network;
      severity = ErrorSeverity.medium;
    } else if (exception is FormatException) {
      userMessage = '数据格式错误';
      errorType = ErrorType.validation;
      severity = ErrorSeverity.low;
    } else if (exception is FileSystemException) {
      userMessage = '文件操作失败';
      errorType = ErrorType.storage;
      severity = ErrorSeverity.high;
    } else {
      userMessage = '未知错误，请联系技术支持';
      errorType = ErrorType.unknown;
      severity = ErrorSeverity.medium;
    }

    final error = AppError(
      id: _generateErrorId(),
      type: errorType,
      severity: severity,
      message: exception.toString(),
      context: {
        'operation': operation,
        'userMessage': userMessage,
      },
    );

    recordError(error);
    return userMessage;
  }

  /// 获取错误统计
  Map<String, dynamic> getErrorStatistics({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentErrors = _errorHistory
        .where((error) => error.timestamp.isAfter(cutoffDate))
        .toList();

    final typeCount = <ErrorType, int>{};
    final severityCount = <ErrorSeverity, int>{};
    final dailyCount = <String, int>{};

    for (final error in recentErrors) {
      // 按类型统计
      typeCount[error.type] = (typeCount[error.type] ?? 0) + 1;
      
      // 按严重程度统计
      severityCount[error.severity] = (severityCount[error.severity] ?? 0) + 1;
      
      // 按日期统计
      final dateKey = '${error.timestamp.year}-${error.timestamp.month.toString().padLeft(2, '0')}-${error.timestamp.day.toString().padLeft(2, '0')}';
      dailyCount[dateKey] = (dailyCount[dateKey] ?? 0) + 1;
    }

    return {
      'totalErrors': recentErrors.length,
      'typeCount': typeCount.map((k, v) => MapEntry(k.name, v)),
      'severityCount': severityCount.map((k, v) => MapEntry(k.name, v)),
      'dailyCount': dailyCount,
      'period': days,
    };
  }

  /// 清理错误日志
  Future<void> clearErrorHistory({int? keepDays}) async {
    if (keepDays != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      _errorHistory.removeWhere((error) => error.timestamp.isBefore(cutoffDate));
    } else {
      _errorHistory.clear();
    }

    await _saveErrorHistory();
  }

  /// 导出错误日志
  Future<String> exportErrorLogs() async {
    final logs = _errorHistory.map((error) => error.toJson()).toList();
    return logs.toString();
  }

  /// 根据严重程度处理错误
  void _handleErrorBySeverity(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.critical:
        // 关键错误：可能需要重启应用或显示错误页面
        _showCriticalErrorDialog(error);
        break;
      case ErrorSeverity.high:
        // 高级错误：显示错误提示
        _showErrorSnackBar(error);
        break;
      case ErrorSeverity.medium:
      case ErrorSeverity.low:
        // 中低级错误：记录日志即可
        break;
    }
  }

  /// 显示关键错误对话框
  void _showCriticalErrorDialog(AppError error) {
    // 在实际应用中，这里需要获取BuildContext
    // 这里仅作为示例
    if (kDebugMode) {
      print('🚨 关键错误: ${error.message}');
    }
  }

  /// 显示错误SnackBar
  void _showErrorSnackBar(AppError error) {
    // 在实际应用中，这里需要获取ScaffoldMessenger
    // 这里仅作为示例
    if (kDebugMode) {
      print('⚠️ 错误提示: ${error.message}');
    }
  }

  /// 获取网络错误严重程度
  ErrorSeverity _getNetworkErrorSeverity(int? statusCode) {
    if (statusCode == null) return ErrorSeverity.high;
    
    if (statusCode >= 500) return ErrorSeverity.high;
    if (statusCode >= 400) return ErrorSeverity.medium;
    return ErrorSeverity.low;
  }

  /// 生成错误ID
  String _generateErrorId() {
    return 'error_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 检查存储服务是否可用
  bool _isStorageAvailable() {
    try {
      final box = StorageService.settingsBox;
      return box.isOpen;
    } catch (e) {
      return false;
    }
  }

  /// 保存错误到本地存储
  Future<void> _saveErrorToStorage(AppError error) async {
    try {
      if (!_isStorageAvailable()) {
        if (kDebugMode) {
          print('💾 存储服务不可用，跳过错误日志保存');
        }
        return;
      }
      
      final box = StorageService.settingsBox;
      final existingLogs = box.get(storageKey, defaultValue: <String>[]) as List;
      existingLogs.add(error.toJson().toString());
      
      // 限制存储的错误数量
      if (existingLogs.length > 100) {
        existingLogs.removeAt(0);
      }
      
      await box.put(storageKey, existingLogs);
    } catch (e) {
      if (kDebugMode) {
        print('保存错误日志失败: $e');
      }
    }
  }

  /// 加载历史错误日志
  Future<void> _loadErrorHistory() async {
    try {
      if (!_isStorageAvailable()) {
        if (kDebugMode) {
          print('💾 存储服务不可用，跳过加载错误历史');
        }
        return;
      }
      
      final box = StorageService.settingsBox;
      final logs = box.get(storageKey, defaultValue: <String>[]) as List;
      
      // 这里简化处理，实际应该解析JSON
      // 由于复杂性，暂时跳过加载历史记录
      
    } catch (e) {
      if (kDebugMode) {
        print('加载错误历史失败: $e');
      }
    }
  }

  /// 保存错误历史
  Future<void> _saveErrorHistory() async {
    try {
      if (!_isStorageAvailable()) {
        if (kDebugMode) {
          print('💾 存储服务不可用，跳过保存错误历史');
        }
        return;
      }
      
      final logs = _errorHistory.map((error) => error.toJson().toString()).toList();
      final box = StorageService.settingsBox;
      await box.put(storageKey, logs);
    } catch (e) {
      if (kDebugMode) {
        print('保存错误历史失败: $e');
      }
    }
  }

  /// 释放资源
  void dispose() {
    _errorStreamController.close();
  }

  /// 获取错误历史
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);
}