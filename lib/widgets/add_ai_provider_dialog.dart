import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/ai_provider.dart';
import '../constants/app_constants.dart';

/// 添加AI服务提供商对话框
class AddAIProviderDialog extends StatefulWidget {
  const AddAIProviderDialog({super.key});

  @override
  State<AddAIProviderDialog> createState() => _AddAIProviderDialogState();
}

class _AddAIProviderDialogState extends State<AddAIProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedProvider = 'openai';
  int _priority = 1;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _updateProviderDefaults();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _descriptionController.dispose();
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
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入API密钥';
                          }
                          return null;
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
                          if (!Uri.tryParse(value)?.isAbsolute == true) {
                            return '请输入有效的URL地址';
                          }
                          return null;
                        },
                      ),
                      
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
            '添加AI服务',
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
                  _updateProviderDefaults();
                });
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
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () {
                      // TODO: 实现密码可见性切换
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
            inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.2),
            thumbColor: AppConstants.primaryColor,
            overlayColor: AppConstants.primaryColor.withOpacity(0.1),
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
      final tempProvider = _selectedProvider == 'openai'
          ? aiProvider.createOpenAIProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            )
          : aiProvider.createDeepSeekProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            );
      
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
      // 创建AI服务提供商
      final provider = _selectedProvider == 'openai'
          ? aiProvider.createOpenAIProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            )
          : aiProvider.createDeepSeekProvider(
              apiKey: _apiKeyController.text.trim(),
              baseUrl: _baseUrlController.text.trim(),
            );
      
      // 设置自定义配置
      final updatedProvider = provider.copyWith(
        displayName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
      );
      
      // 添加到Provider
      await aiProvider.addProvider(updatedProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI服务\"${updatedProvider.displayName}\"添加成功'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败：$e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}