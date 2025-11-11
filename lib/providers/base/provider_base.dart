import 'package:flutter/foundation.dart';

/// Provider基类
/// 提供统一的状态管理机制
abstract class ProviderBase with ChangeNotifier {
  bool _isDisposed = false;
  String? _error;

  /// 检查是否已释放
  bool get isDisposed => _isDisposed;

  /// 错误信息
  String? get error => _error;

  /// 是否正在加载
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 安全的notifyListeners
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 包装异步操作
  Future<T> _runOperation<T>(Future<T> Function() operation) async {
    _setError(null);

    try {
      _setLoading(true);
      final result = await operation();
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// 重写dispose
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// 异步Provider基类
abstract class AsyncProviderBase<T> extends ProviderBase {
  AsyncValue<T>? _value;

  /// 异步值
  AsyncValue<T>? get value => _value;

  /// 数据的Getter
  T? get data => _value?.data;

  /// 是否有数据
  bool get hasData => _value?.data != null;

  /// 是否正在加载
  @override
  bool get isLoading => _value?.isLoading ?? false;

  /// 是否有错误
  bool get hasError => _value?.hasError ?? false;

  /// 错误信息
  @override
  String? get error => _value?.error?.toString();

  /// 设置数据
  void _setData(T data) {
    _value = AsyncValue.data(data);
    notifyListeners();
  }

  /// 设置错误
  void _setErrorState(Object error, StackTrace stackTrace) {
    _value = AsyncValue.error(error, stackTrace);
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoadingState() {
    _value = const AsyncValue.loading();
    notifyListeners();
  }

  /// 加载数据
  Future<void> load(Future<T> Function() loader) async {
    _setLoadingState();

    try {
      final data = await loader();
      _setData(data);
    } catch (e, stack) {
      _setErrorState(e, stack);
    }
  }

  /// 刷新数据
  Future<void> refresh(Future<T> Function() loader) async {
    await load(loader);
  }
}

/// 异步值
class AsyncValue<T> {
  final T? _data;
  final Object? _error;
  final StackTrace? _stackTrace;
  final bool _isLoading;

  const AsyncValue._(
      this._data, this._error, this._stackTrace, this._isLoading);

  /// 数据状态
  const AsyncValue.data(T data) : this._(data, null, null, false);

  /// 加载状态
  const AsyncValue.loading() : this._(null, null, null, true);

  /// 错误状态
  const AsyncValue.error(Object error, StackTrace stackTrace)
      : this._(null, error, stackTrace, false);

  /// 数据
  T? get data => _data;

  /// 错误
  Object? get error => _error;

  /// 堆栈
  StackTrace? get stackTrace => _stackTrace;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 是否有错误
  bool get hasError => _error != null;

  /// 是否有数据
  bool get hasData => _data != null;
}
