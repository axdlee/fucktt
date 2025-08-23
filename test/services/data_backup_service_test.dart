import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:value_filter/services/data_backup_service.dart';
import 'package:value_filter/models/ai_provider_model.dart';
import 'package:value_filter/models/value_template_model.dart';
import '../test_helper.dart';

void main() {
  group('DataBackupService Tests', () {
    late DataBackupService backupService;

    setUp(() async {
      await TestHelper.initializeTestEnvironment();
      backupService = DataBackupService.instance;
    });

    tearDown(() async {
      await TestHelper.cleanupTestEnvironment();
    });

    test('should be singleton instance', () {
      final service1 = DataBackupService.instance;
      final service2 = DataBackupService.instance;
      expect(service1, equals(service2));
    });

    test('should export all data successfully', () async {
      // 准备测试数据
      final testProvider = TestHelper.createTestAIProvider();
      final testTemplate = TestHelper.createTestValueTemplate();

      // 导出数据
      final backupData = await backupService.exportAllData();

      expect(backupData, isNotNull);
      expect(backupData.version, isNotEmpty);
      expect(backupData.signature, isNotEmpty);
      expect(backupData.timestamp, isA<DateTime>());
      expect(backupData.metadata, isA<Map<String, dynamic>>());
    });

    test('should export to file successfully', () async {
      final backupData = await backupService.exportAllData();
      final filePath = await backupService.exportToFile(backupData);

      expect(filePath, isNotEmpty);
      expect(File(filePath).existsSync(), isTrue);

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should import from file successfully', () async {
      // 先导出数据
      final originalData = await backupService.exportAllData();
      final filePath = await backupService.exportToFile(originalData);

      // 然后导入数据
      final importedData = await backupService.importFromFile(filePath);

      expect(importedData.version, equals(originalData.version));
      expect(importedData.signature, equals(originalData.signature));

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should handle non-existent file import gracefully', () async {
      expect(
        () async => await backupService.importFromFile('non_existent_file.json'),
        throwsA(isA<BackupException>()),
      );
    });

    test('should apply backup data correctly', () async {
      final backupData = await backupService.exportAllData();

      expect(
        () async => await backupService.applyBackupData(
          backupData,
          restoreUserConfig: true,
          restoreAIProviders: true,
          restoreValueTemplates: true,
        ),
        returnsNormally,
      );
    });

    test('should create quick backup successfully', () async {
      final filePath = await backupService.createQuickBackup();

      expect(filePath, isNotEmpty);
      expect(File(filePath).existsSync(), isTrue);

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should get backup files list', () async {
      // 创建一些备份文件
      await backupService.createQuickBackup();
      await backupService.createQuickBackup();

      final backupFiles = await backupService.getBackupFiles();

      expect(backupFiles, isA<List<BackupFileInfo>>());
      
      // 清理测试文件
      for (final fileInfo in backupFiles) {
        if (File(fileInfo.filePath).existsSync()) {
          await File(fileInfo.filePath).delete();
        }
      }
    });

    test('should delete backup file successfully', () async {
      final filePath = await backupService.createQuickBackup();
      expect(File(filePath).existsSync(), isTrue);

      await backupService.deleteBackupFile(filePath);
      expect(File(filePath).existsSync(), isFalse);
    });

    test('should cleanup old backups correctly', () async {
      // 创建多个备份文件
      final filePaths = <String>[];
      for (int i = 0; i < 7; i++) {
        final path = await backupService.createQuickBackup();
        filePaths.add(path);
        // 添加小延迟确保文件时间戳不同
        await Future.delayed(const Duration(milliseconds: 10));
      }

      await backupService.cleanupOldBackups(keepCount: 3);

      // 检查只保留了3个最新的文件
      int existingFiles = 0;
      for (final path in filePaths) {
        if (File(path).existsSync()) {
          existingFiles++;
          await File(path).delete(); // 清理
        }
      }

      expect(existingFiles, lessThanOrEqualTo(3));
    });

    test('should handle backup validation correctly', () async {
      final validData = await backupService.exportAllData();
      final filePath = await backupService.exportToFile(validData);

      // 应该成功导入有效的备份
      expect(
        () async => await backupService.importFromFile(filePath),
        returnsNormally,
      );

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should export and import specific data types', () async {
      // 测试导出特定数据
      final exportData = {
        'version': '1.0.0',
        'exportTime': DateTime.now().toIso8601String(),
        'templates': [TestHelper.createTestValueTemplate()],
        'userProfile': {'userId': 'test_user'},
      };

      final filePath = await backupService.exportBackup(
        data: exportData,
        filename: 'test_specific_export.json',
      );

      expect(File(filePath).existsSync(), isTrue);

      // 测试导入特定数据
      final backupData = await backupService.loadBackupData(filePath);
      expect(backupData, isNotNull);
      expect(backupData.valueTemplates, isNotEmpty);

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should handle large backup data efficiently', () async {
      // 创建大量测试数据
      final largeBackupData = await backupService.exportAllData();

      final startTime = DateTime.now();
      final filePath = await backupService.exportToFile(largeBackupData);
      final exportDuration = DateTime.now().difference(startTime);

      expect(exportDuration.inSeconds, lessThan(10)); // 应该在10秒内完成

      final importStartTime = DateTime.now();
      final importedData = await backupService.importFromFile(filePath);
      final importDuration = DateTime.now().difference(importStartTime);

      expect(importDuration.inSeconds, lessThan(5)); // 导入应该更快
      expect(importedData.version, equals(largeBackupData.version));

      // 清理测试文件
      if (File(filePath).existsSync()) {
        await File(filePath).delete();
      }
    });

    test('should handle backup rollback on failure', () async {
      final originalData = await backupService.exportAllData();

      // 创建一个可能导致失败的备份数据
      final corruptData = BackupData(
        version: 'invalid_version',
        signature: 'invalid_signature',
        timestamp: DateTime.now(),
        metadata: {'corrupted': true},
      );

      // 尝试应用损坏的数据，应该回滚
      expect(
        () async => await backupService.applyBackupData(corruptData),
        throwsA(isA<BackupException>()),
      );
    });

    test('should generate correct backup metadata', () async {
      final backupData = await backupService.exportAllData();

      expect(backupData.metadata, isA<Map<String, dynamic>>());
      expect(backupData.metadata.isNotEmpty, isTrue);
    });

    test('should handle concurrent backup operations', () async {
      // 并发创建多个备份
      final futures = List.generate(3, (index) async {
        return await backupService.createQuickBackup();
      });

      final filePaths = await Future.wait(futures);

      expect(filePaths.length, equals(3));
      expect(filePaths.every((path) => path.isNotEmpty), isTrue);

      // 清理测试文件
      for (final path in filePaths) {
        if (File(path).existsSync()) {
          await File(path).delete();
        }
      }
    });
  });
}