import 'package:flutter/services.dart';
import 'dart:developer';
import '../models/behavior_model.dart';
import '../services/content_capture_service.dart';

/// 悬浮操作服务 - 管理悬浮窗和快捷操作
class FloatingActionService {
  static const MethodChannel _channel = MethodChannel('value_filter/floating_action');
  
  static FloatingActionService? _instance;
  static FloatingActionService get instance => _instance ??= FloatingActionService._();
  
  FloatingActionService._();
  
  bool _isFloatingWindowShown = false;
  Function(String actionType, Map<String, dynamic> data)? _onActionCallback;
  
  /// 显示悬浮窗
  Future<bool> showFloatingWindow() async {
    try {
      final result = await _channel.invokeMethod('showFloatingWindow');
      _isFloatingWindowShown = result as bool? ?? false;
      
      if (_isFloatingWindowShown) {
        _channel.setMethodCallHandler(_handleMethodCall);
      }
      
      return _isFloatingWindowShown;
    } catch (e) {
      log('显示悬浮窗失败: $e');
      return false;
    }
  }
  
  /// 隐藏悬浮窗
  Future<void> hideFloatingWindow() async {
    try {
      await _channel.invokeMethod('hideFloatingWindow');
      _isFloatingWindowShown = false;
      _channel.setMethodCallHandler(null);
    } catch (e) {
      log('隐藏悬浮窗失败: $e');
    }
  }
  
  /// 更新悬浮窗位置
  Future<void> updateFloatingWindowPosition(double x, double y) async {
    try {
      await _channel.invokeMethod('updatePosition', {
        'x': x,
        'y': y,
      });
    } catch (e) {
      log('更新悬浮窗位置失败: $e');
    }
  }
  
  /// 更新悬浮窗透明度
  Future<void> updateFloatingWindowOpacity(double opacity) async {
    try {
      await _channel.invokeMethod('updateOpacity', {
        'opacity': opacity,
      });
    } catch (e) {
      log('更新悬浮窗透明度失败: $e');
    }
  }
  
  /// 显示快捷菜单
  Future<void> showQuickMenu() async {
    try {
      await _channel.invokeMethod('showQuickMenu');
    } catch (e) {
      log('显示快捷菜单失败: $e');
    }
  }
  
  /// 隐藏快捷菜单
  Future<void> hideQuickMenu() async {
    try {
      await _channel.invokeMethod('hideQuickMenu');
    } catch (e) {
      log('隐藏快捷菜单失败: $e');
    }
  }
  
