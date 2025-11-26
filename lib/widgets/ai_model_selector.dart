import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/ai_provider_model.dart';
import '../providers/ai_provider.dart';
import '../constants/app_constants.dart';

/// 增强的AI模型选择器组件 - 支持动态获取模型列表和自定义配置
class AIModelSelector extends StatefulWidget {
  final String? selectedProviderId;
  final String? selectedModelId;
  final Function(String? providerId, String? modelId)? onModelChanged;
  final bool enabled;
  final bool allowCustomModel;
  final bool showModelRefresh;

  const AIModelSelector({
    super.key,
    this.selectedProviderId,
    this.selectedModelId,
    this.onModelChanged,
    this.enabled = true,
    this.allowCustomModel = true,
    this.showModelRefresh = true,
  });

  @override
  State<AIModelSelector> createState() => _AIModelSelectorState();
}

class _AIModelSelectorState extends State<AIModelSelector> {
  String? _selectedProviderId;
  String? _selectedModelId;
  List<ModelConfig> _availableModels = [];
  bool _isLoadingModels = false;
  bool _isCustomModel = false;
  final TextEditingController _customModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProviderId = widget.selectedProviderId;
    _selectedModelId = widget.selectedModelId;
    
    if (_selectedModelId != null) {
      _customModelController.text = _selectedModelId!;
    }
    
