import '../models/user_config_model.dart';
import 'dart:developer';
import 'storage_service.dart';

/// 用户配置服务 - 管理用户配置的读写操作
class UserConfigService {
  static const String defaultUserId = 'default_user';
  
  /// 获取用户配置
  static UserConfigModel? getUserConfig([String? userId]) {
    final box = StorageService.userConfigBox;
    return box.get(userId ?? defaultUserId);
  }
  
  /// 保存用户配置
  static Future<void> saveUserConfig(UserConfigModel config) async {
    final box = StorageService.userConfigBox;
    final updatedConfig = config.copyWith(
      updatedAt: DateTime.now(),
    );
    await box.put(config.userId, updatedConfig);
  }
  
  /// 更新应用设置
  static Future<void> updateAppSettings(AppSettings settings) async {
    final config = getUserConfig();
    if (config != null) {
      final updatedConfig = config.copyWith(
        appSettings: settings,
        updatedAt: DateTime.now(),
      );
      await saveUserConfig(updatedConfig);
    }
  }
  
  /// 更新过滤设置
  static Future<void> updateFilterSettings(FilterSettings settings) async {
    final config = getUserConfig();
    if (config != null) {
      final updatedConfig = config.copyWith(
        filterSettings: settings,
        updatedAt: DateTime.now(),
      );
      await saveUserConfig(updatedConfig);
    }
  }
  
  /// 更新隐私设置
  static Future<void> updatePrivacySettings(PrivacySettings settings) async {
    final config = getUserConfig();
    if (config != null) {
      final updatedConfig = config.copyWith(
        privacySettings: settings,
        updatedAt: DateTime.now(),
      );
      await saveUserConfig(updatedConfig);
    }
  }
  
  /// 获取应用设置
  static AppSettings getAppSettings() {
    final config = getUserConfig();
    return config?.appSettings ?? AppSettings();
  }
  
  /// 获取过滤设置
  static FilterSettings getFilterSettings() {
    final config = getUserConfig();
    return config?.filterSettings ?? FilterSettings();
  }
  
  /// 获取隐私设置
  static PrivacySettings getPrivacySettings() {
    final config = getUserConfig();
    return config?.privacySettings ?? PrivacySettings();
  }
  
  /// 重置为默认配置
  static Future<void> resetToDefault() async {
    final defaultConfig = UserConfigModel(
      userId: defaultUserId,
      userName: '默认用户',
      appSettings: AppSettings(),
      filterSettings: FilterSettings(),
      privacySettings: PrivacySettings(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: '1.0.0',
    );
    await saveUserConfig(defaultConfig);
  }
  
  /// 检查配置是否存在
  static bool hasUserConfig([String? userId]) {
    final box = StorageService.userConfigBox;
    return box.containsKey(userId ?? defaultUserId);
  }
  
  /// 删除用户配置
  static Future<void> deleteUserConfig([String? userId]) async {
    final box = StorageService.userConfigBox;
    await box.delete(userId ?? defaultUserId);
  }
  
  /// 获取所有用户配置
  static List<UserConfigModel> getAllUserConfigs() {
    final box = StorageService.userConfigBox;
    return box.values.toList();
  }
  
  /// 导出用户配置
  static Map<String, dynamic> exportUserConfig([String? userId]) {
    final config = getUserConfig(userId);
    if (config != null) {
      return {
        'config': config.toJson(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    }
    return {};
  }
  
  /// 导入用户配置
  static Future<bool> importUserConfig(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('config')) {
        final config = UserConfigModel.fromJson(data['config']);
        await saveUserConfig(config);
        return true;
      }
      return false;
    } catch (e) {
      log('导入用户配置失败: $e');
      return false;
    }
  }
}