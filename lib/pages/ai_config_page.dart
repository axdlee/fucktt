import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/ai_provider.dart';
import '../models/ai_provider_model.dart';
import '../constants/app_constants.dart';
import '../widgets/app_card.dart';
import '../widgets/ai_provider_card.dart';
import '../widgets/add_ai_provider_dialog.dart';

/// AI服务配置页面
class AIConfigPage extends StatefulWidget {
  const AIConfigPage({super.key});

  @override
  State<AIConfigPage> createState() => _AIConfigPageState();
}

class _AIConfigPageState extends State<AIConfigPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOnlyEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'AI服务配置',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddProviderDialog(),
            tooltip: '添加AI服务',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshServices(),
            tooltip: '刷新状态',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('使用帮助'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_all',
                child: Row(
                  children: [
                    Icon(Icons.speed),
                    SizedBox(width: 8),
                    Text('测试所有服务'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.textSecondaryColor,
          indicatorColor: AppConstants.primaryColor,
          tabs: const [
            Tab(text: 'AI服务列表'),
            Tab(text: '服务统计'),
          ],
        ),
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProvidersTab(aiProvider),
              _buildStatisticsTab(aiProvider),
            ],
          );
        },
      ),
    );
  }

  /// 构建AI服务列表标签页
  Widget _buildProvidersTab(AIProvider aiProvider) {
    return Column(
      children: [
        // 过滤选项
        _buildFilterOptions(),
        
        // 状态概览
        _buildStatusOverview(aiProvider),
        
        // 服务列表
        Expanded(
          child: _buildProvidersList(aiProvider),
        ),
      ],
    );
  }

  /// 构建统计标签页
  Widget _buildStatisticsTab(AIProvider aiProvider) {
    final statistics = aiProvider.getServiceStatistics();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 整体统计
          _buildOverallStats(statistics),
          
          SizedBox(height: 16.h),
          
          // 服务详情
          _buildServiceDetails(statistics),
          
          SizedBox(height: 16.h),
          
          // 性能监控
          _buildPerformanceMonitor(aiProvider),
        ],
      ),
    );
  }

  /// 构建过滤选项
  Widget _buildFilterOptions() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Text(
            '显示选项：',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          FilterChip(
            label: const Text('仅显示已启用'),
            selected: _showOnlyEnabled,
            onSelected: (selected) {
              setState(() {
                _showOnlyEnabled = selected;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: AppConstants.primaryColor.withOpacity(0.1),
            checkmarkColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  /// 构建状态概览
  Widget _buildStatusOverview(AIProvider aiProvider) {
    final totalProviders = aiProvider.providers.length;
    final enabledProviders = aiProvider.enabledProviders.length;
    final healthyProviders = aiProvider.healthyProviders.length;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.smart_toy_outlined,
              title: '总服务数',
              value: totalProviders.toString(),
              color: AppConstants.infoColor,
            ),
          ),
          
          Expanded(
            child: _buildStatItem(
              icon: Icons.power_settings_new,
              title: '已启用',
              value: enabledProviders.toString(),
              color: AppConstants.primaryColor,
            ),
          ),
          
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline,
              title: '健康状态',
              value: healthyProviders.toString(),
              color: AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
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
      ],
    );
  }

  /// 构建服务列表
  Widget _buildProvidersList(AIProvider aiProvider) {
    var providers = aiProvider.providers;
    
    if (_showOnlyEnabled) {
      providers = aiProvider.enabledProviders;
    }
    
    if (providers.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        final isHealthy = aiProvider.healthStatus[provider.id] ?? false;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: AIProviderCard(
            provider: provider,
            isHealthy: isHealthy,
            isLoading: aiProvider.isLoading,
            onToggle: () => _toggleProvider(provider.id),
            onEdit: () => _editProvider(provider),
            onDelete: () => _deleteProvider(provider.id),
            onTest: () => _testProvider(provider),
            onPriorityChanged: (priority) => _updatePriority(provider.id, priority),
          ),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64.sp,
            color: AppConstants.textTertiaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无AI服务',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '添加AI服务以开始使用智能内容分析功能',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showAddProviderDialog(),
            icon: const Icon(Icons.add),
            label: const Text('添加AI服务'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建整体统计
  Widget _buildOverallStats(Map<String, dynamic> statistics) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '整体统计',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          _buildStatRow('总服务数', '${statistics['totalServices']}'),
          _buildStatRow('健康服务', '${statistics['healthyServices']}'),
          _buildStatRow('异常服务', '${statistics['unhealthyServices']}'),
          
          SizedBox(height: 12.h),
          
          LinearProgressIndicator(
            value: statistics['totalServices'] > 0 
                ? statistics['healthyServices'] / statistics['totalServices']
                : 0.0,
            backgroundColor: AppConstants.errorColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.successColor),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            '服务健康率: ${statistics['totalServices'] > 0 ? ((statistics['healthyServices'] / statistics['totalServices']) * 100).toStringAsFixed(1) : 0}%',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务详情
  Widget _buildServiceDetails(Map<String, dynamic> statistics) {
    final services = statistics['services'] as Map<String, dynamic>? ?? {};
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务详情',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          if (services.isEmpty)
            Text(
              '暂无服务信息',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textTertiaryColor,
              ),
            )
          else
            ...services.entries.map((entry) {
              final serviceInfo = entry.value as Map<String, dynamic>;
              return _buildServiceDetailItem(
                name: serviceInfo['name'] as String,
                healthy: serviceInfo['healthy'] as bool,
                enabled: serviceInfo['enabled'] as bool,
                priority: serviceInfo['priority'] as int,
                lastCheck: serviceInfo['lastCheck'] as String?,
              );
            }),
        ],
      ),
    );
  }

  /// 构建服务详情项
  Widget _buildServiceDetailItem({
    required String name,
    required bool healthy,
    required bool enabled,
    required int priority,
    String? lastCheck,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // 状态指示器
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: healthy ? AppConstants.successColor : AppConstants.errorColor,
              shape: BoxShape.circle,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // 服务信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: enabled ? AppConstants.textPrimaryColor : AppConstants.textTertiaryColor,
                  ),
                ),
                if (lastCheck != null)
                  Text(
                    '最后检查: ${_formatDateTime(lastCheck)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppConstants.textTertiaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // 优先级标签
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '优先级 $priority',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建性能监控
  Widget _buildPerformanceMonitor(AIProvider aiProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '性能监控',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () => _refreshServices(),
                child: const Text('刷新'),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          if (aiProvider.hasActiveRequest)
            Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8.w),
                Text(
                  '正在执行AI请求...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            )
          else
            Text(
              '所有服务空闲中',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
        ],
      ),
    );
  }

  /// 处理菜单动作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'help':
        _showHelp();
        break;
      case 'test_all':
        _testAllProviders();
        break;
    }
  }

  /// 显示添加服务对话框
  void _showAddProviderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAIProviderDialog(),
    );
  }

  /// 刷新服务
  void _refreshServices() {
    final aiProvider = context.read<AIProvider>();
    aiProvider.refreshServices();
  }

  /// 切换服务状态
  void _toggleProvider(String providerId) {
    final aiProvider = context.read<AIProvider>();
    aiProvider.toggleProvider(providerId);
  }

  /// 编辑服务
  void _editProvider(AIProviderModel provider) {
    // TODO: 实现编辑对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑AI服务'),
        content: const Text('编辑功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 删除服务
  void _deleteProvider(String providerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除AI服务'),
        content: const Text('确定要删除这个AI服务吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final aiProvider = context.read<AIProvider>();
              aiProvider.removeProvider(providerId);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 测试服务
  void _testProvider(AIProviderModel provider) async {
    final aiProvider = context.read<AIProvider>();
    
    // 显示测试对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('测试连接'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('正在测试 ${provider.displayName} 连接...'),
          ],
        ),
      ),
    );
    
    final result = await aiProvider.testProvider(provider);
    
    if (mounted) {
      Navigator.pop(context); // 关闭测试对话框
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result ? '测试成功' : '测试失败'),
          content: Text(
            result 
                ? '${provider.displayName} 连接正常，可以正常使用。'
                : '${provider.displayName} 连接失败，请检查配置信息。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  /// 更新优先级
  void _updatePriority(String providerId, int priority) {
    final aiProvider = context.read<AIProvider>();
    aiProvider.setProviderPriority(providerId, priority);
  }

  /// 测试所有服务
  void _testAllProviders() async {
    final aiProvider = context.read<AIProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('测试所有服务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            const Text('正在测试所有AI服务连接...'),
          ],
        ),
      ),
    );
    
    await aiProvider.refreshServices();
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有服务测试完成')),
      );
    }
  }

  /// 显示帮助
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI服务配置帮助'),
        content: const SingleChildScrollView(
          child: Text(
            'AI服务配置帮助：\n\n'
            '1. 添加AI服务\n'
            '   - 支持OpenAI、DeepSeek等主流AI服务\n'
            '   - 需要提供API密钥和基础URL\n\n'
            '2. 服务管理\n'
            '   - 可以启用/禁用服务\n'
            '   - 调整服务优先级\n'
            '   - 测试服务连接状态\n\n'
            '3. 智能负载均衡\n'
            '   - 系统会自动选择最佳可用服务\n'
            '   - 支持故障转移\n'
            '   - 定期健康检查\n\n'
            '注意事项：\n'
            '• 确保API密钥有效且有足够额度\n'
            '• 建议配置多个服务以提高可用性\n'
            '• 定期检查服务状态',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}小时前';
      } else {
        return '${difference.inDays}天前';
      }
    } catch (e) {
      return '未知时间';
    }
  }
}