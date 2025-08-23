import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_config_model.dart';
import '../services/user_config_service.dart';
import '../constants/app_constants.dart';

/// 应用主Provider - 管理全局应用状态
class AppProvider extends ChangeNotifier {
  UserConfigModel? _userConfig;
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppConstants.primaryColor;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserConfigModel? get userConfig => _userConfig;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  AppSettings get appSettings => _userConfig?.appSettings ?? AppSettings();
  FilterSettings get filterSettings => _userConfig?.filterSettings ?? FilterSettings();
  PrivacySettings get privacySettings => _userConfig?.privacySettings ?? PrivacySettings();

  /// 初始化应用Provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      await _loadUserConfig();
      await _applyThemeSettings();
      
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载用户配置
  Future<void> _loadUserConfig() async {
    _userConfig = UserConfigService.getUserConfig();
    
    if (_userConfig == null) {
      // 创建默认配置
      await UserConfigService.resetToDefault();
      _userConfig = UserConfigService.getUserConfig();
    }
    
    if (_userConfig != null) {
      _applyAppSettings(_userConfig!.appSettings);
    }
  }

  /// 应用主题设置
  Future<void> _applyThemeSettings() async {
    final appSettings = _userConfig?.appSettings;
    if (appSettings != null) {
      _themeMode = _parseThemeMode(appSettings.themeMode);
      _primaryColor = _parseColor(appSettings.primaryColor);
    }
  }

  /// 应用应用设置
  void _applyAppSettings(AppSettings settings) {
    _themeMode = _parseThemeMode(settings.themeMode);
    _primaryColor = _parseColor(settings.primaryColor);
    
    // 应用系统UI样式
    _updateSystemUIOverlay();
  }

  /// 更新系统UI覆盖样式
  void _updateSystemUIOverlay() {
    final isDark = _themeMode == ThemeMode.dark || 
        (_themeMode == ThemeMode.system && 
         WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  /// 更新应用设置
  Future<void> updateAppSettings(AppSettings settings) async {
    _setLoading(true);
    
    try {
      await UserConfigService.updateAppSettings(settings);
      _userConfig = UserConfigService.getUserConfig();
      
      _applyAppSettings(settings);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('更新应用设置失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新过滤设置
  Future<void> updateFilterSettings(FilterSettings settings) async {
    _setLoading(true);
    
    try {
      await UserConfigService.updateFilterSettings(settings);
      _userConfig = UserConfigService.getUserConfig();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('更新过滤设置失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新隐私设置
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    _setLoading(true);
    
    try {
      await UserConfigService.updatePrivacySettings(settings);
      _userConfig = UserConfigService.getUserConfig();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('更新隐私设置失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    final currentSettings = appSettings;
    final newSettings = currentSettings.copyWith(
      themeMode: mode.toString().split('.').last,
    );
    await updateAppSettings(newSettings);
  }

  /// 设置主色调
  Future<void> setPrimaryColor(Color color) async {
    final currentSettings = appSettings;
    final newSettings = currentSettings.copyWith(
      primaryColor: '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    );
    await updateAppSettings(newSettings);
  }

  /// 切换悬浮按钮显示
  Future<void> toggleFloatingButton() async {
    final currentSettings = appSettings;
    final newSettings = currentSettings.copyWith(
      enableFloatingButton: !currentSettings.enableFloatingButton,
    );
    await updateAppSettings(newSettings);
  }

  /// 切换通知
  Future<void> toggleNotifications() async {
    final currentSettings = appSettings;
    final newSettings = currentSettings.copyWith(
      enableNotifications: !currentSettings.enableNotifications,
    );
    await updateAppSettings(newSettings);
  }

  /// 重置为默认设置
  Future<void> resetToDefault() async {
    _setLoading(true);
    
    try {
      await UserConfigService.resetToDefault();
      await _loadUserConfig();
      await _applyThemeSettings();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('重置失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 导出配置
  Map<String, dynamic> exportConfig() {
    return UserConfigService.exportUserConfig();
  }

  /// 导入配置
  Future<bool> importConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    
    try {
      final success = await UserConfigService.importUserConfig(data);
      if (success) {
        await _loadUserConfig();
        await _applyThemeSettings();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('导入配置失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 解析主题模式
  ThemeMode _parseThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 解析颜色
  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        colorString = colorString.substring(1);
      }
      
      if (colorString.length == 6) {
        colorString = 'FF$colorString'; // 添加alpha通道
      }
      
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return AppConstants.primaryColor; // 返回默认颜色
    }
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 显示错误对话框
  void showError(BuildContext context) {
    if (_errorMessage != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: Text(_errorMessage!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearError();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}