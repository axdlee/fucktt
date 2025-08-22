import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';

/// 快捷操作按钮组件
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppConstants.dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: enabled ? color.withOpacity(0.1) : AppConstants.textTertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : AppConstants.textTertiaryColor,
                  size: 24.sp,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppConstants.textPrimaryColor : AppConstants.textTertiaryColor,
                ),
              ),
              
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: enabled ? AppConstants.textSecondaryColor : AppConstants.textTertiaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 网格快捷操作按钮
class GridQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? badge;

  const GridQuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
    this.enabled = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppConstants.dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: enabled ? color.withOpacity(0.1) : AppConstants.textTertiaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      color: enabled ? color : AppConstants.textTertiaryColor,
                      size: 20.sp,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: badge!,
                    ),
                ],
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: enabled ? AppConstants.textPrimaryColor : AppConstants.textTertiaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 圆形快捷操作按钮
class CircularQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
  final double size;

  const CircularQuickActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.color,
    this.onTap,
    this.enabled = true,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(size.r / 2),
            child: Container(
              width: size.w,
              height: size.w,
              decoration: BoxDecoration(
                color: enabled ? color : AppConstants.textTertiaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (enabled ? color : AppConstants.textTertiaryColor).withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: (size * 0.4).sp,
              ),
            ),
          ),
        ),
        
        if (label != null) ...[
          SizedBox(height: 8.h),
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: enabled ? AppConstants.textPrimaryColor : AppConstants.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 水平快捷操作按钮
class HorizontalQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;

  const HorizontalQuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppConstants.dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: enabled ? color.withOpacity(0.1) : AppConstants.textTertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : AppConstants.textTertiaryColor,
                  size: 20.sp,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: enabled ? AppConstants.textPrimaryColor : AppConstants.textTertiaryColor,
                      ),
                    ),
                    
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: enabled ? AppConstants.textSecondaryColor : AppConstants.textTertiaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ] else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: enabled ? AppConstants.textTertiaryColor : AppConstants.textQuaternaryColor,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}