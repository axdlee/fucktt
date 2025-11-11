import 'dart:async';
import 'dart:developer';
import 'dart:io';

import '../../base/service_base.dart';

/// 错误处理器
/// 统一处理应用中的异常和错误
class ErrorHandler extends ServiceBase {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  ErrorHandler._();

  final StreamController<AppError> _errorStream =
      StreamController<AppError>.broadcast();

  /// 错误流 - 供UI监听
  Stream<AppError> get errorStream => _errorStream.stream;

  /// 报告错误
  void reportError(Object error, StackTrace stackTrace, {String? context}) {
    final appError = AppError(
      message: error.toString(),
      stackTrace: stackTrace,
      context: context,
      timestamp: DateTime.now(),
      type: _getErrorType(error),
    );

    // 输出到日志
    log('❌ 错误: ${appError.message}', error: error, stackTrace: stackTrace);

    // 发送到错误流
    _errorStream.add(appError);

    // 保存到本地日志
    _saveErrorLog(appError);
  }

  /// 处理未捕获的异步错误
  void handleAsyncError(Object error, StackTrace stackTrace) {
    reportError(error, stackTrace, context: '异步操作');
  }

  /// 处理未捕获的同步错误
  bool handleSyncError(Object error, StackTrace stackTrace) {
    reportError(error, stackTrace, context: '同步操作');
    return true; // 继续传播
  }

  /// 包装异步操作，自动处理错误
  Future<T> wrapAsync<T>(Future<T> Function() operation,
      {String? context}) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: context ?? '异步操作');
      rethrow;
    }
  }

  /// 包装同步操作，自动处理错误
  T wrapSync<T>(T Function() operation, {String? context}) {
    try {
      return operation();
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: context ?? '同步操作');
      rethrow;
    }
  }

  /// 获取错误类型
  ErrorType _getErrorType(Object error) {
    if (error is SocketException) return ErrorType.network;
    if (error is TimeoutException) return ErrorType.timeout;
    if (error is FormatException) return ErrorType.format;
    if (error is StateError) return ErrorType.state;
    return ErrorType.unknown;
  }

  /// 保存错误日志到本地
  void _saveErrorLog(AppError error) {
    // 实际实现中可以将错误保存到文件或数据库
    // 这里简化处理
    final logMessage = '''
时间: ${error.timestamp}
类型: ${error.type}
消息: ${error.message}
上下文: ${error.context ?? '无'}
堆栈: ${error.stackTrace}
''';
    // 写入文件或发送到日志服务
  }

  @override
  Future<void> _disposeResources() async {
    await _errorStream.close();
  }
}

/// 应用错误类
class AppError {
  final String message;
  final StackTrace stackTrace;
  final String? context;
  final DateTime timestamp;
  final ErrorType type;

  const AppError({
    required this.message,
    required this.stackTrace,
    required this.context,
    required this.timestamp,
    required this.type,
  });
}

/// 错误类型
enum ErrorType {
  network,
  timeout,
  format,
  state,
  unknown,
}
