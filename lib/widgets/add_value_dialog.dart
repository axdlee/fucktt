import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/values_provider.dart';
import '../constants/app_constants.dart';

/// 添加价值观对话框
class AddValueDialog extends StatefulWidget {
  const AddValueDialog({super.key});

  @override
  State<AddValueDialog> createState() => _AddValueDialogState();
}

class _AddValueDialogState extends State<AddValueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _negativeKeywordsController = TextEditingController();
  
  String _selectedCategory = AppConstants.valueCategories.first;
  double _weight = 0.5;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _negativeKeywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
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
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '创建新的价值观',
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
            ),
            
            // 表单内容
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名称输入
                      _buildTextField(
                        controller: _nameController,
                        label: '价值观名称',
                        hint: '例如：正面价值观',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入价值观名称';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 分类选择
                      _buildCategorySelector(),
                      
                      SizedBox(height: 16.h),
                      
                      // 描述输入
                      _buildTextField(
                        controller: _descriptionController,
                        label: '价值观描述',
                        hint: '简要描述这个价值观的含义和目的',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入价值观描述';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 正面关键词
                      _buildTextField(
                        controller: _keywordsController,
                        label: '正面关键词',
                        hint: '用逗号分隔，例如：正能量,积极,向上',
                        maxLines: 2,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 负面关键词
                      _buildTextField(
                        controller: _negativeKeywordsController,
                        label: '负面关键词',
                        hint: '用逗号分隔，例如：负面,消极,抱怨',
                        maxLines: 2,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // 权重调节
                      _buildWeightSlider(),
                      
                      SizedBox(height: 24.h),
                      
                      // 按钮组
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

  /// 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          ),
        ),
      ],
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '价值观分类',
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
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
            items: AppConstants.valueCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建权重滑块
  Widget _buildWeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '重要程度',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            Text(
              '${(_weight * 100).toInt()}%',
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
            value: _weight,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '不重要',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
            Text(
              '非常重要',
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
    return Row(
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
            onPressed: _createValue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              elevation: 0,
            ),
            child: Text(
              '创建',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 创建价值观
  void _createValue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final valuesProvider = context.read<ValuesProvider>();

    // 解析关键词
    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final negativeKeywords = _negativeKeywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 创建价值观模板
    final template = valuesProvider.createCustomTemplate(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      keywords: keywords,
      negativeKeywords: negativeKeywords,
      weight: _weight,
    );

    // 添加到Provider
    valuesProvider.addTemplate(template);

    // 关闭对话框
    Navigator.of(context).pop();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('价值观"${template.name}"创建成功'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}