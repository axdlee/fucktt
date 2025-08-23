import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/ai_provider_model.dart';
import '../constants/app_constants.dart';
import 'app_card.dart';

/// AI服务提供商卡片组件
class AIProviderCard extends StatelessWidget {
  final AIProviderModel provider;
  final bool isHealthy;
  final bool isLoading;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTest;
  final Function(int)? onPriorityChanged;

  const AIProviderCard({
    super.key,
    required this.provider,
    required this.isHealthy,
    this.isLoading = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onTest,
    this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          _buildHeader(),
          
          SizedBox(height: 12.h),
          
          // 服务信息
          _buildServiceInfo(),
          
          if (provider.enabled) ...[
            SizedBox(height: 12.h),
            
            // 模型信息
            _buildModelsInfo(),
            
            SizedBox(height: 12.h),
            
            // 操作按钮
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Row(
      children: [
        // 服务商图标
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: _getProviderColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            _getProviderIcon(),
            color: _getProviderColor(),
            size: 24.sp,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // 服务商信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    provider.displayName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: provider.enabled 
                          ? AppConstants.textPrimaryColor 
                          : AppConstants.textTertiaryColor,
                    ),
                  ),
                  
                  SizedBox(width: 8.w),
                  
                  // 优先级标签
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '优先级 ${provider.priority}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 4.h),
              
              Row(
                children: [
                  // 状态指示器
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: provider.enabled 
                          ? (isHealthy ? AppConstants.successColor : AppConstants.errorColor)
                          : AppConstants.textTertiaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  SizedBox(width: 6.w),
                  
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  
                  if (isLoading) ...[
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: const CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // 启用开关
        Switch(
          value: provider.enabled,
          onChanged: (_) => onToggle?.call(),
          activeThumbColor: AppConstants.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  /// 构建服务信息
  Widget _buildServiceInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          _buildInfoRow('服务地址', _maskUrl(provider.baseUrl)),
          _buildInfoRow('API密钥', _maskApiKey(provider.apiKey)),
          if (provider.description != null)
            _buildInfoRow('描述', provider.description!),
          _buildInfoRow('创建时间', _formatDateTime(provider.createdAt)),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppConstants.textTertiaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模型信息
  Widget _buildModelsInfo() {
    if (provider.supportedModels.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppConstants.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: AppConstants.warningColor,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '暂无支持的模型',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.warningColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支持的模型 (${provider.supportedModels.length})',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Wrap(
          spacing: 6.w,
          runSpacing: 4.h,
          children: provider.supportedModels.take(4).map((model) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                model.displayName,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppConstants.primaryColor,
                ),
              ),
            );
          }).toList(),
        ),
        
        if (provider.supportedModels.length > 4)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              '还有 ${provider.supportedModels.length - 4} 个模型...',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppConstants.textTertiaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Row(
      children: [
        // 测试连接
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTest,
            icon: Icon(Icons.speed, size: 16.sp),
            label: const Text('测试'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              side: BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
        
        SizedBox(width: 8.w),
        
        // 编辑
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 16.sp),
            label: const Text('编辑'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              side: BorderSide(color: AppConstants.textTertiaryColor),
            ),
          ),
        ),
        
        SizedBox(width: 8.w),
        
        // 更多操作
        PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, action),
          icon: Icon(
            Icons.more_horiz,
            color: AppConstants.textSecondaryColor,
            size: 20.sp,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'priority',
              child: Row(
                children: [
                  Icon(Icons.low_priority),
                  SizedBox(width: 8),
                  Text('调整优先级'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'models',
              child: Row(
                children: [
                  Icon(Icons.model_training),
                  SizedBox(width: 8),
                  Text('查看模型'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 处理操作
  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'priority':
        _showPriorityDialog(context);
        break;
      case 'models':
        _showModelsDialog(context);
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  /// 显示优先级调整对话框
  void _showPriorityDialog(BuildContext context) {
    int currentPriority = provider.priority;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('调整优先级'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前优先级：$currentPriority'),
              SizedBox(height: 16.h),
              Slider(
                value: currentPriority.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: currentPriority.toString(),
                onChanged: (value) {
                  setState(() {
                    currentPriority = value.toInt();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('低优先级', style: TextStyle(fontSize: 12.sp)),
                  Text('高优先级', style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onPriorityChanged?.call(currentPriority);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示模型列表对话框
  void _showModelsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${provider.displayName} 支持的模型'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.supportedModels.length,
            itemBuilder: (context, index) {
              final model = provider.supportedModels[index];
              return ListTile(
                leading: Icon(
                  Icons.model_training,
                  color: AppConstants.primaryColor,
                  size: 20.sp,
                ),
                title: Text(
                  model.displayName,
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  model.modelId,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 获取服务商图标
  IconData _getProviderIcon() {
    switch (provider.name.toLowerCase()) {
      case 'openai':
        return Icons.psychology;
      case 'deepseek':
        return Icons.memory;
      case 'anthropic':
        return Icons.android;
      case 'google':
        return Icons.search;
      case 'alibaba':
        return Icons.cloud;
      case 'baidu':
        return Icons.translate;
      default:
        return Icons.smart_toy;
    }
  }

  /// 获取服务商颜色
  Color _getProviderColor() {
    switch (provider.name.toLowerCase()) {
      case 'openai':
        return const Color(0xFF10A37F);
      case 'deepseek':
        return const Color(0xFF3B82F6);
      case 'anthropic':
        return const Color(0xFFDB4444);
      case 'google':
        return const Color(0xFF4285F4);
      case 'alibaba':
        return const Color(0xFFFF6A00);
      case 'baidu':
        return const Color(0xFF2932E1);
      default:
        return AppConstants.primaryColor;
    }
  }

  /// 获取状态文本
  String _getStatusText() {
    if (!provider.enabled) {
      return '已禁用';
    } else if (isHealthy) {
      return '连接正常';
    } else {
      return '连接异常';
    }
  }

  /// 遮罩URL
  String _maskUrl(String url) {
    if (url.length <= 30) {
      return url;
    }
    return '${url.substring(0, 15)}...${url.substring(url.length - 10)}';
  }

  /// 遮罩API密钥
  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) {
      return '*' * apiKey.length;
    }
    return '${apiKey.substring(0, 4)}${'*' * (apiKey.length - 8)}${apiKey.substring(apiKey.length - 4)}';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}