  /// 执行举报操作
  Future<void> reportContent(String contentText, ReportReason reason) async {
    try {
      await _channel.invokeMethod('reportContent', {
        'contentText': contentText,
        'reason': reason.index,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 触发回调
      _onActionCallback?.call('report', {
        'contentText': contentText,
        'reason': reason,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      log('举报内容失败: $e');
    }
  }
  
  /// 执行屏蔽操作
  Future<void> blockContent(String contentText, BlockType blockType) async {
    try {
      await _channel.invokeMethod('blockContent', {
        'contentText': contentText,
        'blockType': blockType.index,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 触发回调
      _onActionCallback?.call('block', {
        'contentText': contentText,
        'blockType': blockType,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      log('屏蔽内容失败: $e');
    }
  }
  
  /// 执行标记操作
  Future<void> markContent(String contentText, MarkType markType) async {
    try {
      await _channel.invokeMethod('markContent', {
        'contentText': contentText,
        'markType': markType.index,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 触发回调
      _onActionCallback?.call('mark', {
        'contentText': contentText,
        'markType': markType,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      log('标记内容失败: $e');
    }
  }
  
  /// 获取当前屏幕内容
  Future<String?> getCurrentContent() async {
    try {
      final contents = await ContentCaptureService.instance.analyzeScreen();
      if (contents.isNotEmpty) {
        return contents.map((content) => content.text).join('\n');
      }
      return null;
    } catch (e) {
      log('获取当前内容失败: $e');
      return null;
    }
  }
  
  /// 设置操作回调
  void setActionCallback(Function(String actionType, Map<String, dynamic> data) callback) {
    _onActionCallback = callback;
  }
  
  /// 处理原生方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onFloatingButtonClicked':
        await _handleFloatingButtonClick();
        break;
      case 'onQuickActionSelected':
        final args = call.arguments as Map<dynamic, dynamic>;
        await _handleQuickAction(args['action'] as String);
        break;
      case 'onPositionChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final x = args['x'] as double;
        final y = args['y'] as double;
        _onActionCallback?.call('positionChanged', {'x': x, 'y': y});
        break;
      default:
        log('未知的方法调用: ${call.method}');
    }
  }
  
  /// 处理悬浮按钮点击
  Future<void> _handleFloatingButtonClick() async {
    try {
      await showQuickMenu();
    } catch (e) {
      log('处理悬浮按钮点击失败: $e');
    }
  }
  
  /// 处理快捷操作
  Future<void> _handleQuickAction(String action) async {
    try {
      final currentContent = await getCurrentContent();
      
      switch (action) {
        case 'report':
          await _showReportDialog(currentContent);
          break;
        case 'block':
          await _showBlockDialog(currentContent);
          break;
        case 'mark_like':
          if (currentContent != null) {
            await markContent(currentContent, MarkType.like);
          }
          break;
        case 'mark_dislike':
          if (currentContent != null) {
            await markContent(currentContent, MarkType.dislike);
          }
          break;
        case 'settings':
          _onActionCallback?.call('openSettings', {});
          break;
        default:
          log('未知的快捷操作: $action');
      }
    } catch (e) {
      log('处理快捷操作失败: $e');
    }
  }
  
  /// 显示举报对话框
  Future<void> _showReportDialog(String? content) async {
    if (content == null) return;
    
    try {
      await _channel.invokeMethod('showReportDialog', {
        'content': content,
        'reasons': ReportReason.values.map((r) => r.description).toList(),
      });
    } catch (e) {
      log('显示举报对话框失败: $e');
    }
  }
  
  /// 显示屏蔽对话框
  Future<void> _showBlockDialog(String? content) async {
    if (content == null) return;
    
    try {
      await _channel.invokeMethod('showBlockDialog', {
        'content': content,
        'types': BlockType.values.map((t) => t.description).toList(),
      });
    } catch (e) {
      log('显示屏蔽对话框失败: $e');
    }
  }
  
  /// 检查悬浮窗状态
  bool get isFloatingWindowShown => _isFloatingWindowShown;
  
  /// 检查是否支持悬浮窗
  Future<bool> isFloatingWindowSupported() async {
    try {
      final result = await _channel.invokeMethod('isSupported');
      return result as bool? ?? false;
    } catch (e) {
      log('检查悬浮窗支持失败: $e');
      return false;
    }
  }
}

/// 举报原因
enum ReportReason {
  inappropriate,  // 内容不当
  spam,          // 垃圾信息
  harassment,    // 骚扰
  fakeNews,      // 虚假信息
  copyright,     // 版权侵犯
  violence,      // 暴力内容
  other,         // 其他
}

extension ReportReasonExtension on ReportReason {
  String get description {
    switch (this) {
      case ReportReason.inappropriate:
        return '内容不当';
      case ReportReason.spam:
        return '垃圾信息';
      case ReportReason.harassment:
        return '骚扰信息';
      case ReportReason.fakeNews:
        return '虚假信息';
      case ReportReason.copyright:
        return '版权侵犯';
      case ReportReason.violence:
        return '暴力内容';
      case ReportReason.other:
        return '其他原因';
    }
  }
}

/// 屏蔽类型
enum BlockType {
  temporary,  // 临时屏蔽
  permanent,  // 永久屏蔽
  author,     // 屏蔽作者
  topic,      // 屏蔽话题
}

extension BlockTypeExtension on BlockType {
  String get description {
    switch (this) {
      case BlockType.temporary:
        return '临时屏蔽';
      case BlockType.permanent:
        return '永久屏蔽';
      case BlockType.author:
        return '屏蔽作者';
      case BlockType.topic:
        return '屏蔽话题';
    }
  }
}

/// 标记类型
enum MarkType {
  like,     // 喜欢
  dislike,  // 不喜欢
  bookmark, // 书签
  share,    // 分享
}

extension MarkTypeExtension on MarkType {
  String get description {
    switch (this) {
      case MarkType.like:
        return '喜欢';
      case MarkType.dislike:
        return '不喜欢';
      case MarkType.bookmark:
        return '收藏';
      case MarkType.share:
        return '分享';
    }
  }
  
  BehaviorType get behaviorType {
    switch (this) {
      case MarkType.like:
        return BehaviorType.like;
      case MarkType.dislike:
        return BehaviorType.dislike;
      case MarkType.bookmark:
        return BehaviorType.bookmark;
      case MarkType.share:
        return BehaviorType.share;
    }
  }
}