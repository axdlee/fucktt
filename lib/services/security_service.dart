import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// 安全级别枚举
enum SecurityLevel {
  low,
  medium,
  high,
  maximum,
}

/// 数据敏感度枚举
enum DataSensitivity {
  public,
  internal,
  confidential,
  secret,
}

/// 安全策略配置
class SecurityPolicy {
  final SecurityLevel level;
  final bool enableEncryption;
  final bool enableDataMasking;
  final bool enableAuditLog;
  final Duration sessionTimeout;
  final int maxFailedAttempts;

  const SecurityPolicy({
    required this.level,
    required this.enableEncryption,
    required this.enableDataMasking,
    required this.enableAuditLog,
    required this.sessionTimeout,
    required this.maxFailedAttempts,
  });

  static const SecurityPolicy defaultPolicy = SecurityPolicy(
    level: SecurityLevel.medium,
    enableEncryption: true,
    enableDataMasking: true,
    enableAuditLog: true,
    sessionTimeout: Duration(hours: 24),
    maxFailedAttempts: 5,
  );
}

/// 审计日志条目
class AuditLogEntry {
  final String id;
  final String action;
  final String resource;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final SecurityLevel severity;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.resource,
    required this.userId,
    required this.timestamp,
    this.metadata = const {},
    this.severity = SecurityLevel.medium,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'resource': resource,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'severity': severity.name,
    };
  }
}

