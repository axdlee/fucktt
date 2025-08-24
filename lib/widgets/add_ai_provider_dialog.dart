import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/ai_provider_model.dart';
import '../providers/ai_provider.dart';
import '../constants/app_constants.dart';
import '../services/openai_compatible_service.dart';
import 'ai_model_selector.dart';

/// 添加AI服务提供商对话框
class AddAIProviderDialog extends StatefulWidget {
  final AIProviderModel? editProvider; // 编辑模式下的提供商
  
  const AddAIProviderDialog({super.key, this.editProvider});

  @override
  State<AddAIProviderDialog> createState() => _AddAIProviderDialogState();
}

class _AddAIProviderDialogState extends State<AddAIProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedProvider = '';
  int _priority = 1;
  bool _isTesting = false;
  bool _isPasswordVisible = false;
  bool get _isEditMode => widget.editProvider != null;
  
  // 模型选择相关状态
  String? _selectedModelId;
  List<ModelConfig> _availableModels = [];
  bool _isLoadingModels = false;
  bool _showModelSelector = false;

  @override
  void initState() {
    super.initState();
    
    // 确保_selectedProvider的初始值是有效的
    final supportedProviders = AppConstants.supportedAIProviders.keys.toList();
    _selectedProvider = supportedProviders.isNotEmpty ? supportedProviders.first : 'openai';
    
    if (_isEditMode) {
      _initForEdit();
    } else {
      _updateProviderDefaults();
    }
  }
  
  void _initForEdit() {
    final provider = widget.editProvider!;
    _nameController.text = provider.displayName;
    _apiKeyController.text = provider.apiKey;
    _baseUrlController.text = provider.baseUrl;
    _descriptionController.text = provider.description ?? '';
    
    // 确保 provider.name 在支持列表中
    final providerName = provider.name.toLowerCase();
    if (AppConstants.supportedAIProviders.containsKey(providerName)) {
      _selectedProvider = providerName;
    } else {
      // 如果不在支持列表中，使用custom或第一个可用的
      _selectedProvider = AppConstants.supportedAIProviders.containsKey('custom') 
          ? 'custom' 
          : AppConstants.supportedAIProviders.keys.first;
    }
    
    // 确保优先级值在有效范围内（1-10）
    _priority = provider.priority.clamp(1, 10);
    
    // 编辑模式下，如果有API密钥和基础URL，显示模型选择器
    if (_apiKeyController.text.trim().isNotEmpty && _baseUrlController.text.trim().isNotEmpty) {
      _showModelSelector = true;
      // 延迟加载模型列表
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAvailableModels();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _descriptionController.dispose();
    _loadModelsTimer?.cancel(); // 清理定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            _buildTitleBar(),
            
            // 表单内容
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 服务商选择
                      _buildProviderSelector(),
                      
                      SizedBox(height: 16.h),
                      
                      // 显示名称
                      _buildTextField(
                        controller: _nameController,
                        label: '显示名称',
                        hint: '例如：我的OpenAI服务',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入显示名称';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // API密钥
                      _buildTextField(
                        controller: _apiKeyController,
                        label: 'API密钥',
                        hint: '请输入您的API密钥',
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入API密钥';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // API密钥变化时，自动拉取模型列表
                          if (value.trim().isNotEmpty && _baseUrlController.text.trim().isNotEmpty) {
                            setState(() {
                              _showModelSelector = true;
                            });
                            _loadModelsAfterDelay();
                          } else {
                            setState(() {
                              _showModelSelector = value.trim().isNotEmpty && _baseUrlController.text.trim().isNotEmpty;
                            });
                          }
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 基础URL
                      _buildTextField(
                        controller: _baseUrlController,
                        label: '基础URL',
                        hint: 'API服务的基础URL地址',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入基础URL';
                          }
                          final parsedUri = Uri.tryParse(value);
                          if (parsedUri == null || !parsedUri.isAbsolute) {
                            return '请输入有效的URL地址';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // 基础URL变化时，自动拉取模型列表
                          if (value.trim().isNotEmpty && _apiKeyController.text.trim().isNotEmpty) {
                            setState(() {
                              _showModelSelector = true;
                            });
                            _loadModelsAfterDelay();
                          } else {
                            setState(() {
                              _showModelSelector = value.trim().isNotEmpty && _apiKeyController.text.trim().isNotEmpty;
                            });
                          }
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 模型选择器
                      if (_showModelSelector) ...[
                        _buildModelSelector(),
                        SizedBox(height: 16.h),
                      ],
                      
                      SizedBox(height: 16.h),
                      
                      // 优先级
                      _buildPrioritySlider(),
                      
                      SizedBox(height: 16.h),
                      
                      // 描述
                      _buildTextField(
                        controller: _descriptionController,
                        label: '描述（可选）',
                        hint: '简要描述这个AI服务的用途',
                        maxLines: 2,
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // 操作按钮
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标题栏
  Widget _buildTitleBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            _isEditMode ? '编辑AI服务' : '添加AI服务',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 构建服务商选择器
  Widget _buildProviderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI服务商',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppConstants.dividerColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButton<String>(
            value: _selectedProvider,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedProvider = value;
                  // 重置模型选择状态
                  _selectedModelId = null;
                  _availableModels.clear();
                  _showModelSelector = false;
                });
                _updateProviderDefaults();
              }
            },
            items: AppConstants.supportedAIProviders.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(
                      _getProviderIcon(entry.key),
                      color: _getProviderColor(entry.key),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppConstants.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppConstants.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            suffixIcon: obscureText 
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// 构建优先级滑块
  Widget _buildPrioritySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '优先级',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            Text(
              '优先级 $_priority',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppConstants.primaryColor,
            inactiveTrackColor: AppConstants.primaryColor.withValues(alpha: 0.2),
            thumbColor: AppConstants.primaryColor,
            overlayColor: AppConstants.primaryColor.withValues(alpha: 0.1),
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
          ),
          child: Slider(
            value: _priority.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _priority = value.toInt();
              });
            },
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '低优先级',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
            Text(
              '高优先级',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 测试连接按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isTesting ? null : _testConnection,
            icon: _isTesting 
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.speed, size: 16.sp),
            label: Text(_isTesting ? '测试中...' : '测试连接'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // 底部按钮组
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: AppConstants.dividerColor),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            Expanded(
              child: ElevatedButton(
                onPressed: _addProvider,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  '添加',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 更新服务商默认值
  void _updateProviderDefaults() {
    final defaults = _getProviderDefaults(_selectedProvider);
    _nameController.text = defaults['name'] ?? '';
    _baseUrlController.text = defaults['baseUrl'] ?? '';
    _descriptionController.text = defaults['description'] ?? '';
    
    // 如果基础URL不为空，设置显示模型选择器（不调用setState）
    if (_baseUrlController.text.trim().isNotEmpty) {
      _showModelSelector = true;
    }
  }

  /// 获取服务商默认配置
  Map<String, String> _getProviderDefaults(String provider) {
    switch (provider) {
      case 'openai':
        return {
          'name': 'OpenAI',
          'baseUrl': 'https://api.openai.com/v1',
          'description': 'OpenAI官方API服务',
        };
      case 'deepseek':
        return {
          'name': 'DeepSeek',
          'baseUrl': 'https://api.deepseek.com/v1',
          'description': 'DeepSeek AI服务',
        };
      case 'anthropic':
        return {
          'name': 'Anthropic Claude',
          'baseUrl': 'https://api.anthropic.com',
          'description': 'Anthropic Claude AI服务',
        };
      case 'google':
        return {
          'name': 'Google Gemini',
          'baseUrl': 'https://generativelanguage.googleapis.com/v1',
          'description': 'Google Gemini AI服务',
        };
      case 'alibaba':
        return {
          'name': '通义千问',
          'baseUrl': 'https://dashscope.aliyuncs.com/api/v1',
          'description': '阿里云通义千问服务',
        };
      case 'siliconflow':
        return {
          'name': 'SiliconFlow',
          'baseUrl': 'https://api.siliconflow.cn/v1',
          'description': 'SiliconFlow AI服务平台',
        };
      case 'baidu':
        return {
          'name': '文心一言',
          'baseUrl': 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1',
          'description': '百度文心一言服务',
        };
      default:
        return {
          'name': '自定义AI服务',
          'baseUrl': '',
          'description': '自定义AI服务接口',
        };
    }
  }

  /// 获取服务商图标
  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'openai':
        return Icons.psychology;
      case 'deepseek':
        return Icons.memory;
      case 'siliconflow':
        return Icons.computer;
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
  Color _getProviderColor(String provider) {
    switch (provider) {
      case 'openai':
        return const Color(0xFF10A37F);
      case 'deepseek':
        return const Color(0xFF3B82F6);
      case 'siliconflow':
        return const Color(0xFF8B5CF6);
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

  /// 构建模型选择器
  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'AI模型选择',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),
            IconButton(
              onPressed: _isLoadingModels ? null : _loadAvailableModels,
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
        ),
        
        SizedBox(height: 8.h),
        
        if (_availableModels.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModelId,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                hint: Text(
                  '选择AI模型（可选）',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                items: _availableModels.map((model) {
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
                onChanged: (value) {
                  setState(() {
                    _selectedModelId = value;
                  });
                },
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppConstants.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppConstants.warningColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.warningColor,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '请填写API密钥和基础URL后，点击刷新按钮获取模型列表',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppConstants.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 延迟加载模型列表（避免频繁请求）
  Timer? _loadModelsTimer;
  void _loadModelsAfterDelay() {
    _loadModelsTimer?.cancel();
    _loadModelsTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadAvailableModels();
      }
    });
  }

  /// 加载可用模型列表
  Future<void> _loadAvailableModels() async {
    final apiKey = _apiKeyController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    
    if (apiKey.isEmpty || baseUrl.isEmpty) {
      setState(() {
        _showModelSelector = false;
        _availableModels.clear();
        _selectedModelId = null;
      });
      return;
    }

    setState(() {
      _isLoadingModels = true;
      _showModelSelector = true;
    });

    try {
      // 直接创建临时的AI服务来获取模型列表
      final tempProvider = AIProviderModel(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
        name: _selectedProvider,
        displayName: 'Temporary Provider',
        baseUrl: baseUrl,
        apiKey: apiKey,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 直接创建OpenAI兼容服务
      final tempService = OpenAICompatibleService(tempProvider);
      
      print('🔍 开始获取模型列表: ${tempProvider.baseUrl}');
      final models = await tempService.getAvailableModels();
      print('✅ 成功获取${models.length}个模型');
      
      if (mounted) {
        setState(() {
          _availableModels = models;
          // 如果当前选中的模型不在列表中，清空选择
          if (_selectedModelId != null && 
              !models.any((m) => m.modelId == _selectedModelId)) {
            _selectedModelId = null;
          }
        });
        
        // 显示成功消息
        if (models.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功获取${models.length}个可用模型'),
              backgroundColor: AppConstants.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      // 清理临时服务
      tempService.dispose();
      
    } catch (e) {
      print('❌ 获取模型列表失败: $e');
      if (mounted) {
        setState(() {
          _availableModels.clear();
          _selectedModelId = null;
        });
        
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取模型列表失败: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
        });
      }
    }
  }

  /// 测试连接
  void _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTesting = true;
    });

    try {
      final aiProvider = context.read<AIProvider>();
      
      // 创建临时的AI服务提供商进行测试
      AIProviderModel tempProvider;
      
      switch (_selectedProvider) {
        case 'openai':
          tempProvider = aiProvider.createOpenAIProvider(
            apiKey: _apiKeyController.text.trim(),
            baseUrl: _baseUrlController.text.trim(),
          );
          break;
        case 'deepseek':
          tempProvider = aiProvider.createDeepSeekProvider(
            apiKey: _apiKeyController.text.trim(),
            baseUrl: _baseUrlController.text.trim(),
          );
          break;
        default:
          // 对于其他类型，使用通用创建方法
          tempProvider = aiProvider.createCustomProvider(
            name: _selectedProvider,
            displayName: _nameController.text.trim(),
            apiKey: _apiKeyController.text.trim(),
            baseUrl: _baseUrlController.text.trim(),
            description: _descriptionController.text.trim(),
          );
          break;
      }
      
      final result = await aiProvider.testProvider(tempProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? '连接测试成功！' : '连接测试失败，请检查配置信息。'),
            backgroundColor: result ? AppConstants.successColor : AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试失败：$e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  /// 添加服务提供商
  void _addProvider() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final aiProvider = context.read<AIProvider>();
    
    try {
      AIProviderModel provider;
      
      if (_isEditMode) {
        // 编辑模式：更新现有提供商
        provider = widget.editProvider!.copyWith(
          displayName: _nameController.text.trim(),
          apiKey: _apiKeyController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          priority: _priority,
          // 如果选择了模型，更新支持的模型列表
          supportedModels: _selectedModelId != null 
              ? [ModelConfig(
                  modelId: _selectedModelId!,
                  displayName: _availableModels
                      .where((m) => m.modelId == _selectedModelId)
                      .firstOrNull?.displayName ?? _selectedModelId!,
                  description: _availableModels
                      .where((m) => m.modelId == _selectedModelId)
                      .firstOrNull?.description,
                )]
              : widget.editProvider!.supportedModels,
        );
        
        await aiProvider.updateProvider(provider);
      } else {
        // 新增模式：创建新的提供商
        switch (_selectedProvider) {
          case 'openai':
            provider = aiProvider.createOpenAIProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            );
            break;
          case 'deepseek':
            provider = aiProvider.createDeepSeekProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            );
            break;
          default:
            // 对于其他类型，使用通用创建方法
            provider = aiProvider.createCustomProvider(
              name: _selectedProvider,
              displayName: _nameController.text.trim(),
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
              description: _descriptionController.text.trim(),
            );
            break;
        }
        
        // 设置自定义配置
        final updatedProvider = provider.copyWith(
          displayName: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          priority: _priority,
          // 如果选择了模型，设置为默认模型
          supportedModels: _selectedModelId != null 
              ? [ModelConfig(
                  modelId: _selectedModelId!,
                  displayName: _availableModels
                      .where((m) => m.modelId == _selectedModelId)
                      .firstOrNull?.displayName ?? _selectedModelId!,
                  description: _availableModels
                      .where((m) => m.modelId == _selectedModelId)
                      .firstOrNull?.description,
                )]
              : provider.supportedModels,
        );
        
        // 添加到Provider
        await aiProvider.addProvider(updatedProvider);
        provider = updatedProvider;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI服务"${provider.displayName}"${_isEditMode ? "更新" : "添加"}成功'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isEditMode ? "更新" : "添加"}失败：$e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}

// 扩展方法用于安全获取列表第一个元素
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}