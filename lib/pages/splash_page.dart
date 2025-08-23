import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../services/performance_service.dart';
import '../providers/app_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/values_provider.dart';
import '../providers/content_provider.dart';

/// 应用启动页面 - 展示启动动画和初始化数据
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isInitializing = true;
  String _currentTask = '正在启动应用...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// 设置动画
  void _setupAnimations() {
    // Logo动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 文字动画控制器
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Logo缩放动画
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    // Logo透明度动画
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    // 文字透明度动画
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    // 文字滑动动画
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
    
    // 进度动画
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  /// 开始初始化
  Future<void> _startInitialization() async {
    // 启动Logo动画
    await _logoController.forward();
    
    // 延迟一下再启动文字动画
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
    
    // 开始初始化任务
    await _initializeApp();
    
    // 完成后跳转到主页
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      final tasks = [
        ('正在初始化存储服务...', _initializeStorage),
        ('正在加载用户配置...', _initializeAppProvider),
        ('正在连接AI服务...', _initializeAIProvider),
        ('正在加载价值观配置...', _initializeValuesProvider),
        ('正在准备内容分析...', _initializeContentProvider),
        ('正在预加载数据...', _preloadData),
        ('正在优化性能...', _optimizePerformance),
      ];
      
      for (int i = 0; i < tasks.length; i++) {
        final (taskName, taskFunction) = tasks[i];
        
        setState(() {
          _currentTask = taskName;
          _progress = i / tasks.length;
        });
        
        _progressController.animateTo(_progress);
        
        await taskFunction();
        
        // 添加小延迟让用户看到进度
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      setState(() {
        _currentTask = '启动完成！';
        _progress = 1.0;
        _isInitializing = false;
      });
      
      _progressController.animateTo(1.0);
      
      // 等待动画完成
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      setState(() {
        _currentTask = '启动失败: $e';
        _isInitializing = false;
      });
      
      // 错误情况下延迟更长时间
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// 初始化存储服务
  Future<void> _initializeStorage() async {
    // 存储服务在main中已初始化，这里可以做额外检查
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// 初始化应用Provider
  Future<void> _initializeAppProvider() async {
    final appProvider = context.read<AppProvider>();
    if (!appProvider.isInitialized) {
      await appProvider.initialize();
    }
  }

  /// 初始化AI Provider
  Future<void> _initializeAIProvider() async {
    final aiProvider = context.read<AIProvider>();
    if (!aiProvider.isInitialized) {
      await aiProvider.initialize();
    }
  }

  /// 初始化价值观Provider
  Future<void> _initializeValuesProvider() async {
    final valuesProvider = context.read<ValuesProvider>();
    if (!valuesProvider.isInitialized) {
      await valuesProvider.initialize();
    }
  }

  /// 初始化内容Provider
  Future<void> _initializeContentProvider() async {
    final contentProvider = context.read<ContentProvider>();
    if (!contentProvider.isInitialized) {
      await contentProvider.initialize();
    }
  }

  /// 预加载数据
  Future<void> _preloadData() async {
    await PerformanceService().preloadData();
  }

  /// 优化性能
  Future<void> _optimizePerformance() async {
    // 清理不必要的缓存
    PerformanceService().clearAllCache();
    
    // 等待垃圾回收
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FBFF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo区域
              _buildLogoSection(),
              
              const Spacer(),
              
              // 进度指示器区域
              _buildProgressSection(),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Logo区域
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo动画
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Opacity(
                opacity: _logoOpacityAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // 应用名称动画
        AnimatedBuilder(
          animation: _textController,
          builder: (context, child) {
            return SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _textOpacityAnimation,
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '智能内容过滤 · 价值观守护',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建进度区域
  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // 当前任务文本
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _currentTask,
              key: ValueKey(_currentTask),
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 进度条
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.accentColor,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // 进度百分比
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppConstants.textTertiaryColor,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}