/// 安全性检查和数据保护服务
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  SecurityPolicy _currentPolicy = SecurityPolicy.defaultPolicy;
  final List<AuditLogEntry> _auditLog = [];
  final Random _random = Random.secure();
  
  static const String encryptionKeyKey = 'encryption_key';
  static const String auditLogKey = 'audit_log';
  static const int maxAuditLogSize = 1000;

  /// 初始化安全服务
  Future<void> initialize() async {
    await _loadSecurityPolicy();
    await _initializeEncryption();
    await _loadAuditLog();
    
    if (kDebugMode) {
      dev.log('安全服务已初始化 (级别: ${_currentPolicy.level.name})', name: 'SecurityService');
    }
  }

  /// 设置安全策略
  Future<void> setSecurityPolicy(SecurityPolicy policy) async {
    _currentPolicy = policy;
    await _saveSecurityPolicy();
    
    _logAuditEvent(
      action: 'SECURITY_POLICY_CHANGED',
      resource: 'system',
      metadata: {'newLevel': policy.level.name},
      severity: SecurityLevel.high,
    );
  }

  /// 加密敏感数据
  String encryptSensitiveData(String data, DataSensitivity sensitivity) {
    if (!_currentPolicy.enableEncryption || 
        sensitivity == DataSensitivity.public) {
      return data;
    }

    try {
      // final key = _getEncryptionKey(); // 简化的实现中暂时不需要
      final bytes = utf8.encode(data);

      // 简化的加密实现（实际应用中应使用更强的加密算法）
      final encrypted = base64.encode(bytes);
      
      _logAuditEvent(
        action: 'DATA_ENCRYPTED',
        resource: 'sensitive_data',
        metadata: {
          'sensitivity': sensitivity.name,
          'dataLength': data.length,
        },
      );

      return encrypted;
    } catch (e) {
      if (kDebugMode) {
        dev.log('数据加密失败: $e', name: 'SecurityService', level: 900);
      }
      return data;
    }
  }

  /// 解密敏感数据
  String decryptSensitiveData(String encryptedData, DataSensitivity sensitivity) {
    if (!_currentPolicy.enableEncryption || 
        sensitivity == DataSensitivity.public) {
      return encryptedData;
    }

    try {
      // 简化的解密实现
      final decrypted = utf8.decode(base64.decode(encryptedData));
      
      _logAuditEvent(
        action: 'DATA_DECRYPTED',
        resource: 'sensitive_data',
        metadata: {
          'sensitivity': sensitivity.name,
        },
      );

      return decrypted;
    } catch (e) {
      if (kDebugMode) {
        dev.log('数据解密失败: $e', name: 'SecurityService', level: 900);
      }
      return encryptedData;
    }
  }

  /// 脱敏显示敏感信息
  String maskSensitiveData(String data, DataSensitivity sensitivity) {
    if (!_currentPolicy.enableDataMasking || 
        sensitivity == DataSensitivity.public) {
      return data;
    }

    switch (sensitivity) {
      case DataSensitivity.confidential:
        return _maskString(data, showFirst: 2, showLast: 2);
      case DataSensitivity.secret:
        return _maskString(data, showFirst: 1, showLast: 1);
      case DataSensitivity.internal:
        return _maskString(data, showFirst: 4, showLast: 4);
      default:
        return data;
    }
  }

  /// 验证API密钥安全性
  SecurityValidationResult validateApiKeySecurity(String apiKey) {
    final issues = <String>[];
    SecurityLevel level = SecurityLevel.high;

    // 检查长度
    if (apiKey.length < 20) {
      issues.add('API密钥长度过短');
      level = SecurityLevel.low;
    }

    // 检查复杂度
    if (!_hasGoodComplexity(apiKey)) {
      issues.add('API密钥复杂度不足');
      if (level == SecurityLevel.high) level = SecurityLevel.medium;
    }

    // 检查是否为常见弱密钥
    if (_isWeakApiKey(apiKey)) {
      issues.add('使用了常见的弱API密钥');
      level = SecurityLevel.low;
    }

    _logAuditEvent(
      action: 'API_KEY_VALIDATED',
      resource: 'api_key',
      metadata: {
        'securityLevel': level.name,
        'issueCount': issues.length,
      },
      severity: level,
    );

    return SecurityValidationResult(
      isValid: issues.isEmpty,
      securityLevel: level,
      issues: issues,
    );
  }

  /// 验证输入数据安全性
  bool validateInputSecurity(String input) {
    // 检查SQL注入风险
    if (_containsSqlInjectionPatterns(input)) {
      _logAuditEvent(
        action: 'SECURITY_THREAT_DETECTED',
        resource: 'user_input',
        metadata: {'threat': 'sql_injection_attempt'},
        severity: SecurityLevel.high,
      );
      return false;
    }

    // 检查XSS风险
    if (_containsXssPatterns(input)) {
      _logAuditEvent(
        action: 'SECURITY_THREAT_DETECTED',
        resource: 'user_input',
        metadata: {'threat': 'xss_attempt'},
        severity: SecurityLevel.high,
      );
      return false;
    }

    // 检查过长输入
    if (input.length > 10000) {
      _logAuditEvent(
        action: 'SECURITY_THREAT_DETECTED',
        resource: 'user_input',
        metadata: {'threat': 'oversized_input'},
        severity: SecurityLevel.medium,
      );
      return false;
    }

    return true;
  }

  /// 生成安全的随机字符串
  String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// 记录安全事件
  void logSecurityEvent(String action, String resource, {
    Map<String, dynamic>? metadata,
    SecurityLevel severity = SecurityLevel.medium,
  }) {
    _logAuditEvent(
      action: action,
      resource: resource,
      metadata: metadata ?? {},
      severity: severity,
    );
  }

  /// 获取安全报告
  Map<String, dynamic> getSecurityReport({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentLogs = _auditLog
        .where((log) => log.timestamp.isAfter(cutoffDate))
        .toList();

    final actionCount = <String, int>{};
    final severityCount = <SecurityLevel, int>{};
    final dailyCount = <String, int>{};
    final threats = <AuditLogEntry>[];

    for (final log in recentLogs) {
      // 统计操作类型
      actionCount[log.action] = (actionCount[log.action] ?? 0) + 1;
      
      // 统计严重程度
      severityCount[log.severity] = (severityCount[log.severity] ?? 0) + 1;
      
      // 统计每日事件
      final dateKey = '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      dailyCount[dateKey] = (dailyCount[dateKey] ?? 0) + 1;
      
      // 收集安全威胁
      if (log.action.contains('THREAT_DETECTED')) {
        threats.add(log);
      }
    }

    return {
      'period': days,
      'totalEvents': recentLogs.length,
      'securityPolicy': _currentPolicy.level.name,
      'actionCount': actionCount,
      'severityCount': severityCount.map((k, v) => MapEntry(k.name, v)),
      'dailyCount': dailyCount,
      'threats': threats.map((t) => t.toJson()).toList(),
      'recommendations': _generateSecurityRecommendations(),
    };
  }

  /// 清理审计日志
  Future<void> cleanupAuditLog({int keepDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    _auditLog.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    await _saveAuditLog();
  }

  /// 数据备份前的安全检查
  Future<bool> validateBackupSecurity(Map<String, dynamic> backupData) async {
    // 检查备份数据中是否包含敏感信息
    final sensitiveKeys = ['apiKey', 'token', 'password', 'secret'];
    
    bool hasSensitiveData = false;
    for (final key in sensitiveKeys) {
      if (_containsSensitiveKey(backupData, key)) {
        hasSensitiveData = true;
        break;
      }
    }

    if (hasSensitiveData) {
      _logAuditEvent(
        action: 'BACKUP_SECURITY_CHECK',
        resource: 'backup_data',
        metadata: {'hasSensitiveData': true},
        severity: SecurityLevel.high,
      );
    }

    return !hasSensitiveData || _currentPolicy.enableEncryption;
  }

  /// 私有方法

  String _maskString(String data, {int showFirst = 2, int showLast = 2}) {
    if (data.length <= showFirst + showLast) {
      return '*' * data.length;
    }

    final first = data.substring(0, showFirst);
    final last = data.substring(data.length - showLast);
    final middle = '*' * (data.length - showFirst - showLast);
    
    return '$first$middle$last';
  }

  bool _hasGoodComplexity(String text) {
    final hasUpper = text.contains(RegExp(r'[A-Z]'));
    final hasLower = text.contains(RegExp(r'[a-z]'));
    final hasDigit = text.contains(RegExp(r'[0-9]'));
    final hasSpecial = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return [hasUpper, hasLower, hasDigit, hasSpecial].where((x) => x).length >= 3;
  }

  bool _isWeakApiKey(String apiKey) {
    final weakPatterns = [
      'test',
      'demo',
      'example',
      '12345',
      'abcde',
      'password',
    ];
    
    final lowerKey = apiKey.toLowerCase();
    return weakPatterns.any((pattern) => lowerKey.contains(pattern));
  }

  bool _containsSqlInjectionPatterns(String input) {
    final patterns = [
      RegExp(r"('|(\\'))|(;)|(--|#)", caseSensitive: false),
      RegExp(r'\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b', caseSensitive: false),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(input));
  }

  bool _containsXssPatterns(String input) {
    final patterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(input));
  }

  bool _containsSensitiveKey(Map<String, dynamic> data, String key) {
    return data.toString().toLowerCase().contains(key.toLowerCase());
  }

  String _getEncryptionKey() {
    final box = StorageService.settingsBox;
    String? key = box.get(encryptionKeyKey);
    
    if (key == null) {
      key = generateSecureRandomString(32);
      box.put(encryptionKeyKey, key);
    }
    
    return key;
  }

  void _logAuditEvent({
    required String action,
    required String resource,
    Map<String, dynamic> metadata = const {},
    SecurityLevel severity = SecurityLevel.medium,
  }) {
    if (!_currentPolicy.enableAuditLog) return;

    final entry = AuditLogEntry(
      id: generateSecureRandomString(16),
      action: action,
      resource: resource,
      userId: 'default_user', // 实际应用中从认证服务获取
      timestamp: DateTime.now(),
      metadata: metadata,
      severity: severity,
    );

    _auditLog.add(entry);

    // 限制日志大小
    if (_auditLog.length > maxAuditLogSize) {
      _auditLog.removeAt(0);
    }

    // 异步保存
    _saveAuditLog();
  }

  List<String> _generateSecurityRecommendations() {
    final recommendations = <String>[];

    if (_currentPolicy.level == SecurityLevel.low) {
      recommendations.add('建议提高安全级别');
    }

    if (!_currentPolicy.enableEncryption) {
      recommendations.add('建议启用数据加密');
    }

    if (!_currentPolicy.enableDataMasking) {
      recommendations.add('建议启用数据脱敏');
    }

    final threats = _auditLog
        .where((log) => log.action.contains('THREAT_DETECTED'))
        .where((log) => log.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .length;

    if (threats > 5) {
      recommendations.add('检测到多次安全威胁，建议加强监控');
    }

    return recommendations;
  }

  Future<void> _loadSecurityPolicy() async {
    // 从存储加载安全策略
    // 这里简化处理，使用默认策略
  }

  Future<void> _saveSecurityPolicy() async {
    // 保存安全策略到存储
    // 这里简化处理
  }

  Future<void> _initializeEncryption() async {
    if (_currentPolicy.enableEncryption) {
      _getEncryptionKey(); // 确保加密密钥存在
    }
  }

  Future<void> _loadAuditLog() async {
    // 从存储加载审计日志
    // 这里简化处理
  }

  Future<void> _saveAuditLog() async {
    // 保存审计日志到存储
    // 这里简化处理
  }
}

/// 安全验证结果
class SecurityValidationResult {
  final bool isValid;
  final SecurityLevel securityLevel;
  final List<String> issues;

  SecurityValidationResult({
    required this.isValid,
    required this.securityLevel,
    required this.issues,
  });
}