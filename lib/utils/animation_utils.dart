import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// UI动画工具类 - 提供流畅的动画效果
class AnimationUtils {
  /// 默认动画时长
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration slowDuration = Duration(milliseconds: 500);
  
  /// 默认曲线
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.decelerate;
  
  /// 创建页面转场动画
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    PageTransitionType transitionType = PageTransitionType.slideFromRight,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          transitionType: transitionType,
          curve: curve,
        );
      },
    );
  }
  
  /// 构建页面转场效果
  static Widget _buildPageTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required PageTransitionType transitionType,
    required Curve curve,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );
    
    switch (transitionType) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
        
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );
        
      case PageTransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.rotation:
        return RotationTransition(
          turns: curvedAnimation,
          child: child,
        );
        
      case PageTransitionType.size:
        return SizeTransition(
          sizeFactor: curvedAnimation,
          child: child,
        );
        
      case PageTransitionType.sharedAxis:
        return SharedAxisTransition(
          animation: curvedAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
    }
  }
  
  /// 创建弹性入场动画
  static Widget createBounceInAnimation({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// 创建淡入动画
  static Widget createFadeInAnimation({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  /// 创建滑入动画
  static Widget createSlideInAnimation({
    required Widget child,
    SlideDirection direction = SlideDirection.fromBottom,
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    Offset beginOffset;
    
    switch (direction) {
      case SlideDirection.fromTop:
        beginOffset = const Offset(0.0, -1.0);
        break;
      case SlideDirection.fromBottom:
        beginOffset = const Offset(0.0, 1.0);
        break;
      case SlideDirection.fromLeft:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromRight:
        beginOffset = const Offset(1.0, 0.0);
        break;
    }
    
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(
            offset.dx * MediaQuery.of(context).size.width,
            offset.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// 创建交错列表动画
  static Widget createStaggeredListAnimation({
    required Widget child,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 100),
    Duration duration = defaultDuration,
  }) {
    final delay = baseDelay * index;
    
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutBack,
      transform: Matrix4.identity()
        ..translate(0.0, index * 10.0)
        ..scale(0.95 + (index * 0.01)),
      child: child,
    );
  }
  
  /// 创建脉冲动画
  static Widget createPulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        // 循环动画需要状态管理，这里简化处理
      },
      child: child,
    );
  }
  
  /// 创建摇摆动画
  static Widget createShakeAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 5.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -offset, end: offset),
      duration: duration,
      curve: Curves.elasticInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// 创建翻转动画
  static Widget createFlipAnimation({
    required Widget child,
    Duration duration = defaultDuration,
    Axis axis = Axis.horizontal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        if (axis == Axis.horizontal) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 3.14159),
            child: child,
          );
        } else {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(value * 3.14159),
            child: child,
          );
        }
      },
      child: child,
    );
  }
  
  /// 创建波纹效果
  static Widget createRippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    double radius = 28.0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: rippleColor?.withOpacity(0.3),
        highlightColor: rippleColor?.withOpacity(0.1),
        child: child,
      ),
    );
  }
  
  /// 创建加载动画
  static Widget createLoadingAnimation({
    Color? color,
    double size = 20.0,
    LoadingType type = LoadingType.circular,
  }) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.blue,
            ),
          ),
        );
        
      case LoadingType.linear:
        return SizedBox(
          width: size * 3,
          height: 4.0,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.blue,
            ),
          ),
        );
        
      case LoadingType.dots:
        return _DotsLoadingAnimation(
          color: color ?? Colors.blue,
          size: size,
        );
        
      case LoadingType.wave:
        return _WaveLoadingAnimation(
          color: color ?? Colors.blue,
          size: size,
        );
    }
  }
  
  /// 创建Hero动画
  static Widget createHeroAnimation({
    required String tag,
    required Widget child,
    CreateRectTween? createRectTween,
  }) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween,
      child: child,
    );
  }
}

/// 页面转场类型
enum PageTransitionType {
  fade,
  scale,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  rotation,
  size,
  sharedAxis,
}

/// 滑入方向
enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

/// 加载动画类型
enum LoadingType {
  circular,
  linear,
  dots,
  wave,
}

/// 点状加载动画
class _DotsLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;
  
  const _DotsLoadingAnimation({
    required this.color,
    required this.size,
  });
  
  @override
  State<_DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<_DotsLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = (_controller.value - (index * 0.2)) % 1.0;
              final scale = 0.5 + (0.5 * (1.0 - (value - 0.5).abs() * 2));
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 波浪加载动画
class _WaveLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;
  
  const _WaveLoadingAnimation({
    required this.color,
    required this.size,
  });
  
  @override
  State<_WaveLoadingAnimation> createState() => _WaveLoadingAnimationState();
}

class _WaveLoadingAnimationState extends State<_WaveLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = (_controller.value - (index * 0.1)) % 1.0;
              final height = widget.size * (0.3 + 0.7 * (0.5 + 0.5 * 
                  (value < 0.5 ? value * 2 : (1.0 - value) * 2)));
              
              return Container(
                width: widget.size * 0.1,
                height: height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size * 0.05),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 动画组合器
class AnimationComposer {
  static Widget composeAnimations({
    required Widget child,
    List<AnimationEffect> effects = const [],
    Duration totalDuration = AnimationUtils.defaultDuration,
  }) {
    Widget result = child;
    
    for (final effect in effects) {
      switch (effect.type) {
        case AnimationEffectType.fadeIn:
          result = AnimationUtils.createFadeInAnimation(
            child: result,
            duration: effect.duration ?? totalDuration,
            curve: effect.curve ?? AnimationUtils.defaultCurve,
          );
          break;
          
        case AnimationEffectType.slideIn:
          result = AnimationUtils.createSlideInAnimation(
            child: result,
            direction: effect.slideDirection ?? SlideDirection.fromBottom,
            duration: effect.duration ?? totalDuration,
            curve: effect.curve ?? AnimationUtils.defaultCurve,
          );
          break;
          
        case AnimationEffectType.bounceIn:
          result = AnimationUtils.createBounceInAnimation(
            child: result,
            duration: effect.duration ?? totalDuration,
          );
          break;
          
        case AnimationEffectType.scale:
          result = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: effect.duration ?? totalDuration,
            curve: effect.curve ?? AnimationUtils.defaultCurve,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: result,
          );
          break;
      }
    }
    
    return result;
  }
}

/// 动画效果配置
class AnimationEffect {
  final AnimationEffectType type;
  final Duration? duration;
  final Curve? curve;
  final SlideDirection? slideDirection;
  
  const AnimationEffect({
    required this.type,
    this.duration,
    this.curve,
    this.slideDirection,
  });
}

/// 动画效果类型
enum AnimationEffectType {
  fadeIn,
  slideIn,
  bounceIn,
  scale,
}