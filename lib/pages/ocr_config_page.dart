import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/ocr_service_manager.dart';
import '../services/chinese_ocr_service.dart';
import '../widgets/app_card.dart';
import '../constants/app_constants.dart';

/// 📱 OCR服务配置页面
/// 显示当前OCR服务状态，允许用户切换服务
class OCRConfigPage extends StatefulWidget {
  const OCRConfigPage({super.key});

  @override
  State<OCRConfigPage> createState() => _OCRConfigPageState();
}

class _OCRConfigPageState extends State<OCRConfigPage> {
  final OCRServiceManager _ocrManager = OCRServiceManager.instance;
  OCRServiceStatus? _status;
  OCRRecommendation? _recommendation;
  Map<String, bool>? _serviceTests;
  bool _isLoading = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _initializeAndCheckServices();
  }

  Future<void> _initializeAndCheckServices() async {
    setState(() => _isLoading = true);
    
    try {
      // 初始化OCR服务管理器
      await _ocrManager.initialize();
      
      // 获取状态和推荐
      _status = _ocrManager.getStatus();
      _recommendation = _ocrManager.getRecommendation();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('OCR服务初始化失败: $e');
    }
  }

  Future<void> _testAllServices() async {
    setState(() => _isTesting = true);
    
    try {
      _serviceTests = await _ocrManager.testAllServices();
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 所有OCR服务测试完成'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      _showError('服务测试失败: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR服务配置'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _isTesting ? null : _testAllServices,
            icon: _isTesting 
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.speed),
            tooltip: '测试所有服务',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 当前状态概览
                _buildStatusOverview(),
                SizedBox(height: 24.h),
                
                // 国内使用建议
                _buildChinaRecommendation(),
                SizedBox(height: 24.h),
                
                // OCR策略选择
                _buildStrategySelection(),
                SizedBox(height: 24.h),
                
                // 服务商状态
                _buildServiceProviders(),
                SizedBox(height: 24.h),
                
                // 服务测试结果
                if (_serviceTests != null) _buildTestResults(),
              ],
            ),
          ),
    );
  }

  /// 构建状态概览
  Widget _buildStatusOverview() {
    if (_status == null) return const SizedBox.shrink();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'OCR服务状态',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          _buildStatusItem(
            '📊 整体状态',
            _status!.statusSummary,
            _status!.hasAnyService ? AppConstants.successColor : AppConstants.errorColor,
          ),
          
          _buildStatusItem(
            '🌍 环境检测',
            _status!.isInChina ? '中国大陆' : '海外',
            _status!.isInChina ? AppConstants.warningColor : AppConstants.primaryColor,
          ),
          
          _buildStatusItem(
            '🎯 当前策略',
            _status!.currentStrategy.displayName,
            AppConstants.primaryColor,
          ),
          
          _buildStatusItem(
            '🤖 Google ML Kit',
            _status!.googleMLKitAvailable ? '可用' : '不可用',
            _status!.googleMLKitAvailable ? AppConstants.successColor : AppConstants.errorColor,
          ),
          
          _buildStatusItem(
            '🇨🇳 国产OCR',
            _status!.chineseOCRAvailable ? '可用' : '不可用',
            _status!.chineseOCRAvailable ? AppConstants.successColor : AppConstants.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建中国大陆使用建议
  Widget _buildChinaRecommendation() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.warningColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '国内使用建议',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppConstants.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppConstants.warningColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Google ML Kit在国内的问题：',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.warningColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 需要Google Play服务支持\n'
                  '• 模型下载可能失败\n'
                  '• 网络连接不稳定\n'
                  '• 部分国产手机不兼容',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppConstants.successColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ 推荐使用国产OCR服务：',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.successColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 百度OCR - 免费额度充足，识别准确\n'
                  '• 腾讯OCR - 企业级稳定性\n'
                  '• 阿里云OCR - 速度快，API丰富\n'
                  '• 科大讯飞OCR - 本土化程度高',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建策略选择
  Widget _buildStrategySelection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'OCR策略选择',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          ...OCRStrategy.values.map((strategy) {
            final isSelected = _status?.currentStrategy == strategy;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : null,
              child: ListTile(
                leading: Radio<OCRStrategy>(
                  value: strategy,
                  groupValue: _status?.currentStrategy,
                  onChanged: (value) {
                    if (value != null) {
                      _ocrManager.setStrategy(value);
                      setState(() {
                        _status = _ocrManager.getStatus();
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ 已切换到: ${strategy.displayName}'),
                          backgroundColor: AppConstants.successColor,
                        ),
                      );
                    }
                  },
                ),
                title: Text(
                  strategy.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _getStrategyDescription(strategy),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getStrategyDescription(OCRStrategy strategy) {
    switch (strategy) {
      case OCRStrategy.googleOnly:
        return '仅使用Google ML Kit，需要Google Play服务';
      case OCRStrategy.chineseOnly:
        return '仅使用国产OCR，适合中国大陆用户';
      case OCRStrategy.googleFirst:
        return 'Google优先，失败时使用国产OCR备用';
      case OCRStrategy.chineseFirst:
        return '国产OCR优先，失败时使用Google备用';
      case OCRStrategy.auto:
        return '自动选择最佳方案，根据环境智能切换';
    }
  }

  /// 构建服务商状态
  Widget _buildServiceProviders() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_queue,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '服务提供商',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          _buildProviderItem(
            'Google ML Kit',
            '🤖 免费离线识别',
            _status?.googleMLKitAvailable ?? false,
            '需要Google Play服务支持',
          ),
          
          _buildProviderItem(
            '百度OCR',
            '🇨🇳 每月免费1000次',
            true, // 假设已配置
            '中文识别效果好，免费额度充足',
          ),
          
          _buildProviderItem(
            '腾讯OCR',
            '🏢 企业级服务',
            true, // 假设已配置
            '稳定性好，适合大规模使用',
          ),
          
          _buildProviderItem(
            '阿里云OCR',
            '⚡ 识别速度快',
            true, // 假设已配置
            'API丰富，功能全面',
          ),
        ],
      ),
    );
  }

  Widget _buildProviderItem(String name, String description, bool available, String note) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: available ? AppConstants.successColor.withOpacity(0.05) : AppConstants.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: available ? AppConstants.successColor.withOpacity(0.2) : AppConstants.errorColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                available ? Icons.check_circle : Icons.error,
                color: available ? AppConstants.successColor : AppConstants.errorColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                available ? '可用' : '不可用',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: available ? AppConstants.successColor : AppConstants.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            note,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppConstants.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建测试结果
  Widget _buildTestResults() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '服务测试结果',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          ..._serviceTests!.entries.map((entry) {
            final isAvailable = entry.value;
            return ListTile(
              leading: Icon(
                isAvailable ? Icons.check_circle : Icons.error,
                color: isAvailable ? AppConstants.successColor : AppConstants.errorColor,
              ),
              title: Text(entry.key),
              trailing: Text(
                isAvailable ? '✅ 通过' : '❌ 失败',
                style: TextStyle(
                  color: isAvailable ? AppConstants.successColor : AppConstants.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}