    // 如果有选中的provider，立即加载模型
    if (_selectedProviderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadModelsForProvider(_selectedProviderId!);
      });
    }
  }

  @override
  void didUpdateWidget(AIModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProviderId != oldWidget.selectedProviderId) {
      _selectedProviderId = widget.selectedProviderId;
      if (_selectedProviderId != null) {
        _loadModelsForProvider(_selectedProviderId!);
      }
    }
    if (widget.selectedModelId != oldWidget.selectedModelId) {
      _selectedModelId = widget.selectedModelId;
      if (_selectedModelId != null) {
        _customModelController.text = _selectedModelId!;
      }
    }
  }

  @override
  void dispose() {
    _customModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        final healthyProviders = aiProvider.healthyProviders;
        
        if (healthyProviders.isEmpty) {
          return _buildEmptyState();
        }

        // 如果没有选中的提供商，默认选择第一个
        if (_selectedProviderId == null || 
            !healthyProviders.any((p) => p.id == _selectedProviderId)) {
          _selectedProviderId = healthyProviders.first.id;
          // 立即加载模型
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadModelsForProvider(_selectedProviderId!);
          });
        }

        final selectedProvider = healthyProviders
            .where((p) => p.id == _selectedProviderId)
            .firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI服务提供商选择
            _buildProviderSelector(healthyProviders),
            SizedBox(height: 12.h),

            // AI模型选择
            if (selectedProvider != null) ...[
              _buildModelSelector(selectedProvider),
              SizedBox(height: 8.h),

              // 模型信息显示
              if (_selectedModelId != null || _isCustomModel) ...[
                _buildModelInfo(),
              ],
            ],
          ],
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
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

  /// 构建服务提供商选择器
  Widget _buildProviderSelector(List<AIProviderModel> providers) {
    return Container(
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
          items: providers.map((provider) {
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
              _isCustomModel = false;
              _availableModels.clear();
            });
            if (value != null) {
              _loadModelsForProvider(value);
            }
            _notifyChange();
          } : null,
        ),
      ),
    );
  }

  /// 构建模型选择器
  Widget _buildModelSelector(AIProviderModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'AI模型',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),
            if (widget.showModelRefresh) ...[
              IconButton(
                onPressed: _isLoadingModels ? null : () => _refreshModels(provider),
                icon: _isLoadingModels 
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, size: 16.sp),
                tooltip: '刷新模型列表',
              ),
            ],
            if (widget.allowCustomModel) ...[
              IconButton(
                onPressed: () => _toggleCustomModel(),
                icon: Icon(
                  _isCustomModel ? Icons.list : Icons.edit,
                  size: 16.sp,
                  color: _isCustomModel ? AppConstants.primaryColor : null,
                ),
                tooltip: _isCustomModel ? '选择预设模型' : '自定义模型',
              ),
            ],
          ],
        ),
        
        SizedBox(height: 8.h),
        
        if (_isCustomModel) ...[
          _buildCustomModelInput(),
        ] else ...[
          _buildModelDropdown(provider),
        ],
      ],
    );
  }

  /// 构建模型下拉选择
  Widget _buildModelDropdown(AIProviderModel provider) {
    final models = _availableModels.isNotEmpty 
        ? _availableModels 
        : _getDefaultModelsForProvider(provider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _getValidModelId(models),
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          hint: Text(
            _isLoadingModels ? '正在加载模型...' : '选择AI模型',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          items: models.map((model) {
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
          }).toList(),
          onChanged: widget.enabled && !_isLoadingModels ? (value) {
            setState(() {
              _selectedModelId = value;
              _customModelController.text = value ?? '';
            });
            _notifyChange();
          } : null,
        ),
      ),
    );
  }

  /// 构建自定义模型输入
  Widget _buildCustomModelInput() {
    return TextFormField(
      controller: _customModelController,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: '输入自定义模型名称，如：gpt-4o、claude-3-5-sonnet',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        suffixIcon: IconButton(
          onPressed: () {
            _customModelController.clear();
            setState(() {
              _selectedModelId = null;
            });
            _notifyChange();
          },
          icon: Icon(Icons.clear, size: 16.sp),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _selectedModelId = value.isNotEmpty ? value : null;
        });
        _notifyChange();
      },
    );
  }

  /// 构建模型信息
  Widget _buildModelInfo() {
    return Container(
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
              '当前选择: ${_selectedModelId ?? '未选择'}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          if (_isCustomModel) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppConstants.warningColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '自定义',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppConstants.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 加载服务商的模型列表
  Future<void> _loadModelsForProvider(String providerId) async {
    if (_isLoadingModels) return;
    
    setState(() {
      _isLoadingModels = true;
    });

    try {
      final aiProvider = context.read<AIProvider>();
      final provider = aiProvider.providers
          .where((p) => p.id == providerId)
          .firstOrNull;
      
      if (provider == null) return;

      // 尝试从API获取模型列表
      final service = aiProvider.getServiceForProvider(providerId);
      if (service != null) {
        try {
          final models = await service.getAvailableModels();
          if (models.isNotEmpty) {
            setState(() {
              _availableModels = models;
            });
            return;
          }
        } catch (e) {
          log('获取模型列表失败: $e');
        }
      }

      // 如果API获取失败，使用预配置的模型
      final defaultModels = _getDefaultModelsForProvider(provider);
      setState(() {
        _availableModels = defaultModels;
      });
      
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  /// 刷新模型列表
  Future<void> _refreshModels(AIProviderModel provider) async {
    setState(() {
      _availableModels.clear();
    });
    await _loadModelsForProvider(provider.id);
  }

  /// 切换自定义模型模式
  void _toggleCustomModel() {
    setState(() {
      _isCustomModel = !_isCustomModel;
      if (_isCustomModel) {
        _customModelController.text = _selectedModelId ?? '';
      } else {
        // 从自定义模式切换回来时，尝试匹配已有模型
        final currentText = _customModelController.text;
        final matchedModel = _availableModels
            .where((m) => m.modelId == currentText)
            .firstOrNull;
        if (matchedModel != null) {
          _selectedModelId = matchedModel.modelId;
        }
      }
    });
  }

  /// 获取有效的模型ID
  String? _getValidModelId(List<ModelConfig> models) {
    if (_selectedModelId != null && 
        models.any((m) => m.modelId == _selectedModelId)) {
      return _selectedModelId;
    }
    
    // 如果当前选择的模型无效，选择第一个可用模型
    if (models.isNotEmpty) {
      _selectedModelId = models.first.modelId;
      return _selectedModelId;
    }
    
    return null;
  }

  /// 获取服务商的默认模型列表
  List<ModelConfig> _getDefaultModelsForProvider(AIProviderModel provider) {
    // 首先检查provider自身的配置模型
    if (provider.supportedModels.isNotEmpty) {
      return provider.supportedModels;
    }

    // 根据provider名称或URL返回默认模型
    final providerName = provider.name.toLowerCase();
    final baseUrl = provider.baseUrl.toLowerCase();

    if (baseUrl.contains('siliconflow')) {
      return [
        ModelConfig(
          modelId: 'deepseek-ai/DeepSeek-V2.5',
          displayName: 'DeepSeek-V2.5',
          description: '深度求索最新模型，综合能力强',
        ),
        ModelConfig(
          modelId: 'Qwen/Qwen2.5-7B-Instruct',
          displayName: 'Qwen2.5-7B',
          description: '阿里通义千问，高效实用',
        ),
        ModelConfig(
          modelId: 'meta-llama/Meta-Llama-3.1-8B-Instruct',
          displayName: 'Llama-3.1-8B',
          description: 'Meta开源模型，性能均衡',
        ),
      ];
    } else if (providerName.contains('openai') || baseUrl.contains('openai')) {
      return [
        ModelConfig(
          modelId: 'gpt-3.5-turbo',
          displayName: 'GPT-3.5 Turbo',
          description: 'OpenAI经典模型，速度快',
        ),
        ModelConfig(
          modelId: 'gpt-4o',
          displayName: 'GPT-4o',
          description: 'OpenAI最新多模态模型',
        ),
        ModelConfig(
          modelId: 'gpt-4',
          displayName: 'GPT-4',
          description: 'OpenAI强力模型，能力最佳',
        ),
      ];
    } else if (providerName.contains('deepseek') || baseUrl.contains('deepseek')) {
      return [
        ModelConfig(
          modelId: 'deepseek-chat',
          displayName: 'DeepSeek Chat',
          description: 'DeepSeek对话模型',
        ),
        ModelConfig(
          modelId: 'deepseek-coder',
          displayName: 'DeepSeek Coder',
          description: 'DeepSeek代码模型',
        ),
      ];
    } else if (providerName.contains('anthropic') || baseUrl.contains('anthropic')) {
      return [
        ModelConfig(
          modelId: 'claude-3-5-sonnet-20241022',
          displayName: 'Claude 3.5 Sonnet',
          description: 'Anthropic最新模型',
        ),
        ModelConfig(
          modelId: 'claude-3-haiku-20240307',
          displayName: 'Claude 3 Haiku',
          description: 'Anthropic快速模型',
        ),
      ];
    } else {
      // 通用默认模型
      return [
        ModelConfig(
          modelId: 'default',
          displayName: '默认模型',
          description: '服务商默认AI模型',
        ),
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