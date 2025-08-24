import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/content_provider.dart';
import '../providers/values_provider.dart';
import '../providers/ai_provider.dart';
import '../models/behavior_model.dart';
import '../widgets/app_card.dart';

/// 价值观过滤模拟测试页面
/// 用于测试完整的内容分析和过滤流程
class FilterSimulationPage extends StatefulWidget {
  const FilterSimulationPage({super.key});

  @override
  State<FilterSimulationPage> createState() => _FilterSimulationPageState();
}

class _FilterSimulationPageState extends State<FilterSimulationPage> {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 模拟的今日头条内容样本
  final List<Map<String, String>> _sampleContents = [
    {
      'title': '正能量新闻',
      'content': '某地志愿者团队连续三年为贫困山区儿童送书籍，累计帮助2000多名孩子接受教育。这个由年轻人组成的团队，用实际行动诠释了什么是奉献精神。',
      'type': '社会新闻',
    },
    {
      'title': '科技创新',
      'content': '中国科研团队在量子计算领域取得重大突破，新技术有望在未来5年内实现商业化应用，为人类科技进步做出重要贡献。',
      'type': '科技新闻',
    },
    {
      'title': '争议内容',
      'content': '网络上某明星又爆出丑闻，各种小道消息满天飞。粉丝和黑粉在评论区激烈对骂，场面一度失控。这种低俗八卦严重污染网络环境。',
      'type': '娱乐八卦',
    },
    {
      'title': '负面情绪',
      'content': '现在的年轻人真是一代不如一代，整天只知道玩手机，没有任何上进心。社会风气越来越差，到处都是负能量，让人看不到希望。',
      'type': '社会评论',
    },
    {
      'title': '教育价值',
      'content': '清华大学教授分享学习方法：阅读是提升思维能力的最佳途径。他建议学生每天至少阅读一小时，培养独立思考和批判性思维能力。',
      'type': '教育资讯',
    },
  ];

