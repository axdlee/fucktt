import 'package:flutter/material.dart';
import '../services/test_service.dart';
import '../constants/app_constants.dart';

/// 功能测试页面 - 运行和展示测试结果
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  TestSummary? _testSummary;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 运行所有测试
  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testSummary = null;
    });

    _animationController.repeat();

    try {
      final summary = await TestService.runAllTests();
      setState(() {
        _testSummary = summary;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试执行失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _animationController.stop();
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// 清理测试数据
  Future<void> _cleanupTestData() async {
    try {
      await TestService.cleanupTestData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('测试数据清理完成'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清理失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能测试'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRunning ? null : _cleanupTestData,
            icon: const Icon(Icons.cleaning_services),
            tooltip: '清理测试数据',
          ),
        ],
      ),
      body: Column(
        children: [
          // 测试控制面板
          _buildControlPanel(),
          
          // 测试结果展示
          Expanded(
            child: _buildTestResults(),
          ),
        ],
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.padding),
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '测试控制',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          
          if (_isRunning) ...[
            Row(
              children: [
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: const Icon(
                        Icons.refresh,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSizes.spacing),
                const Text('正在运行测试...'),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runAllTests,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('运行所有测试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.padding,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (_testSummary != null) ...[
            const SizedBox(height: AppSizes.spacing),
            _buildTestSummaryCard(),
          ],
        ],
      ),
    );
  }

  /// 构建测试总结卡片
  Widget _buildTestSummaryCard() {
    final summary = _testSummary!;
    final successRate = summary.successRate;
    
    Color statusColor;
    IconData statusIcon;
    
    if (successRate >= 0.9) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (successRate >= 0.7) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: AppSizes.spacing),
              Text(
                '测试完成',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总数', summary.totalCount.toString()),
              _buildStatItem('通过', summary.passedCount.toString()),
              _buildStatItem('失败', summary.failedCount.toString()),
              _buildStatItem('成功率', '${(successRate * 100).toStringAsFixed(1)}%'),
            ],
          ),
          
          const SizedBox(height: AppSizes.spacing),
          
          LinearProgressIndicator(
            value: successRate,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          
          const SizedBox(height: AppSizes.spacing / 2),
          
          Text(
            '耗时: ${summary.totalDuration.inMilliseconds}ms',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// 构建测试结果列表
  Widget _buildTestResults() {
    if (_testSummary == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: AppSizes.padding),
            Text(
              '点击上方按钮开始测试',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final results = _testSummary!.results;
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildTestResultItem(result);
      },
    );
  }

  /// 构建单个测试结果项
  Widget _buildTestResultItem(TestResult result) {
    final isSuccess = result.passed;
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          result.name,
          style: TextStyle(
            color: isSuccess ? null : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '耗时: ${result.duration.inMilliseconds}ms',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          if (result.error != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSizes.padding),
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '错误信息:',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing / 2),
                  Text(
                    result.error!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isSuccess) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSizes.padding),
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: AppSizes.spacing),
                  Text(
                    '测试通过',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 测试菜单项组件
class TestMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const TestMenuItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.spacing / 2,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: enabled 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? null : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled ? null : Colors.grey,
          ),
        ),
        trailing: enabled
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}