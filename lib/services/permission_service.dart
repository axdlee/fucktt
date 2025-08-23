import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限类型枚举
enum PermissionType {
  accessibility,    // 无障碍服务
  overlay,         // 悬浮窗
  storage,         // 存储
  camera,          // 摄像头
  notification,    // 通知
}

/// 权限管理服务
class PermissionService {
  static const MethodChannel _channel = MethodChannel('value_filter/permissions');
  
  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();
  
  PermissionService._();
  
  /// 检查所有必要权限
  Future<Map<PermissionType, bool>> checkAllPermissions() async {
    final results = <PermissionType, bool>{};
    
    // 检查基础权限
    results[PermissionType.storage] = await _checkStoragePermission();
    results[PermissionType.notification] = await _checkNotificationPermission();
    
    // 检查Android特定权限
    if (await _isAndroid()) {
      results[PermissionType.accessibility] = await _checkAccessibilityPermission();
      results[PermissionType.overlay] = await _checkOverlayPermission();
    }
    
    return results;
  }
  
  /// 请求所有必要权限
  Future<Map<PermissionType, bool>> requestAllPermissions() async {
    final results = <PermissionType, bool>{};
    
    // 请求基础权限
    results[PermissionType.storage] = await _requestStoragePermission();
    results[PermissionType.notification] = await _requestNotificationPermission();
    
    // 请求Android特定权限
    if (await _isAndroid()) {
      results[PermissionType.accessibility] = await _requestAccessibilityPermission();
      results[PermissionType.overlay] = await _requestOverlayPermission();
    }
    
    return results;
  }
  
  /// 检查存储权限
  Future<bool> _checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      print('检查存储权限失败: $e');
      return false;
    }
  }
  
  /// 请求存储权限
  Future<bool> _requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('请求存储权限失败: $e');
      return false;
    }
  }
  
  /// 检查通知权限
  Future<bool> _checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('检查通知权限失败: $e');
      return false;
    }
  }
  
  /// 请求通知权限
  Future<bool> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('请求通知权限失败: $e');
      return false;
    }
  }
  
  /// 检查无障碍权限
  Future<bool> _checkAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod('checkAccessibilityPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('检查无障碍权限失败: $e');
      return false;
    }
  }
  
  /// 请求无障碍权限
  Future<bool> _requestAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod('requestAccessibilityPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('请求无障碍权限失败: $e');
      return false;
    }
  }
  
  /// 检查悬浮窗权限
  Future<bool> _checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('checkOverlayPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('检查悬浮窗权限失败: $e');
      return false;
    }
  }
  
  /// 请求悬浮窗权限
  Future<bool> _requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('requestOverlayPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('请求悬浮窗权限失败: $e');
      return false;
    }
  }
  
  /// 检查是否为Android平台
  Future<bool> _isAndroid() async {
    try {
      final result = await _channel.invokeMethod('isAndroid');
      return result as bool? ?? false;
    } catch (e) {
      // 如果原生方法不可用，假设为Android
      return true;
    }
  }
  
  /// 打开应用设置页面
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('打开应用设置失败: $e');
    }
  }
  
  /// 打开无障碍设置页面
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      print('打开无障碍设置失败: $e');
    }
  }
  
  /// 打开悬浮窗设置页面
  Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (e) {
      print('打开悬浮窗设置失败: $e');
    }
  }
  
  /// 获取权限说明文本
  String getPermissionDescription(PermissionType type) {
    switch (type) {
      case PermissionType.accessibility:
        return '无障碍服务权限用于读取今日头条应用中的内容，实现智能过滤功能。';
      case PermissionType.overlay:
        return '悬浮窗权限用于在今日头条应用上显示快捷操作按钮，方便您进行举报和屏蔽操作。';
      case PermissionType.notification:
        return '通知权限用于向您发送过滤结果和重要提醒信息。';
      case PermissionType.storage:
        return '存储权限用于保存您的配置信息和过滤历史数据。';
      case PermissionType.camera:
        return '相机权限用于扫描二维码导入配置信息。';
    }
  }
  
  /// 获取权限名称
  String getPermissionName(PermissionType type) {
    switch (type) {
      case PermissionType.accessibility:
        return '无障碍服务';
      case PermissionType.overlay:
        return '悬浮窗显示';
      case PermissionType.notification:
        return '通知权限';
      case PermissionType.storage:
        return '存储权限';
      case PermissionType.camera:
        return '相机权限';
    }
  }
  
  /// 检查权限是否为必须的
  bool isPermissionRequired(PermissionType type) {
    switch (type) {
      case PermissionType.accessibility:
      case PermissionType.storage:
        return true; // 必须权限
      case PermissionType.overlay:
      case PermissionType.notification:
      case PermissionType.camera:
        return false; // 可选权限
    }
  }
  
  /// 获取所有需要的权限
  List<PermissionType> getRequiredPermissions() {
    return [
      PermissionType.accessibility,
      PermissionType.storage,
      PermissionType.overlay,
      PermissionType.notification,
    ];
  }
  
  /// 检查是否所有必须权限都已获得
  Future<bool> hasAllRequiredPermissions() async {
    final permissions = await checkAllPermissions();
    
    for (final type in getRequiredPermissions()) {
      if (isPermissionRequired(type) && !(permissions[type] ?? false)) {
        return false;
      }
    }
    
    return true;
  }
}