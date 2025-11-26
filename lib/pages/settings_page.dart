import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 外观设置
                _buildAppearanceSection(appProvider),

                SizedBox(height: 16.h),

                // 功能设置
                _buildFunctionalSection(appProvider),

                SizedBox(height: 16.h),

                // 隐私设置
                _buildPrivacySection(appProvider),

                SizedBox(height: 16.h),

                // 其他设置
                _buildOtherSection(appProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建外观设置区域
  Widget _buildAppearanceSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '外观设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 主题模式
          ListTile(
            leading: Icon(Icons.dark_mode_outlined, size: 20.sp),
            title: Text('主题模式', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text(_getThemeModeText(appProvider.themeMode),
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: DropdownButton<ThemeMode>(
              value: appProvider.themeMode,
              underline: const SizedBox(),
              onChanged: (mode) async {
                if (mode != null) {
                  await appProvider.setThemeMode(mode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('主题模式已设置为${_getThemeModeText(mode)}'),
                      backgroundColor: AppConstants.successColor,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('跟随系统', style: TextStyle(fontSize: 12.sp)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('浅色模式', style: TextStyle(fontSize: 12.sp)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('深色模式', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能设置区域
  Widget _buildFunctionalSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '功能设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 通知设置
          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined, size: 20.sp),
            title: Text('通知', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('接收应用通知和提醒',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableNotifications,
            onChanged: (value) async {
              await appProvider.toggleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启通知' : '已关闭通知'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 悬浮按钮
          SwitchListTile(
            secondary: Icon(Icons.touch_app_outlined, size: 20.sp),
            title: Text('悬浮按钮', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('显示应用悬浮操作按钮',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableFloatingButton,
            onChanged: (value) async {
              await appProvider.toggleFloatingButton();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启悬浮按钮' : '已关闭悬浮按钮'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 触觉反馈
          SwitchListTile(
            secondary: Icon(Icons.vibration_outlined, size: 20.sp),
            title: Text('触觉反馈', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('操作时提供触觉反馈',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableHapticFeedback,
            onChanged: (value) async {
              final newSettings =
                  appProvider.appSettings.copyWith(enableHapticFeedback: value);
              await appProvider.updateAppSettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启触觉反馈' : '已关闭触觉反馈'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 开机自启
          SwitchListTile(
            secondary: Icon(Icons.power_settings_new_outlined, size: 20.sp),
            title: Text('开机自启', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('系统启动时自动运行应用',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableAutoStart,
            onChanged: (value) async {
              final newSettings =
                  appProvider.appSettings.copyWith(enableAutoStart: value);
              await appProvider.updateAppSettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启开机自启' : '已关闭开机自启'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建隐私设置区域
  Widget _buildPrivacySection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '隐私设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 数据收集
          SwitchListTile(
            secondary: Icon(Icons.analytics_outlined, size: 20.sp),
            title: Text('数据收集', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('允许收集使用数据用于改进服务',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableDataCollection,
            onChanged: (value) async {
              final newSettings = appProvider.privacySettings
                  .copyWith(enableDataCollection: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已允许数据收集' : '已禁止数据收集'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 统计分析
          SwitchListTile(
            secondary: Icon(Icons.insights_outlined, size: 20.sp),
            title: Text('统计分析', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('允许发送匿名的使用统计数据',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableAnalytics,
            onChanged: (value) async {
              final newSettings =
                  appProvider.privacySettings.copyWith(enableAnalytics: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启统计分析' : '已关闭统计分析'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 崩溃报告
          SwitchListTile(
            secondary: Icon(Icons.bug_report_outlined, size: 20.sp),
            title: Text('崩溃报告', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('自动发送崩溃报告帮助改进应用',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableCrashReporting,
            onChanged: (value) async {
              final newSettings = appProvider.privacySettings
                  .copyWith(enableCrashReporting: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启崩溃报告' : '已关闭崩溃报告'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建其他设置区域
  Widget _buildOtherSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.more_horiz_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '其他',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 导出配置
          ListTile(
            leading: Icon(Icons.upload_outlined, size: 20.sp),
            title: Text('导出配置', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('将应用配置导出为文件',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _exportConfig(appProvider);
            },
          ),

          // 导入配置
          ListTile(
            leading: Icon(Icons.download_outlined, size: 20.sp),
            title: Text('导入配置', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('从文件导入应用配置',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _importConfig(appProvider);
            },
          ),

          // 重置设置
          ListTile(
            leading: Icon(Icons.restore_outlined,
                size: 20.sp, color: AppConstants.errorColor),
            title: Text('重置设置',
                style:
                    TextStyle(fontSize: 14.sp, color: AppConstants.errorColor)),
            subtitle: Text('恢复所有设置为默认值',
                style: TextStyle(
                    fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _showResetDialog(appProvider);
            },
          ),
        ],
      ),
    );
  }

  /// 获取主题模式文本
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  /// 导出配置
  void _exportConfig(AppProvider appProvider) async {
    try {
      final config = appProvider.exportConfig();

      // 显示导出成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置导出成功'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败：$e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  /// 导入配置
  void _importConfig(AppProvider appProvider) async {
    // 这里应该实现文件选择和导入逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中，敬请期待'),
        backgroundColor: AppConstants.infoColor,
      ),
    );
  }

  /// 显示重置对话框
  void _showResetDialog(AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('这将恢复所有设置为默认值，操作不可撤销。是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await appProvider.resetToDefault();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('重置成功'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('重置失败：$e'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            child: const Text('确定',
                style: TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
  }
}