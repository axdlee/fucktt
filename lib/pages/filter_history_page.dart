import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../widgets/app_card.dart';

class FilterHistoryPage extends StatefulWidget {
  const FilterHistoryPage({super.key});

  @override
  State<FilterHistoryPage> createState() => _FilterHistoryPageState();
}

class _FilterHistoryPageState extends State<FilterHistoryPage> {
  final List<Map<String, dynamic>> _filterHistory = [
    {
      'id': '1',
      'content': '这是一篇关于科技创新的文章，讲述了人工智能在未来的发展前景和对社会的积极影响。',
      'valueScore': 0.85,
      'sentiment': '积极',
      'action': '允许',
      'topics': ['科技', '创新', '人工智能'],
      'matchedKeywords': ['积极', '创新', '发展'],
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'source': '今日头条',
    },
    {
      'id': '2',
      'content': '网络上一些不实信息和恶意言论正在传播，影响着社会的和谐稳定。',
      'valueScore': 0.25,
      'sentiment': '消极',
      'action': '拦截',
      'topics': ['虚假信息', '社会问题'],
      'matchedKeywords': ['不实', '恶意', '消极'],
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'source': '微博',
    },
    {
      'id': '3',
      'content': '家庭教育的重要性及其对孩子成长的深远影响，如何培养孩子的品格和价值观。',
      'valueScore': 0.75,
      'sentiment': '中性',
      'action': '警告',
      'topics': ['家庭教育', '品格培养'],
      'matchedKeywords': ['教育', '品格', '价值观'],
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'source': '知乎',
    },
    {
      'id': '4',
      'content': '环保主题的文章，关注可持续发展和绿色生活方式，倡导低碳环保理念。',
      'valueScore': 0.92,
      'sentiment': '积极',
      'action': '允许',
      'topics': ['环保', '可持续发展'],
      'matchedKeywords': ['环保', '可持续', '绿色'],
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'source': '网易新闻',
    },
    {
      'id': '5',
      'content': '有关金融投资的风险警示文章，提醒投资者理性投资，警惕各种投资陷阱。',
      'valueScore': 0.68,
      'sentiment': '中性',
      'action': '模糊',
      'topics': ['金融投资', '风险管理'],
      'matchedKeywords': ['理性', '警惕', '风险'],
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'source': '财经网',
    },
  ];

  String _selectedFilter = '全部';
  String _selectedSort = '时间降序';

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('过滤历史'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '时间降序', child: Text('时间降序')),
              const PopupMenuItem(value: '时间升序', child: Text('时间升序')),
              const PopupMenuItem(value: '分数降序', child: Text('分数降序')),
              const PopupMenuItem(value: '分数升序', child: Text('分数升序')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '全部', child: Text('全部')),
              const PopupMenuItem(value: '允许', child: Text('允许')),
              const PopupMenuItem(value: '警告', child: Text('警告')),
              const PopupMenuItem(value: '模糊', child: Text('模糊')),
              const PopupMenuItem(value: '拦截', child: Text('拦截')),
            ],
          ),
        ],
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 统计信息
            _buildStatsSection(),

            SizedBox(height: 16.h),

            // 过滤历史列表
            _buildHistoryList(filteredHistory),
          ],
        ),
      ),
    );
  }

  /// 获取过滤后的历史记录
  List<Map<String, dynamic>> _getFilteredHistory() {
    var filtered = _filterHistory.where((item) {
      if (_selectedFilter == '全部') return true;
      return item['action'] == _selectedFilter;
    }).toList();

    // 排序
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case '时间升序':
          return (a['timestamp'] as DateTime)
              .compareTo(b['timestamp'] as DateTime);
        case '分数降序':
          return (b['valueScore'] as double)
              .compareTo(a['valueScore'] as double);
        case '分数升序':
          return (a['valueScore'] as double)
              .compareTo(b['valueScore'] as double);
        default: // 时间降序
          return (b['timestamp'] as DateTime)
              .compareTo(a['timestamp'] as DateTime);
      }
    });

    return filtered;
  }

  /// 构建统计信息区域
  Widget _buildStatsSection() {
    final totalCount = _filterHistory.length;
    final allowedCount =
        _filterHistory.where((item) => item['action'] == '允许').length;
    final blockedCount =
        _filterHistory.where((item) => item['action'] == '拦截').length;
    final averageScore = _filterHistory.isEmpty
        ? 0.0
        : _filterHistory
                .map((item) => item['valueScore'] as double)
                .reduce((a, b) => a + b) /
            totalCount;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '过滤统计',
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
                child: _buildStatItem(
                  icon: Icons.article_outlined,
                  title: '总数',
                  value: totalCount.toString(),
                  color: AppConstants.primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  title: '允许',
                  value: allowedCount.toString(),
                  color: AppConstants.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.block_outlined,
                  title: '拦截',
                  value: blockedCount.toString(),
                  color: AppConstants.errorColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up_outlined,
                  title: '平均分',
                  value: '${(averageScore * 100).toInt()}%',
                  color: AppConstants.infoColor,
                ),
              ),
            ],
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
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// 构建历史列表
  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Icon(
              Icons.history_outlined,
              size: 64.sp,
              color: AppConstants.textTertiaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无过滤历史',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '过滤历史',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                '当前: $_selectedFilter | $_selectedSort',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = history[index];
              return _buildHistoryCard(item);
            },
          ),
        ],
      ),
    );
  }

  /// 构建历史卡片
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final action = item['action'] as String;
    final valueScore = item['valueScore'] as double;
    final actionColor = _getActionColor(action);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: actionColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  action,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: actionColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(valueScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(item['timestamp'] as DateTime),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppConstants.textTertiaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 内容
          Text(
            item['content'] as String,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textPrimaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 8.h),

          // 标签和关键词
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              ...((item['topics'] as List<String>).map(
                (topic) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppConstants.accentColor,
                    ),
                  ),
                ),
              )),
            ],
          ),

          SizedBox(height: 8.h),

          // 底部信息
          Row(
            children: [
              Icon(
                Icons.source_outlined,
                size: 14.sp,
                color: AppConstants.textTertiaryColor,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  item['source'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppConstants.textTertiaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.sentiment_satisfied_outlined,
                size: 14.sp,
                color: AppConstants.textTertiaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                item['sentiment'] as String,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppConstants.textTertiaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showDetailDialog(item),
                child: Text('详情', style: TextStyle(fontSize: 11.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取操作颜色
  Color _getActionColor(String action) {
    switch (action) {
      case '允许':
        return AppConstants.successColor;
      case '警告':
        return AppConstants.warningColor;
      case '模糊':
        return AppConstants.infoColor;
      case '拦截':
        return AppConstants.errorColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  /// 显示详情对话框
  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('内容分析详情'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('内容：', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text(item['content'] as String),
                SizedBox(height: 12.h),
                Text(
                    '价值观分数：${((item['valueScore'] as double) * 100).toInt()}%'),
                SizedBox(height: 8.h),
                Text('情感倾向：${item['sentiment']}'),
                SizedBox(height: 8.h),
                Text('过滤动作：${item['action']}'),
                SizedBox(height: 8.h),
                Text('来源：${item['source']}'),
                SizedBox(height: 12.h),
                Text('主题标签：', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text((item['topics'] as List<String>).join('、')),
                SizedBox(height: 8.h),
                Text('匹配关键词：', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text((item['matchedKeywords'] as List<String>).join('、')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}