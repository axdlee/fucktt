import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';

/// 统计图表组件
class StatisticsChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const StatisticsChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final totalAnalyzed = data['totalAnalyzed'] as int? ?? 0;
    final actionCounts = data['actionCounts'] as Map<String, dynamic>? ?? {};
    
    if (totalAnalyzed == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildOverviewStats(totalAnalyzed, actionCounts),
        SizedBox(height: 16.h),
        _buildActionDistribution(actionCounts, totalAnalyzed),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 32.sp,
              color: AppConstants.textTertiaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              '暂无统计数据',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建概览统计
  Widget _buildOverviewStats(int totalAnalyzed, Map<String, dynamic> actionCounts) {
    final allowedCount = actionCounts['FilterAction.allow'] as int? ?? 0;
    final blockedCount = actionCounts['FilterAction.block'] as int? ?? 0;
    final warnedCount = actionCounts['FilterAction.warning'] as int? ?? 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: '总分析',
            value: totalAnalyzed.toString(),
            color: AppConstants.infoColor,
            icon: Icons.analytics_outlined,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        Expanded(
          child: _buildStatItem(
            title: '已允许',
            value: allowedCount.toString(),
            color: AppConstants.successColor,
            icon: Icons.check_circle_outline,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        Expanded(
          child: _buildStatItem(
            title: '已屏蔽',
            value: blockedCount.toString(),
            color: AppConstants.errorColor,
            icon: Icons.block_outlined,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        Expanded(
          child: _buildStatItem(
            title: '已警告',
            value: warnedCount.toString(),
            color: AppConstants.warningColor,
            icon: Icons.warning_outlined,
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动作分布图
  Widget _buildActionDistribution(Map<String, dynamic> actionCounts, int total) {
    final actions = [
      {
        'name': '允许',
        'key': 'FilterAction.allow',
        'color': AppConstants.successColor,
      },
      {
        'name': '警告',
        'key': 'FilterAction.warning',
        'color': AppConstants.warningColor,
      },
      {
        'name': '模糊',
        'key': 'FilterAction.blur',
        'color': AppConstants.infoColor,
      },
      {
        'name': '屏蔽',
        'key': 'FilterAction.block',
        'color': AppConstants.errorColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '过滤动作分布',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        // 简化的条形图
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppConstants.dividerColor,
          ),
          child: total > 0 ? _buildProgressBar(actions, actionCounts, total) : null,
        ),
        
        SizedBox(height: 8.h),
        
        // 图例
        Wrap(
          spacing: 12.w,
          runSpacing: 4.h,
          children: actions.map((action) {
            final count = actionCounts[action['key']] as int? ?? 0;
            final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: action['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '${action['name']} $percentage%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(List<Map<String, dynamic>> actions, Map<String, dynamic> actionCounts, int total) {
    double currentPosition = 0.0;
    final segments = <Widget>[];
    
    for (final action in actions) {
      final count = actionCounts[action['key']] as int? ?? 0;
      final width = count / total;
      
      if (width > 0) {
        segments.add(
          Positioned(
            left: currentPosition,
            top: 0,
            bottom: 0,
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: action['color'] as Color,
                borderRadius: currentPosition == 0.0 
                    ? BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                      )
                    : currentPosition + width >= 1.0
                        ? BorderRadius.only(
                            topRight: Radius.circular(4.r),
                            bottomRight: Radius.circular(4.r),
                          )
                        : null,
              ),
            ),
          ),
        );
        currentPosition += width;
      }
    }
    
    return Stack(children: segments);
  }
}

/// 简单的线性图表组件
class SimpleLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color lineColor;
  final double height;

  const SimpleLineChart({
    super.key,
    required this.data,
    this.lineColor = AppConstants.primaryColor,
    this.height = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height.h,
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textTertiaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(
          data: data,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

/// 线性图表绘制器
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color lineColor;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 找到最大值用于归一化
    final maxValue = data.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    
    if (maxValue == 0) return;
    
    // 绘制线条
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i]['count'] as int) / maxValue) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // 绘制点
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i]['count'] as int) / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 3.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}