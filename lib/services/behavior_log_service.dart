import '../models/behavior_model.dart';
import 'storage_service.dart';

/// 行为日志服务 - 管理用户行为数据的记录和查询
class BehaviorLogService {
  
  /// 记录用户行为
  static Future<void> logBehavior({
    required String userId,
    required BehaviorType actionType,
    required String content,
    required ContentType contentType,
    String? contentId,
    String? authorId,
    String? authorName,
    Map<String, dynamic>? metadata,
    double? confidence,
  }) async {
    final box = StorageService.behaviorLogBox;
    
    final log = BehaviorLogModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      actionType: actionType,
      contentId: contentId,
      content: content,
      contentType: contentType,
      authorId: authorId,
      authorName: authorName,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
      confidence: confidence,
    );
    
    await box.put(log.id, log);
    
    // 检查是否需要清理旧数据
    await _checkAndCleanupOldLogs();
  }
  
  /// 获取用户行为历史
  static List<BehaviorLogModel> getUserBehaviorHistory(
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
    BehaviorType? actionType,
    ContentType? contentType,
    int? limit,
  }) {
    final box = StorageService.behaviorLogBox;
    var logs = box.values.where((log) => log.userId == userId);
    
    // 时间范围过滤
    if (startTime != null) {
      logs = logs.where((log) => log.timestamp.isAfter(startTime));
    }
    if (endTime != null) {
      logs = logs.where((log) => log.timestamp.isBefore(endTime));
    }
    
    // 行为类型过滤
    if (actionType != null) {
      logs = logs.where((log) => log.actionType == actionType);
    }
    
    // 内容类型过滤
    if (contentType != null) {
      logs = logs.where((log) => log.contentType == contentType);
    }
    
    // 按时间倒序排序
    final sortedLogs = logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // 限制数量
    if (limit != null && limit > 0) {
      return sortedLogs.take(limit).toList();
    }
    
    return sortedLogs;
  }
  
  /// 获取最近的行为日志
  static List<BehaviorLogModel> getRecentBehaviors(
    String userId, {
    int days = 7,
    int? limit = 100,
  }) {
    final startTime = DateTime.now().subtract(Duration(days: days));
    return getUserBehaviorHistory(
      userId,
      startTime: startTime,
      limit: limit,
    );
  }
  
  /// 获取行为统计
  static Map<String, dynamic> getBehaviorStatistics(
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final logs = getUserBehaviorHistory(
      userId,
      startTime: startTime,
      endTime: endTime,
    );
    
    final stats = <String, dynamic>{};
    
    // 按行为类型统计
    final actionCounts = <BehaviorType, int>{};
    final contentTypeCounts = <ContentType, int>{};
    
    for (final log in logs) {
      actionCounts[log.actionType] = (actionCounts[log.actionType] ?? 0) + 1;
      contentTypeCounts[log.contentType] = (contentTypeCounts[log.contentType] ?? 0) + 1;
    }
    
    stats['totalLogs'] = logs.length;
    stats['actionCounts'] = actionCounts.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    stats['contentTypeCounts'] = contentTypeCounts.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    
    // 时间分布统计
    final timeDistribution = <int, int>{}; // 小时 -> 数量
    for (final log in logs) {
      final hour = log.timestamp.hour;
      timeDistribution[hour] = (timeDistribution[hour] ?? 0) + 1;
    }
    stats['timeDistribution'] = timeDistribution;
    
    // 最活跃的内容作者
    final authorCounts = <String, int>{};
    for (final log in logs) {
      if (log.authorName != null) {
        authorCounts[log.authorName!] = (authorCounts[log.authorName!] ?? 0) + 1;
      }
    }
    
    final topAuthors = authorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    stats['topAuthors'] = topAuthors.take(10).map(
      (entry) => {'name': entry.key, 'count': entry.value},
    ).toList();
    
    return stats;
  }
  
  /// 获取用户偏好分析数据
  static Map<String, dynamic> getPreferenceAnalysisData(String userId) {
    final recentLogs = getRecentBehaviors(userId, days: 30);
    
    // 喜欢的内容（点赞、收藏、分享）
    final positiveActions = [BehaviorType.like, BehaviorType.bookmark, BehaviorType.share];
    final likedContent = recentLogs
        .where((log) => positiveActions.contains(log.actionType))
        .map((log) => log.content)
        .toList();
    
    // 不喜欢的内容（点踩、举报、屏蔽）
    final negativeActions = [BehaviorType.dislike, BehaviorType.report, BehaviorType.block];
    final dislikedContent = recentLogs
        .where((log) => negativeActions.contains(log.actionType))
        .map((log) => log.content)
        .toList();
    
    // 阅读时长分析（通过metadata中的duration字段）
    final readingDurations = recentLogs
        .where((log) => 
            log.actionType == BehaviorType.read && 
            log.metadata.containsKey('duration'))
        .map((log) => log.metadata['duration'] as int)
        .toList();
    
    final avgReadingTime = readingDurations.isNotEmpty
        ? readingDurations.reduce((a, b) => a + b) / readingDurations.length
        : 0.0;
    
    return {
      'likedContent': likedContent,
      'dislikedContent': dislikedContent,
      'averageReadingTime': avgReadingTime,
      'totalInteractions': recentLogs.length,
      'dataRange': {
        'start': recentLogs.isNotEmpty ? recentLogs.last.timestamp.toIso8601String() : null,
        'end': recentLogs.isNotEmpty ? recentLogs.first.timestamp.toIso8601String() : null,
      },
    };
  }
  
  /// 删除行为日志
  static Future<void> deleteBehaviorLog(String logId) async {
    final box = StorageService.behaviorLogBox;
    await box.delete(logId);
  }
  
  /// 清空用户的所有行为日志
  static Future<void> clearUserBehaviorLogs(String userId) async {
    final box = StorageService.behaviorLogBox;
    final userLogs = box.values.where((log) => log.userId == userId);
    
    for (final log in userLogs) {
      await box.delete(log.id);
    }
  }
  
  /// 清理过期日志
  static Future<void> _checkAndCleanupOldLogs() async {
    final box = StorageService.behaviorLogBox;
    final now = DateTime.now();
    final maxAge = Duration(days: 90); // 保留90天
    
    final expiredLogs = box.values
        .where((log) => now.difference(log.timestamp) > maxAge)
        .toList();
    
    for (final log in expiredLogs) {
      await box.delete(log.id);
    }
    
    // 如果日志数量过多，保留最近的1000条
    if (box.length > 1000) {
      final allLogs = box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final logsToDelete = allLogs.skip(1000);
      for (final log in logsToDelete) {
        await box.delete(log.id);
      }
    }
  }
  
  /// 导出行为数据
  static Map<String, dynamic> exportBehaviorData(String userId) {
    final logs = getUserBehaviorHistory(userId);
    return {
      'userId': userId,
      'logs': logs.map((log) => log.toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
      'totalCount': logs.length,
    };
  }
  
  /// 获取行为趋势数据（用于图表展示）
  static List<Map<String, dynamic>> getBehaviorTrends(
    String userId, {
    int days = 30,
    String groupBy = 'day', // 'hour', 'day', 'week'
  }) {
    final logs = getRecentBehaviors(userId, days: days);
    final trends = <String, int>{};
    
    for (final log in logs) {
      String key;
      switch (groupBy) {
        case 'hour':
          key = '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')} ${log.timestamp.hour.toString().padLeft(2, '0')}:00';
          break;
        case 'week':
          final weekStart = log.timestamp.subtract(Duration(days: log.timestamp.weekday - 1));
          key = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
          break;
        default: // day
          key = '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      }
      
      trends[key] = (trends[key] ?? 0) + 1;
    }
    
    return trends.entries
        .map((entry) => {
              'date': entry.key,
              'count': entry.value,
            })
        .toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }
}