  @override
  void initState() {
    super.initState();
    _contentController.text = _sampleContents[0]['content']!;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('价值观过滤模拟测试'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测试说明
            _buildTestDescription(),
            SizedBox(height: 24.h),
            
            // 内容输入区域
            _buildContentInputSection(),
            SizedBox(height: 24.h),
            
            // 样本内容选择
            _buildSampleContentSection(),
            SizedBox(height: 24.h),
            
            // 分析按钮
            _buildAnalysisButton(),
            SizedBox(height: 24.h),
            
            // 分析结果显示
            _buildAnalysisResults(),
            SizedBox(height: 24.h),
            
            // 系统状态显示
            _buildSystemStatus(),
          ],
        ),
      ),
    );
  }

  /// 构建测试说明
  Widget _buildTestDescription() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                '功能模拟测试',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '这个测试模拟了完整的今日头条内容价值观过滤流程：\n'
            '1. 📱 内容获取：模拟OCR识别或无障碍服务获取的文本\n'
            '2. 🧠 本地分析：基于用户设定的价值观模板进行初步匹配\n'
            '3. 🤖 AI增强：调用AI服务进行深度语义分析\n'
            '4. ⚖️ 决策过滤：根据分析结果决定显示、警告或屏蔽\n'
            '5. 📊 行为记录：记录用户行为数据以改进AI模型',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容输入区域
  Widget _buildContentInputSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 模拟内容输入',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '输入或选择要分析的内容（模拟从今日头条获取的文本）：',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: '在这里输入要分析的文本内容...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  /// 构建样本内容选择区域
  Widget _buildSampleContentSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 样本内容选择',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '点击下面的样本内容快速测试不同类型的价值观过滤效果：',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(_sampleContents.length, (index) {
            final sample = _sampleContents[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () {
                    setState(() {
                      _contentController.text = sample['content']!;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                sample['type']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                sample['title']!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          sample['content']!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 构建分析按钮
  Widget _buildAnalysisButton() {
    return Consumer3<ContentProvider, ValuesProvider, AIProvider>(
      builder: (context, contentProvider, valuesProvider, aiProvider, child) {
        final isAnalyzing = contentProvider.isAnalyzing;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAnalyzing ? null : () => _performAnalysis(
              contentProvider, 
              valuesProvider, 
              aiProvider,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '正在分析中...',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology),
                      SizedBox(width: 8.w),
                      Text(
                        '🚀 开始价值观分析',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// 构建分析结果显示
  Widget _buildAnalysisResults() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        final results = contentProvider.analysisHistory;
        
        if (results.isEmpty) {
          return AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48.w,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无分析结果',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '点击上方按钮开始分析',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // 显示最新的分析结果
        final latestResult = results.first;
        
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '📊 分析结果',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // 过滤决策
              _buildFilterActionCard(latestResult.recommendedAction),
              SizedBox(height: 12.h),
              
              // 分数显示
              _buildScoreDisplay(latestResult),
              SizedBox(height: 12.h),
              
              // 情感分析
              _buildSentimentAnalysis(latestResult.sentiment),
              SizedBox(height: 12.h),
              
              // 分析详情
              _buildAnalysisDetails(latestResult),
            ],
          ),
        );
      },
    );
  }

  /// 构建过滤动作卡片
  Widget _buildFilterActionCard(FilterAction action) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;
    String description;

    switch (action) {
      case FilterAction.allow:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        text = '✅ 内容通过';
        description = '内容符合用户价值观，正常显示';
        break;
      case FilterAction.warning:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.warning;
        text = '⚠️ 内容警告';
        description = '内容可能存在争议，需要用户判断';
        break;
      case FilterAction.blur:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.blur_on;
        text = '🔍 内容模糊';
        description = '内容被模糊处理，用户可选择查看';
        break;
      case FilterAction.block:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.block;
        text = '🚫 内容屏蔽';
        description = '内容不符合用户价值观，建议屏蔽';
        break;
      case FilterAction.askUser:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        icon = Icons.help;
        text = '❓ 询问用户';
        description = '系统不确定，需要用户决定';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分数显示
  Widget _buildScoreDisplay(dynamic result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '价值观匹配度评分',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '综合评分',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                    value: result.overallScore,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.overallScore >= 0.7
                          ? Colors.green
                          : result.overallScore >= 0.4
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${(result.overallScore * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建情感分析
  Widget _buildSentimentAnalysis(dynamic sentiment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '情感倾向分析',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildSentimentChip('积极', sentiment.positive, Colors.green),
            SizedBox(width: 8.w),
            _buildSentimentChip('消极', sentiment.negative, Colors.red),
            SizedBox(width: 8.w),
            _buildSentimentChip('中性', sentiment.neutral, Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildSentimentChip(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label ${(value * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 12.sp,
          color: color.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建分析详情
  Widget _buildAnalysisDetails(dynamic result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分析详情',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('内容类型', result.contentType.name),
              _buildDetailRow('分析时间', latestResult.analyzedAt.toString().substring(0, 19)),
              _buildDetailRow('AI模型', latestResult.aiProviderId.isNotEmpty ? latestResult.aiProviderId : '本地分析'),
              if (latestResult.extractedTopics.isNotEmpty)
                _buildDetailRow('内容标签', latestResult.extractedTopics.join(', ')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建系统状态
  Widget _buildSystemStatus() {
    return Consumer3<ContentProvider, ValuesProvider, AIProvider>(
      builder: (context, contentProvider, valuesProvider, aiProvider, child) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚙️ 系统状态',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              _buildStatusRow('价值观模板', valuesProvider.templates.length.toString()),
              _buildStatusRow('AI服务', aiProvider.providers.length.toString()),
              _buildStatusRow('分析记录', contentProvider.analysisHistory.length.toString()),
              _buildStatusRow('行为日志', '${contentProvider.analysisHistory.length * 2}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 执行内容分析
  Future<void> _performAnalysis(
    ContentProvider contentProvider,
    ValuesProvider valuesProvider,
    AIProvider aiProvider,
  ) async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入要分析的内容'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // 显示开始分析提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚀 开始价值观分析...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      // 执行内容分析
      final result = await contentProvider.analyzeContent(
        content: content,
        contentType: ContentType.article,
        contentId: DateTime.now().millisecondsSinceEpoch.toString(),
        valuesProvider: valuesProvider,
        aiProvider: aiProvider,
      );

      if (result != null) {
        // 分析成功
        HapticFeedback.lightImpact();
        
        // 滚动到结果区域
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 分析完成！结果：${_getActionText(result.recommendedAction)}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _getActionColor(result.filterAction),
          ),
        );
      } else {
        throw Exception('分析结果为空');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 分析失败：$e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getActionText(FilterAction action) {
    switch (action) {
      case FilterAction.allow:
        return '内容通过';
      case FilterAction.warning:
        return '内容警告';
      case FilterAction.blur:
        return '内容模糊';
      case FilterAction.block:
        return '内容屏蔽';
      case FilterAction.askUser:
        return '询问用户';
    }
  }

  Color _getActionColor(FilterAction action) {
    switch (action) {
      case FilterAction.allow:
        return Colors.green;
      case FilterAction.warning:
        return Colors.orange;
      case FilterAction.blur:
        return Colors.blue;
      case FilterAction.block:
        return Colors.red;
      case FilterAction.askUser:
        return Colors.purple;
    }
  }
}