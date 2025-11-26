import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';

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
      log('加载Prompt模板失败: $e');
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
      log('保存Prompt模板失败: $e');
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
    final enabledCount =
        _promptTemplates.where((p) => p['enabled'] as bool).length;
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
          color:
              isEnabled ? AppConstants.primaryColor : AppConstants.dividerColor,
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
                        Icon(Icons.delete_outline,
                            size: 16.sp, color: AppConstants.errorColor),
                        SizedBox(width: 8.w),
                        Text('删除',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppConstants.errorColor)),
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
    final categoryController =
        TextEditingController(text: prompt?['category'] ?? '');
    final descriptionController =
        TextEditingController(text: prompt?['description'] ?? '');
    final templateController =
        TextEditingController(text: prompt?['template'] ?? '');

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
                'id': prompt?['id'] ??
                    'prompt_${DateTime.now().millisecondsSinceEpoch}',
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
            child: const Text('删除',
                style: TextStyle(color: AppConstants.errorColor)),
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