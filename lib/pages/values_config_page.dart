import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/values_provider.dart';
import '../models/value_template_model.dart';
import '../constants/app_constants.dart';
import '../widgets/app_card.dart';
import '../widgets/value_template_card.dart';
import '../widgets/add_value_dialog.dart';

/// 价值观配置页面
class ValuesConfigPage extends StatefulWidget {
  const ValuesConfigPage({super.key});

  @override
  State<ValuesConfigPage> createState() => _ValuesConfigPageState();
}

class _ValuesConfigPageState extends State<ValuesConfigPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          '价值观配置',
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
            onPressed: () => _showAddValueDialog(),
            tooltip: '添加价值观',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.textSecondaryColor,
          indicatorColor: AppConstants.primaryColor,
          tabs: const [
            Tab(text: '我的价值观'),
            Tab(text: '模板库'),
            Tab(text: '个人档案'),
          ],
        ),
      ),
      body: Consumer<ValuesProvider>(
        builder: (context, valuesProvider, child) {
          if (valuesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMyValuesTab(valuesProvider),
              _buildTemplatesTab(valuesProvider),
              _buildProfileTab(valuesProvider),
            ],
          );
        },
      ),
    );
  }

  /// 构建我的价值观标签页
  Widget _buildMyValuesTab(ValuesProvider valuesProvider) {
    return Column(
      children: [
        // 搜索和筛选栏
        _buildSearchAndFilter(),
        
        // 价值观列表
        Expanded(
          child: _buildValuesList(valuesProvider.enabledTemplates),
        ),
      ],
    );
  }

  /// 构建模板库标签页
  Widget _buildTemplatesTab(ValuesProvider valuesProvider) {
    final categories = valuesProvider.templatesByCategory;
    
    return Column(
      children: [
        _buildSearchAndFilter(),
        
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.keys.elementAt(index);
              final templates = categories[category]!;
              
              return _buildCategorySection(category, templates);
            },
          ),
        ),
      ],
    );
  }

  /// 构建个人档案标签页
  Widget _buildProfileTab(ValuesProvider valuesProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价值观分析报告
          _buildAnalysisReport(valuesProvider),
          
          SizedBox(height: 16.h),
          
          // 黑白名单管理
          _buildBlackWhiteListSection(valuesProvider),
          
          SizedBox(height: 16.h),
          
          // 导入导出功能
          _buildImportExportSection(valuesProvider),
        ],
      ),
    );
  }

  /// 构建搜索和筛选栏
  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索价值观模板...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppConstants.dividerColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          SizedBox(height: 12.h),
          
          // 分类筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                '全部',
                ...AppConstants.valueCategories,
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppConstants.primaryColor.withOpacity(0.1),
                    checkmarkColor: AppConstants.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建价值观列表
  Widget _buildValuesList(List<ValueTemplateModel> templates) {
    var filteredTemplates = templates;
    
    // 应用搜索筛选
    if (_searchQuery.isNotEmpty) {
      filteredTemplates = templates.where((template) {
        return template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // 应用分类筛选
    if (_selectedCategory != '全部') {
      filteredTemplates = filteredTemplates.where((template) {
        return template.category == _selectedCategory;
      }).toList();
    }
    
    if (filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: AppConstants.textTertiaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              '没有找到匹配的价值观模板',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _showAddValueDialog(),
              child: const Text('创建新的价值观'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ValueTemplateCard(
            template: template,
            onToggle: () => _toggleTemplate(template.id),
            onEdit: () => _editTemplate(template),
            onDelete: template.isCustom ? () => _deleteTemplate(template.id) : null,
            onWeightChanged: (weight) => _updateWeight(template.id, weight),
          ),
        );
      },
    );
  }

  /// 构建分类区域
  Widget _buildCategorySection(String category, List<ValueTemplateModel> templates) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                color: AppConstants.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                '${templates.length}个模板',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          ...templates.map((template) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: ValueTemplateCard(
              template: template,
              compact: true,
              onToggle: () => _toggleTemplate(template.id),
              onEdit: () => _editTemplate(template),
              onDelete: template.isCustom ? () => _deleteTemplate(template.id) : null,
            ),
          )),
        ],
      ),
    );
  }

  /// 构建分析报告
  Widget _buildAnalysisReport(ValuesProvider valuesProvider) {
    final report = valuesProvider.getValueAnalysisReport();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '价值观分析报告',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          _buildReportItem('总模板数', '${report['totalTemplates']}'),
          _buildReportItem('已启用', '${report['enabledTemplates']}'),
          _buildReportItem('自定义模板', '${report['customTemplates']}'),
          _buildReportItem('覆盖分类', '${report['categories']}'),
          
          if (report['lastUpdated'] != null) ..[
            SizedBox(height: 8.h),
            Text(
              '最后更新: ${_formatDateTime(report['lastUpdated'])}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textTertiaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建报告项
  Widget _buildReportItem(String label, String value) {
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
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建黑白名单区域
  Widget _buildBlackWhiteListSection(ValuesProvider valuesProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '黑白名单管理',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildKeywordsList(
                  title: '黑名单',
                  keywords: valuesProvider.userProfile?.blacklist ?? [],
                  color: AppConstants.errorColor,
                  onAdd: (keyword) => valuesProvider.addBlacklistKeyword(keyword),
                  onRemove: (keyword) => valuesProvider.removeBlacklistKeyword(keyword),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: _buildKeywordsList(
                  title: '白名单',
                  keywords: valuesProvider.userProfile?.whitelist ?? [],
                  color: AppConstants.successColor,
                  onAdd: (keyword) => valuesProvider.addWhitelistKeyword(keyword),
                  onRemove: (keyword) => valuesProvider.removeWhitelistKeyword(keyword),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建关键词列表
  Widget _buildKeywordsList({
    required String title,
    required List<String> keywords,
    required Color color,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add, size: 16.sp),
              onPressed: () => _showAddKeywordDialog(title, onAdd),
              constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        if (keywords.isEmpty)
          Text(
            '暂无关键词',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppConstants.textTertiaryColor,
            ),
          )
        else
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: keywords.map((keyword) {
              return Chip(
                label: Text(
                  keyword,
                  style: TextStyle(fontSize: 11.sp),
                ),
                deleteIcon: Icon(Icons.close, size: 14.sp),
                onDeleted: () => onRemove(keyword),
                backgroundColor: color.withOpacity(0.1),
                deleteIconColor: color,
              );
            }).toList(),
          ),
      ],
    );
  }

  /// 构建导入导出区域
  Widget _buildImportExportSection(ValuesProvider valuesProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '配置管理',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportValues(valuesProvider),
                  icon: const Icon(Icons.upload),
                  label: const Text('导出配置'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importValues(valuesProvider),
                  icon: const Icon(Icons.download),
                  label: const Text('导入配置'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '政治立场':
        return Icons.account_balance;
      case '社会价值':
        return Icons.group;
      case '经济观念':
        return Icons.trending_up;
      case '文化认同':
        return Icons.language;
      case '环保意识':
        return Icons.eco;
      case '生活方式':
        return Icons.home;
      case '道德观念':
        return Icons.favorite;
      case '教育理念':
        return Icons.school;
      default:
        return Icons.label;
    }
  }

  /// 切换模板状态
  void _toggleTemplate(String templateId) {
    final valuesProvider = context.read<ValuesProvider>();
    valuesProvider.toggleTemplate(templateId);
  }

  /// 更新权重
  void _updateWeight(String templateId, double weight) {
    final valuesProvider = context.read<ValuesProvider>();
    valuesProvider.setTemplateWeight(templateId, weight);
  }

  /// 编辑模板
  void _editTemplate(ValueTemplateModel template) {
    // TODO: 实现编辑模板对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑价值观'),
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

  /// 删除模板
  void _deleteTemplate(String templateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除价值观'),
        content: const Text('确定要删除这个价值观模板吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final valuesProvider = context.read<ValuesProvider>();
              valuesProvider.removeTemplate(templateId);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示添加价值观对话框
  void _showAddValueDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddValueDialog(),
    );
  }

  /// 显示添加关键词对话框
  void _showAddKeywordDialog(String type, Function(String) onAdd) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加$type关键词'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入关键词',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重置为默认'),
              onTap: () {
                Navigator.pop(context);
                _resetToDefault();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('使用帮助'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 导出价值观配置
  void _exportValues(ValuesProvider valuesProvider) {
    // TODO: 实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中...')),
    );
  }

  /// 导入价值观配置
  void _importValues(ValuesProvider valuesProvider) {
    // TODO: 实现导入功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能开发中...')),
    );
  }

  /// 重置为默认
  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置为默认'),
        content: const Text('确定要重置所有价值观配置为默认设置吗？这将清除所有自定义配置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现重置功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('重置功能开发中...')),
              );
            },
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  /// 显示帮助
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: const SingleChildScrollView(
          child: Text(
            '价值观配置帮助：\n\n'
            '1. 在"我的价值观"中管理已启用的价值观模板\n'
            '2. 在"模板库"中浏览和添加新的价值观模板\n'
            '3. 在"个人档案"中查看分析报告和管理黑白名单\n\n'
            '• 滑动调节权重来改变价值观的重要性\n'
            '• 使用黑名单屏蔽不想看到的内容\n'
            '• 使用白名单确保重要内容不被过滤',
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
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '未知';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '格式错误';
    }
  }
}