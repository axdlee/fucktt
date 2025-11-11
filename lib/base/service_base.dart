import 'dart:async';

/// 服务基类 - 统一资源管理
/// 提供生命周期管理和资源释放机制
abstract class ServiceBase {
  bool _disposed = false;
  final List<StreamSubscription> _subscriptions = [];
  final List<Completer<void>> _pendingOperations = [];

  /// 检查服务是否已释放
  bool get isDisposed => _disposed;

  /// 保证在非 disposed 状态执行操作
  T _ensureNotDisposed<T>(T Function() operation) {
    if (_disposed) {
      throw StateError('Cannot use service after disposal');
    }
    return operation();
  }

  /// 追踪订阅（可选自动取消）
  void _trackSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// 追踪异步操作
  Completer<void> _trackOperation() {
    final completer = Completer<void>();
    _pendingOperations.add(completer);
    return completer;
  }

  /// 子类重写：释放具体资源
  Future<void> _disposeResources() async {
    // 子类实现具体资源释放
  }

  /// 获取异步操作完成
  Future<void> _waitForPendingOperations() async {
    final pending = List<Completer<void>>.from(_pendingOperations);
    _pendingOperations.clear();
    await Future.wait(pending.map((c) => c.future));
  }

  /// 生命周期：释放资源
  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;

    // 等待正在进行的操作
    await _waitForPendingOperations();

    // 取消所有订阅
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // 释放具体资源
    await _disposeResources();

    print('✅ 服务 $runtimeType 已释放资源');
  }
}
