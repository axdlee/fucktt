import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/ai_provider_model.dart';
import '../providers/ai_provider.dart';
import '../constants/app_constants.dart';

/// AI模型选择器组件
class AIModelSelector extends StatefulWidget {
  final String? selectedProviderId;
  final String? selectedModelId;
  final Function(String? providerId, String? modelId)? onModelChanged;
  final bool enabled;

  const AIModelSelector({
    super.key,
    this.selectedProviderId,
    this.selectedModelId,
    this.onModelChanged,
    this.enabled = true,
  });

  @override
  State<AIModelSelector> createState() => _AIModelSelectorState();
}

class _AIModelSelectorState extends State<AIModelSelector> {
  String? _selectedProviderId;
  String? _selectedModelId;

  @override
  void initState() {
    super.initState();
    _selectedProviderId = widget.selectedProviderId;
    _selectedModelId = widget.selectedModelId;
  }

  @override
  void didUpdateWidget(AIModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProviderId != oldWidget.selectedProviderId) {
      _selectedProviderId = widget.selectedProviderId;
    }
    if (widget.selectedModelId != oldWidget.selectedModelId) {
      _selectedModelId = widget.selectedModelId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        final healthyProviders = aiProvider.healthyProviders;
        
        if (healthyProviders.isEmpty) {
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AppConstants.errorColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '暂无可用的AI服务',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppConstants.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 如果没有选中的提供商，默认选择第一个
        if (_selectedProviderId == null || 
            !healthyProviders.any((p) => p.id == _selectedProviderId)) {
          _selectedProviderId = healthyProviders.first.id;
        }

        final selectedProvider = healthyProviders
            .where((p) => p.id == _selectedProviderId)
            .firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI服务提供商选择
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProviderId,
                  isExpanded: true,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  hint: Text(
                    '选择AI服务',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  items: healthyProviders.map((provider) {
                    return DropdownMenuItem<String>(
                      value: provider.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppConstants.successColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              provider.displayName,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: widget.enabled ? (value) {
                    setState(() {
                      _selectedProviderId = value;
                      _selectedModelId = null; // 重置模型选择
                    });
                    _notifyChange();
                  } : null,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // AI模型选择
            if (selectedProvider != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _getValidModelId(selectedProvider),
                    isExpanded: true,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    hint: Text(
                      '选择AI模型',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    items: _buildModelItems(selectedProvider),
                    onChanged: widget.enabled ? (value) {
                      setState(() {
                        _selectedModelId = value;
                      });
                      _notifyChange();
                    } : null,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // 模型信息显示
              if (_selectedModelId != null) ...[
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppConstants.primaryColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          '当前选择: $_selectedModelId',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  /// 获取有效的模型ID
  String? _getValidModelId(AIProviderModel provider) {
    if (_selectedModelId != null && 
        provider.supportedModels.any((m) => m.modelId == _selectedModelId)) {
      return _selectedModelId;
    }
    
    // 如果当前选择的模型无效，选择第一个可用模型
    if (provider.supportedModels.isNotEmpty) {
      _selectedModelId = provider.supportedModels.first.modelId;
      return _selectedModelId;
    }
    
    return null;
  }

  /// 构建模型选择项
  List<DropdownMenuItem<String>> _buildModelItems(AIProviderModel provider) {
    if (provider.supportedModels.isEmpty) {
      // 如果没有预定义模型，使用默认模型
      final defaultModels = _getDefaultModelsForProvider(provider);
      return defaultModels.map((model) {
        return DropdownMenuItem<String>(
          value: model['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model['name']!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (model['description'] != null)
                Text(
                  model['description']!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
            ],
          ),
        );
      }).toList();
    }

    return provider.supportedModels.map((model) {
      return DropdownMenuItem<String>(
        value: model.modelId,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.displayName.isNotEmpty ? model.displayName : model.modelId,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (model.description != null && model.description!.isNotEmpty)
              Text(
                model.description!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  /// 获取服务商的默认模型列表
  List<Map<String, String?>> _getDefaultModelsForProvider(AIProviderModel provider) {
    if (provider.baseUrl.contains('siliconflow')) {
      return [
        {
          'id': 'deepseek-ai/DeepSeek-V2.5',
          'name': 'DeepSeek-V2.5',
          'description': '深度求索最新模型，综合能力强',
        },
        {
          'id': 'Qwen/Qwen2.5-7B-Instruct',
          'name': 'Qwen2.5-7B',
          'description': '阿里通义千问，高效实用',
        },
        {
          'id': 'meta-llama/Meta-Llama-3.1-8B-Instruct',
          'name': 'Llama-3.1-8B',
          'description': 'Meta开源模型，性能均衡',
        },
      ];
    } else if (provider.name.toLowerCase().contains('openai')) {
      return [
        {
          'id': 'gpt-3.5-turbo',
          'name': 'GPT-3.5 Turbo',
          'description': 'OpenAI经典模型，速度快',
        },
        {
          'id': 'gpt-4',
          'name': 'GPT-4',
          'description': 'OpenAI最强模型，能力最佳',
        },
      ];
    } else {
      return [
        {
          'id': 'default',
          'name': '默认模型',
          'description': '系统默认AI模型',
        },
      ];
    }
  }

  /// 通知变化
  void _notifyChange() {
    if (widget.onModelChanged != null) {
      widget.onModelChanged!(_selectedProviderId, _selectedModelId);
    }
  }
}

extension on List<AIProviderModel> {
  AIProviderModel? get firstOrNull => isEmpty ? null : first;
}