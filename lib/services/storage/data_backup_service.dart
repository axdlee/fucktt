import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import '../../base/service_base.dart';
import 'storage_service.dart';

/// 数据备份服务
/// 支持自动备份和恢复功能
class DataBackupService extends ServiceBase {
  static DataBackupService? _instance;
  static DataBackupService get instance => _instance ??= DataBackupService._();
  DataBackupService._();

  late final StorageService _storage;

  @override
  Future<void> initialize() async {
    _storage = StorageService.instance;
  }

  /// 备份所有数据
  Future<BackupResult> createBackup() async {
    final data = <String, dynamic>{};
    final keys = _storage.getAllKeys();

    for (final key in keys) {
      final value = _storage.get<dynamic>(key);
      if (value != null) {
        data[key] = value;
      }
    }

    final timestamp = DateTime.now().toIso8601String();
    final backupData = {
      'timestamp': timestamp,
      'version': '1.0',
      'data': data,
    };

    final backupJson = jsonEncode(backupData);
    final backupBytes = Uint8List.fromList(backupJson.codeUnits);

    return BackupResult(
      success: true,
      data: backupBytes,
      size: backupBytes.length,
      timestamp: timestamp,
    );
  }

  /// 恢复数据
  Future<RestoreResult> restoreFromBackup(Uint8List backupData) async {
    try {
      final backupJson = String.fromCharCodes(backupData);
      final backupMap = jsonDecode(backupJson) as Map<String, dynamic>;

      final data = backupMap['data'] as Map<String, dynamic>;
      int restoredCount = 0;

      for (final entry in data.entries) {
        await _storage.put(entry.key, entry.value);
        restoredCount++;
      }

      return RestoreResult(
        success: true,
        restoredCount: restoredCount,
        message: '成功恢复 $restoredCount 条数据',
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        restoredCount: 0,
        message: '恢复失败: $e',
      );
    }
  }

  /// 导出数据到文件
  Future<File> exportToFile() async {
    final backup = await createBackup();
    final dir = await Directory.systemTemp.createTemp();
    final file = File(
        '${dir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsBytes(backup.data);
    return file;
  }

  /// 从文件导入数据
  Future<RestoreResult> importFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return await restoreFromBackup(bytes);
  }

  @override
  Future<void> _disposeResources() async {}
}

/// 备份结果
class BackupResult {
  final bool success;
  final Uint8List data;
  final int size;
  final String timestamp;

  const BackupResult({
    required this.success,
    required this.data,
    required this.size,
    required this.timestamp,
  });
}

/// 恢复结果
class RestoreResult {
  final bool success;
  final int restoredCount;
  final String message;

  const RestoreResult({
    required this.success,
    required this.restoredCount,
    required this.message,
  });
}
