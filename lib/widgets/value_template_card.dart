import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/value_template_model.dart';
import '../constants/app_constants.dart';
import 'app_card.dart';

/// 价值观模板卡片组件
class ValueTemplateCard extends StatelessWidget {
  final ValueTemplateModel template;
  final bool compact;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(double)? onWeightChanged;

  const ValueTemplateCard({
    super.key,
    required this.template,
    this.compact = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard();
    } else {
      return _buildFullCard();
    }
  }

  /// 构建完整卡片
  Widget _buildFullCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              // 启用开关
              Switch(
                value: template.enabled,
                onChanged: (_) => onToggle?.call(),
                activeThumbColor: AppConstants.primaryColor,
              ),
              
              SizedBox(width: 12.w),
              
              // 标题和描述
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: template.enabled 
                            ? AppConstants.textPrimaryColor 
                            : AppConstants.textTertiaryColor,
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    Text(
                      template.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: template.enabled 
                            ? AppConstants.textSecondaryColor 
                            : AppConstants.textTertiaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 操作按钮
              _buildActionButtons(),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // 分类标签
          _buildCategoryChip(),
          
          if (template.enabled) ...[
            SizedBox(height: 12.h),
            
            // 关键词展示
            _buildKeywords(),
            
            SizedBox(height: 12.h),
            
            // 权重调节
            _buildWeightSlider(),
          ],
        ],
      ),
    );
  }

  /// 构建紧凑卡片
  Widget _buildCompactCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: template.enabled 
            ? AppConstants.cardBackgroundColor 
            : AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: template.enabled 
              ? AppConstants.primaryColor.withValues(alpha: 0.2)
              : AppConstants.dividerColor,
        ),
      ),
      child: Row(
        children: [
          // 启用开关
          Switch(
            value: template.enabled,
            onChanged: (_) => onToggle?.call(),
            activeThumbColor: AppConstants.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          
          SizedBox(width: 12.w),
          
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: template.enabled 
                        ? AppConstants.textPrimaryColor 
                        : AppConstants.textTertiaryColor,
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                Text(
                  template.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: template.enabled 
                        ? AppConstants.textSecondaryColor 
                        : AppConstants.textTertiaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 操作按钮
          if (template.enabled) _buildCompactActionButtons(),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 18.sp,
              color: AppConstants.textSecondaryColor,
            ),
            onPressed: onEdit,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
          ),
        
        if (onDelete != null)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18.sp,
              color: AppConstants.errorColor,
            ),
            onPressed: onDelete,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
          ),
      ],
    );
  }

  /// 构建紧凑模式操作按钮
  Widget _buildCompactActionButtons() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 16.sp,
        color: AppConstants.textSecondaryColor,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined),
                SizedBox(width: 8),
                Text('编辑'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 8),
                Text('删除'),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建分类标签
  Widget _buildCategoryChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        template.category,
        style: TextStyle(
          fontSize: 11.sp,
          color: _getCategoryColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建关键词
  Widget _buildKeywords() {
    final allKeywords = [
      ...template.keywords.map((k) => {'text': k, 'type': 'positive'}),
      ...template.negativeKeywords.map((k) => {'text': k, 'type': 'negative'}),
    ];

    if (allKeywords.isEmpty) {
      return Text(
        '暂无关键词',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppConstants.textTertiaryColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      children: allKeywords.take(6).map((keyword) {
        final isPositive = keyword['type'] == 'positive';
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isPositive 
                ? AppConstants.successColor.withValues(alpha: 0.1)
                : AppConstants.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            keyword['text'] as String,
            style: TextStyle(
              fontSize: 10.sp,
              color: isPositive 
                  ? AppConstants.successColor
                  : AppConstants.errorColor,
            ),
          ),
        );
      }).toList(),
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
                fontSize: 12.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            Text(
              '${(template.weight * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 4.h),
        
        Builder(
          builder: (context) => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppConstants.primaryColor,
              inactiveTrackColor: AppConstants.primaryColor.withValues(alpha: 0.2),
              thumbColor: AppConstants.primaryColor,
              overlayColor: AppConstants.primaryColor.withValues(alpha: 0.1),
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            ),
            child: Slider(
              value: template.weight,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: onWeightChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// 获取分类颜色
  Color _getCategoryColor() {
    switch (template.category) {
      case '政治立场':
        return Colors.red;
      case '社会价值':
        return Colors.blue;
      case '经济观念':
        return Colors.green;
      case '文化认同':
        return Colors.purple;
      case '环保意识':
        return Colors.teal;
      case '生活方式':
        return Colors.orange;
      case '道德观念':
        return Colors.pink;
      case '教育理念':
        return Colors.indigo;
      default:
        return AppConstants.primaryColor;
    }
  }
}