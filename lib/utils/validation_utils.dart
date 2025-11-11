/// 验证工具类
/// 提供各种数据验证方法
library;

import 'package:flutter/material.dart';

class ValidationUtils {
  /// 验证手机号
  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(phone);
  }

  /// 验证邮箱
  static bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  /// 验证身份证号
  static bool isValidIdCard(String idCard) {
    final regex = RegExp(r'^\d{17}[\dX]$');
    return regex.hasMatch(idCard.toUpperCase());
  }

  /// 验证URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 验证密码强度
  static PasswordStrength checkPasswordStrength(String password) {
    int score = 0;

    // 长度检查
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // 字符类型检查
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score < 2) return PasswordStrength.weak;
    if (score < 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// 验证中文
  static bool isChinese(String text) {
    final regex = RegExp(r'[\u4e00-\u9fff]');
    return regex.hasMatch(text);
  }

  /// 验证文件名
  static bool isValidFileName(String fileName) {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(fileName);
  }

  /// 验证数字范围
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// 验证非空
  static bool isNotEmpty(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  /// 验证最小长度
  static bool hasMinLength(String text, int minLength) {
    return text.trim().length >= minLength;
  }

  /// 验证最大长度
  static bool hasMaxLength(String text, int maxLength) {
    return text.trim().length <= maxLength;
  }

  /// 验证包含特定字符
  static bool containsChars(String text, String chars) {
    for (final char in chars.split('')) {
      if (text.contains(char)) return true;
    }
    return false;
  }

  /// 验证不能包含特定字符
  static bool notContainsChars(String text, String chars) {
    for (final char in chars.split('')) {
      if (text.contains(char)) return false;
    }
    return true;
  }
}

/// 密码强度枚举
enum PasswordStrength {
  weak('弱', Colors.red),
  medium('中', Colors.orange),
  strong('强', Colors.green);

  const PasswordStrength(this.displayName, this.color);
  final String displayName;
  final dynamic color;
}
