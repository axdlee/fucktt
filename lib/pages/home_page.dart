import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../models/behavior_model.dart';
import '../models/ai_provider_model.dart';
import '../providers/app_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/values_provider.dart';
import '../providers/content_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/app_card.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/quick_action_button.dart';

/// 应用主页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 延迟初始化，避免在build期间调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    try {
      final appProvider = context.read<AppProvider>();
      final aiProvider = context.read<AIProvider>();
      final valuesProvider = context.read<ValuesProvider>();
      final contentProvider = context.read<ContentProvider>();

      if (!appProvider.isInitialized) {
        await appProvider.initialize();
      }
      
      if (!aiProvider.isInitialized) {
        await aiProvider.initialize();
      }
      
      if (!valuesProvider.isInitialized) {
        await valuesProvider.initialize();
      }
      
      if (!contentProvider.isInitialized) {
        await contentProvider.initialize();
      }
    } catch (e) {
      print('Provider初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Consumer4<AppProvider, AIProvider, ValuesProvider, ContentProvider>(
        builder: (context, appProvider, aiProvider, valuesProvider, contentProvider, child) {
          if (appProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 状态概览卡片
                  _buildStatusOverviewCard(appProvider, aiProvider, valuesProvider, contentProvider),
                  
                  SizedBox(height: 16.h),
                  
                  // 快捷操作区域
                  _buildQuickActionsSection(),
                  
                  SizedBox(height: 16.h),
                  
                  // 统计图表
                  _buildStatisticsSection(contentProvider),
                  
                  SizedBox(height: 16.h),
                  
                  // 最近活动
                  _buildRecentActivitiesSection(contentProvider),
                  
                  SizedBox(height: 16.h),
                  
                  // AI服务状态
                  _buildAIServicesSection(aiProvider),
                  
                  SizedBox(height: 80.h), // 底部安全区域
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (!appProvider.appSettings.enableFloatingButton) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton(
            onPressed: () => _showQuickFilterDialog(),
            backgroundColor: AppConstants.primaryColor,
            child: const Icon(Icons.filter_alt_outlined, color: Colors.white),
          );
        },
      ),
    );
  }

  /// 构建状态概览卡片
  Widget _buildStatusOverviewCard(
    AppProvider appProvider,
    AIProvider aiProvider,
    ValuesProvider valuesProvider,
    ContentProvider contentProvider,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '状态概览',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.aiConfig),
                  child: _buildStatusItem(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI服务',
                    value: '${aiProvider.healthyProviders.length}/${aiProvider.providers.length}',
                    subtitle: '可用/总数',
                    color: aiProvider.hasAvailableServices 
                        ? AppConstants.successColor 
                        : AppConstants.errorColor,
                  ),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.values),
                  child: _buildStatusItem(
                    icon: Icons.favorite_outline,
                    title: '价值观模板',
                    value: valuesProvider.enabledTemplates.length.toString(),
                    subtitle: '已启用',
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.filterHistory),
                  child: _buildStatusItem(
                    icon: Icons.analytics_outlined,
                    title: '今日分析',
                    value: contentProvider.totalAnalyzed.toString(),
                    subtitle: '条内容',
                    color: AppConstants.infoColor,
                  ),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.filterHistory),
                  child: _buildStatusItem(
                    icon: Icons.block_outlined,
                    title: '过滤效率',
                    value: '${(contentProvider.filterEfficiency * 100).toStringAsFixed(1)}%',
                    subtitle: '拦截率',
                    color: AppConstants.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建状态项
  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 32.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppConstants.textTertiaryColor,
          ),
        ),
      ],
    );
  }

  /// 构建快捷操作区域
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.favorite_outline,
                title: '价值观配置',
                subtitle: '设置个人偏好',
                color: AppConstants.primaryColor,
                onTap: () => context.push(AppRoutes.values),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: QuickActionButton(
                icon: Icons.smart_toy,
                title: 'AI配置',
                subtitle: '管理AI服务',
                color: AppConstants.secondaryColor,
                onTap: () => context.push(AppRoutes.aiConfig),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.code_outlined,
                title: 'Prompt管理',
                subtitle: '自定义提示词',
                color: AppConstants.accentColor,
                onTap: () => context.push(AppRoutes.prompts),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: QuickActionButton(
                icon: Icons.history_outlined,
                title: '过滤历史',
                subtitle: '查看分析记录',
                color: AppConstants.warningColor,
                onTap: () => context.push(AppRoutes.filterHistory),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.science_outlined,
                title: '功能测试',
                subtitle: '验证系统功能',
                color: Colors.purple,
                onTap: () => context.push(AppRoutes.test),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: QuickActionButton(
                icon: Icons.psychology,
                title: '🔥 模拟测试',
                subtitle: '价值观过滤测试',
                color: Colors.deepOrange,
                onTap: () => context.push(AppRoutes.filterSimulation),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建统计图表区域
  Widget _buildStatisticsSection(ContentProvider contentProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '过滤统计',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.filterHistory),
                child: const Text('查看更多'),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          StatisticsChart(
            data: contentProvider.getFilterStatistics(),
          ),
        ],
      ),
    );
  }

  /// 构建最近活动区域
  Widget _buildRecentActivitiesSection(ContentProvider contentProvider) {
    final recentBehaviors = contentProvider.recentBehaviors.take(5).toList();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近活动',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          if (recentBehaviors.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  '暂无活动记录',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textTertiaryColor,
                  ),
                ),
              ),
            )
          else
            ...recentBehaviors.map((behavior) => _buildActivityItem(behavior)),
        ],
      ),
    );
  }

  /// 构建活动项
  Widget _buildActivityItem(BehaviorLogModel behavior) {
    IconData icon;
    Color color;
    
    switch (behavior.actionType) {
      case BehaviorType.like:
        icon = Icons.thumb_up_outlined;
        color = AppConstants.successColor;
        break;
      case BehaviorType.dislike:
        icon = Icons.thumb_down_outlined;
        color = AppConstants.errorColor;
        break;
      case BehaviorType.report:
        icon = Icons.report_outlined;
        color = AppConstants.warningColor;
        break;
      case BehaviorType.block:
        icon = Icons.block_outlined;
        color = AppConstants.errorColor;
        break;
      default:
        icon = Icons.visibility_outlined;
        color = AppConstants.infoColor;
    }
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          
          SizedBox(width: 12.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActionDescription(behavior.actionType),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Text(
                  behavior.content.length > 50 
                      ? '${behavior.content.substring(0, 50)}...'
                      : behavior.content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            _formatTimeAgo(behavior.timestamp),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppConstants.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建AI服务状态区域
  Widget _buildAIServicesSection(AIProvider aiProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI服务状态',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.aiConfig),
                child: const Text('管理'),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          if (aiProvider.providers.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 48.sp,
                      color: AppConstants.textTertiaryColor,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '暂未配置AI服务',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textTertiaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.aiConfig),
                      child: const Text('立即配置'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...aiProvider.providers.take(3).map((provider) => _buildAIServiceItem(provider, aiProvider)),
        ],
      ),
    );
  }

  /// 构建AI服务项
  Widget _buildAIServiceItem(AIProviderModel provider, AIProvider aiProvider) {
    final isHealthy = aiProvider.healthStatus[provider.id] ?? false;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isHealthy ? AppConstants.successColor : AppConstants.errorColor,
              shape: BoxShape.circle,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                if (provider.description != null)
                  Text(
                    provider.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          Text(
            isHealthy ? '正常' : '异常',
            style: TextStyle(
              fontSize: 12.sp,
              color: isHealthy ? AppConstants.successColor : AppConstants.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取动作描述
  String _getActionDescription(BehaviorType action) {
    switch (action) {
      case BehaviorType.like:
        return '点赞了内容';
      case BehaviorType.dislike:
        return '点踩了内容';
      case BehaviorType.report:
        return '举报了内容';
      case BehaviorType.block:
        return '屏蔽了内容';
      case BehaviorType.share:
        return '分享了内容';
      case BehaviorType.bookmark:
        return '收藏了内容';
      default:
        return '查看了内容';
    }
  }

  /// 格式化时间
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    final aiProvider = context.read<AIProvider>();
    final contentProvider = context.read<ContentProvider>();
    
    await Future.wait([
      aiProvider.refreshServices(),
      contentProvider.initialize(),
    ]);
  }

  /// 显示快速过滤对话框
  void _showQuickFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('快速过滤'),
        content: const Text('此功能将在后续版本中实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}