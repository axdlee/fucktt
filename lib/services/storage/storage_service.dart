import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../../base/service_base.dart';

/// 存储服务
/// 提供本地数据存储和备份功能
class StorageService extends ServiceBase {
  static const String _boxName = 'storage_service';

  late final Box<Map> _dataBox;
  bool _isInitialized = false;

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _dataBox = await Hive.openBox<Map>(_boxName);
    _isInitialized = true;
  }

  /// 存储数据
  Future<void> put(String key, dynamic value) async {
    if (value is String || value is int || value is double || value is bool) {
      await _dataBox.put(key, {'value': value});
    } else {
      await _dataBox.put(key, {'value': jsonEncode(value)});
    }
  }

  /// 获取数据
  T? get<T>(String key, {T? defaultValue}) {
    final data = _dataBox.get(key);
    if (data == null) return defaultValue;

    final value = data['value'];
    if (value is T) return value;

    if (T == Map || T == List) {
      try {
        return jsonDecode(value) as T;
      } catch (e) {
        return defaultValue;
      }
    }

    return defaultValue ?? value as T?;
  }

  /// 删除数据
  Future<void> delete(String key) async {
    await _dataBox.delete(key);
  }

  /// 清空所有数据
  Future<void> clear() async {
    await _dataBox.clear();
  }

  /// 检查是否存在
  bool containsKey(String key) {
    return _dataBox.containsKey(key);
  }

  /// 获取所有键
  List<String> getAllKeys() {
    return _dataBox.keys.cast<String>().toList();
  }

  @override
  Future<void> _disposeResources() async {
    await _dataBox.close();
  }
}
