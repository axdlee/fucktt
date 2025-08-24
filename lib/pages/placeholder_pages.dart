import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../models/user_config_model.dart';

class PromptManagementPage extends StatefulWidget {
  const PromptManagementPage({super.key});

  @override
  State<PromptManagementPage> createState() => _PromptManagementPageState();
}

class _PromptManagementPageState extends State<PromptManagementPage> {
  final List<Map<String, dynamic>> _promptTemplates = [
    {
      'id': 'content_analysis',
      'name': '内容分析提示词',
      'category': '内容分析',
      'description': '用于分析内容的价值观匹配度',
      'template': '请分析以下内容的价值观匹配度：\n\n{content}\n\n用户价值观：{values}\n\n请返回分析结果。',
      'enabled': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'sentiment_analysis',
      'name': '情感分析提示词',
      'category': '情感分析',
      'description': '用于分析内容的情感倾向',
      'template': '请分析以下文本的情感倾向：\n\n{content}\n\n请评估正面、负面和中性情感的比例。',
      'enabled': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 'topic_extraction',
      'name': '主题提取提示词',
      'category': '主题分析',
      'description': '用于提取内容的主要主题',
      'template': '请从以下内容中提取主要主题：\n\n{content}\n\n请列出3-5个核心主题。',
      'enabled': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPromptTemplates();
  }

  /// 加载Prompt模板
  Future<void> _loadPromptTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString('prompt_templates');
      if (templatesJson != null) {
        final List<dynamic> templatesList = json.decode(templatesJson);
        setState(() {
          _promptTemplates.clear();
          _promptTemplates.addAll(templatesList.map((item) {
            // 确保 createdAt 是 DateTime 对象
            if (item['createdAt'] is String) {
              item['createdAt'] = DateTime.parse(item['createdAt']);
            }
            return Map<String, dynamic>.from(item);
          }).toList());
        });
      }
    } catch (e) {
      print('加载Prompt模板失败: $e');
    }
  }

  /// 保存Prompt模板
  Future<void> _savePromptTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 将DateTime转换为字符串以便序列化
      final templatesForSave = _promptTemplates.map((template) {
        final copy = Map<String, dynamic>.from(template);
        if (copy['createdAt'] is DateTime) {
          copy['createdAt'] = (copy['createdAt'] as DateTime).toIso8601String();
        }
        return copy;
      }).toList();
      
      await prefs.setString('prompt_templates', json.encode(templatesForSave));
    } catch (e) {
      print('保存Prompt模板失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt管理'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPromptDialog,
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
            
            // Prompt模板列表
            _buildPromptsList(),
          ],
        ),
      ),
    );
  }

  /// 构建统计信息区域
  Widget _buildStatsSection() {
    final enabledCount = _promptTemplates.where((p) => p['enabled'] as bool).length;
    final totalCount = _promptTemplates.length;
    
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
                'Prompt统计',
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
                  icon: Icons.text_fields,
                  title: '总数',
                  value: totalCount.toString(),
                  color: AppConstants.primaryColor,
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  title: '已启用',
                  value: enabledCount.toString(),
                  color: AppConstants.successColor,
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pause_circle_outline,
                  title: '已禁用',
                  value: (totalCount - enabledCount).toString(),
                  color: AppConstants.warningColor,
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
      ],
    );
  }

  /// 构建Prompt列表
  Widget _buildPromptsList() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Prompt模板',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _promptTemplates.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final prompt = _promptTemplates[index];
              return _buildPromptCard(prompt, index);
            },
          ),
        ],
      ),
    );
  }

  /// 构建Prompt卡片
  Widget _buildPromptCard(Map<String, dynamic> prompt, int index) {
    final isEnabled = prompt['enabled'] as bool;
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isEnabled ? AppConstants.primaryColor : AppConstants.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt['name'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      prompt['category'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 状态切换
              Switch(
                value: isEnabled,
                onChanged: (value) async {
                  setState(() {
                    _promptTemplates[index]['enabled'] = value;
                  });
                  
                  // 添加持久化存储逻辑
                  await _savePromptTemplates();
                  
                  // 显示反馈
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Prompt已启用' : 'Prompt已禁用'),
                      backgroundColor: AppConstants.successColor,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            prompt['description'] as String,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  '创建于 ${_formatDate(prompt['createdAt'] as DateTime)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppConstants.textTertiaryColor,
                  ),
                ),
              ),
              
              // 用弹出菜单来节省空间
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 16.sp),
                onSelected: (action) {
                  switch (action) {
                    case 'view':
                      _showPromptDetail(prompt);
                      break;
                    case 'edit':
                      _showEditPromptDialog(prompt, index);
                      break;
                    case 'delete':
                      _deletePrompt(index);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('查看', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('编辑', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16.sp, color: AppConstants.errorColor),
                        SizedBox(width: 8.w),
                        Text('删除', style: TextStyle(fontSize: 12.sp, color: AppConstants.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示添加Prompt对话框
  void _showAddPromptDialog() {
    _showPromptDialog();
  }

  /// 显示编辑Prompt对话框
  void _showEditPromptDialog(Map<String, dynamic> prompt, int index) {
    _showPromptDialog(prompt: prompt, index: index);
  }

  /// 显示Prompt对话框
  void _showPromptDialog({Map<String, dynamic>? prompt, int? index}) {
    final isEdit = prompt != null;
    final nameController = TextEditingController(text: prompt?['name'] ?? '');
    final categoryController = TextEditingController(text: prompt?['category'] ?? '');
    final descriptionController = TextEditingController(text: prompt?['description'] ?? '');
    final templateController = TextEditingController(text: prompt?['template'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '编辑Prompt' : '添加Prompt'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: '请输入Prompt名称',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    hintText: '请输入Prompt分类',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    hintText: '请输入Prompt描述',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: templateController,
                  decoration: const InputDecoration(
                    labelText: '模板内容',
                    hintText: '请输入Prompt模板，使用{content}、{values}等参数',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final newPrompt = {
                'id': prompt?['id'] ?? 'prompt_${DateTime.now().millisecondsSinceEpoch}',
                'name': nameController.text,
                'category': categoryController.text,
                'description': descriptionController.text,
                'template': templateController.text,
                'enabled': prompt?['enabled'] ?? true,
                'createdAt': prompt?['createdAt'] ?? DateTime.now(),
              };
              
              setState(() {
                if (isEdit && index != null) {
                  _promptTemplates[index] = newPrompt;
                } else {
                  _promptTemplates.add(newPrompt);
                }
              });
              
              // 保存到本地
              await _savePromptTemplates();
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Prompt修改成功' : 'Prompt添加成功'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            child: Text(isEdit ? '保存' : '添加'),
          ),
        ],
      ),
    );
  }

  /// 显示Prompt详情
  void _showPromptDetail(Map<String, dynamic> prompt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prompt['name'] as String),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('分类：${prompt['category']}'),
                SizedBox(height: 8.h),
                Text('描述：${prompt['description']}'),
                SizedBox(height: 16.h),
                const Text('模板内容：', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    prompt['template'] as String,
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace'),
                  ),
                ),
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

  /// 删除Prompt
  void _deletePrompt(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个Prompt吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _promptTemplates.removeAt(index);
              });
              
              // 保存到本地
              await _savePromptTemplates();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prompt删除成功'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            child: const Text('删除', style: TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}-${date.day}';
  }
}

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
          return (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime);
        case '分数降序':
          return (b['valueScore'] as double).compareTo(a['valueScore'] as double);
        case '分数升序':
          return (a['valueScore'] as double).compareTo(b['valueScore'] as double);
        default: // 时间降序
          return (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime);
      }
    });

    return filtered;
  }

  /// 构建统计信息区域
  Widget _buildStatsSection() {
    final totalCount = _filterHistory.length;
    final allowedCount = _filterHistory.where((item) => item['action'] == '允许').length;
    final blockedCount = _filterHistory.where((item) => item['action'] == '拦截').length;
    final averageScore = _filterHistory.isEmpty 
        ? 0.0 
        : _filterHistory.map((item) => item['valueScore'] as double).reduce((a, b) => a + b) / totalCount;
    
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
              ...((item['topics'] as List<String>).map((topic) => 
                Container(
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
                Text('价值观分数：${((item['valueScore'] as double) * 100).toInt()}%'),
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 外观设置
                _buildAppearanceSection(appProvider),
                
                SizedBox(height: 16.h),
                
                // 功能设置
                _buildFunctionalSection(appProvider),
                
                SizedBox(height: 16.h),
                
                // 隐私设置
                _buildPrivacySection(appProvider),
                
                SizedBox(height: 16.h),
                
                // 其他设置
                _buildOtherSection(appProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建外观设置区域
  Widget _buildAppearanceSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '外观设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 主题模式
          ListTile(
            leading: Icon(Icons.dark_mode_outlined, size: 20.sp),
            title: Text('主题模式', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text(_getThemeModeText(appProvider.themeMode), 
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: DropdownButton<ThemeMode>(
              value: appProvider.themeMode,
              underline: const SizedBox(),
              onChanged: (mode) async {
                if (mode != null) {
                  await appProvider.setThemeMode(mode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('主题模式已设置为${_getThemeModeText(mode)}'),
                      backgroundColor: AppConstants.successColor,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('跟随系统', style: TextStyle(fontSize: 12.sp)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('浅色模式', style: TextStyle(fontSize: 12.sp)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('深色模式', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能设置区域
  Widget _buildFunctionalSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '功能设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 通知设置
          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined, size: 20.sp),
            title: Text('通知', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('接收应用通知和提醒',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableNotifications,
            onChanged: (value) async {
              await appProvider.toggleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启通知' : '已关闭通知'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          
          // 悬浮按钮
          SwitchListTile(
            secondary: Icon(Icons.touch_app_outlined, size: 20.sp),
            title: Text('悬浮按钮', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('显示应用悬浮操作按钮',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableFloatingButton,
            onChanged: (value) async {
              await appProvider.toggleFloatingButton();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启悬浮按钮' : '已关闭悬浮按钮'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          
          // 触觉反馈
          SwitchListTile(
            secondary: Icon(Icons.vibration_outlined, size: 20.sp),
            title: Text('触觉反馈', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('操作时提供触觉反馈',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableHapticFeedback,
            onChanged: (value) async {
              final newSettings = appProvider.appSettings.copyWith(enableHapticFeedback: value);
              await appProvider.updateAppSettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启触觉反馈' : '已关闭触觉反馈'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          
          // 开机自启
          SwitchListTile(
            secondary: Icon(Icons.power_settings_new_outlined, size: 20.sp),
            title: Text('开机自启', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('系统启动时自动运行应用',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.appSettings.enableAutoStart,
            onChanged: (value) async {
              final newSettings = appProvider.appSettings.copyWith(enableAutoStart: value);
              await appProvider.updateAppSettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启开机自启' : '已关闭开机自启'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建隐私设置区域
  Widget _buildPrivacySection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '隐私设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 数据收集
          SwitchListTile(
            secondary: Icon(Icons.analytics_outlined, size: 20.sp),
            title: Text('数据收集', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('允许收集使用数据用于改进服务',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableDataCollection,
            onChanged: (value) async {
              final newSettings = appProvider.privacySettings.copyWith(enableDataCollection: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已允许数据收集' : '已禁止数据收集'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          
          // 统计分析
          SwitchListTile(
            secondary: Icon(Icons.insights_outlined, size: 20.sp),
            title: Text('统计分析', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('允许发送匿名的使用统计数据',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableAnalytics,
            onChanged: (value) async {
              final newSettings = appProvider.privacySettings.copyWith(enableAnalytics: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启统计分析' : '已关闭统计分析'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          
          // 崩溃报告
          SwitchListTile(
            secondary: Icon(Icons.bug_report_outlined, size: 20.sp),
            title: Text('崩溃报告', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('自动发送崩溃报告帮助改进应用',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            value: appProvider.privacySettings.enableCrashReporting,
            onChanged: (value) async {
              final newSettings = appProvider.privacySettings.copyWith(enableCrashReporting: value);
              await appProvider.updatePrivacySettings(newSettings);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '已开启崩溃报告' : '已关闭崩溃报告'),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建其他设置区域
  Widget _buildOtherSection(AppProvider appProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.more_horiz_outlined,
                color: AppConstants.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '其他',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 导出配置
          ListTile(
            leading: Icon(Icons.upload_outlined, size: 20.sp),
            title: Text('导出配置', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('将应用配置导出为文件',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _exportConfig(appProvider);
            },
          ),
          
          // 导入配置
          ListTile(
            leading: Icon(Icons.download_outlined, size: 20.sp),
            title: Text('导入配置', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('从文件导入应用配置',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _importConfig(appProvider);
            },
          ),
          
          // 重置设置
          ListTile(
            leading: Icon(Icons.restore_outlined, size: 20.sp, color: AppConstants.errorColor),
            title: Text('重置设置', style: TextStyle(fontSize: 14.sp, color: AppConstants.errorColor)),
            subtitle: Text('恢复所有设置为默认值',
                         style: TextStyle(fontSize: 12.sp, color: AppConstants.textSecondaryColor)),
            trailing: Icon(Icons.chevron_right, size: 20.sp),
            onTap: () {
              _showResetDialog(appProvider);
            },
          ),
        ],
      ),
    );
  }

  /// 获取主题模式文本
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  /// 导出配置
  void _exportConfig(AppProvider appProvider) async {
    try {
      final config = appProvider.exportConfig();
      
      // 显示导出成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置导出成功'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败：$e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  /// 导入配置
  void _importConfig(AppProvider appProvider) async {
    // 这里应该实现文件选择和导入逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中，敬请期待'),
        backgroundColor: AppConstants.infoColor,
      ),
    );
  }

  /// 显示重置对话框
  void _showResetDialog(AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('这将恢复所有设置为默认值，操作不可撤销。是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await appProvider.resetToDefault();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('重置成功'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('重置失败：$e'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: const Center(
        child: Text('关于页面 - 开发中'),
      ),
    );
  }
}