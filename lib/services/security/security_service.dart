import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../../base/service_base.dart';

/// 安全服务
/// 提供数据加密、解密和哈希功能
class SecurityService extends ServiceBase {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();
  SecurityService._();

  @override
  Future<void> initialize() async {
    // 初始化安全服务
  }

  /// 生成SHA-256哈希
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 生成MD5哈希
  String generateMD5(String data) {
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// 简单的数据混淆（Base64编码）
  String obfuscate(String data) {
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// 简单数据解混淆
  String deobfuscate(String obfuscatedData) {
    final bytes = base64Decode(obfuscatedData);
    return utf8.decode(bytes);
  }

  /// 验证数据完整性
  bool verifyIntegrity(String data, String hash, {bool useMD5 = false}) {
    final computedHash = useMD5 ? generateMD5(data) : generateHash(data);
    return computedHash == hash;
  }

  /// 生成随机字符串
  String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % chars.length;
    return chars.substring(random, random + length);
  }

  /// 清理敏感数据
  String sanitizeData(String data) {
    // 移除或替换敏感信息
    return data
        .replaceAll(RegExp(r'\d{15,18}'), '****') // 移除身份证/银行卡号
        .replaceAll(RegExp(r'\d{11}'), '***********'); // 移除手机号
  }

  @override
  Future<void> _disposeResources() async {}
}

/// 加密工具类
class EncryptionUtils {
  /// 简单的XOR加密（仅用于演示，生产环境使用专业加密库）
  static Uint8List xorEncrypt(Uint8List data, String key) {
    final keyBytes = utf8.encode(key);
    final encrypted = Uint8List(data.length);

    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ keyBytes[i % keyBytes.length];
    }

    return encrypted;
  }

  /// XOR解密
  static Uint8List xorDecrypt(Uint8List encryptedData, String key) {
    return xorEncrypt(encryptedData, key);
  }
}
