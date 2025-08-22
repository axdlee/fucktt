import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../services/storage_service.dart';
import '../services/user_config_service.dart';
import '../models/ai_provider_model.dart';
import '../models/value_template_model.dart';
import '../models/prompt_template_model.dart';
import '../models/user_config_model.dart';

/// 数据导出导入服务
class DataBackupService {
  static const String _backupVersion = '1.0.0';
  static const String _backupSignature = 'VALUE_FILTER_BACKUP';
  
  static DataBackupService? _instance;
  static DataBackupService get instance => _instance ??= DataBackupService._();
  
  DataBackupService._();
  
  /// 导出所有配置数据
  Future<BackupData> exportAllData() async {
    try {
      // 获取用户配置
      final userConfig = UserConfigService.getUserConfig();
      
      // 获取AI服务提供商
      final aiProviders = StorageService.aiProviderBox.values.toList();
      
      // 获取价值观模板
      final valueTemplates = StorageService.valueTemplateBox.values.toList();
      
      // 获取Prompt模板
      final promptTemplates = StorageService.promptTemplateBox.values.toList();
      
      // 获取设置数据
      final settings = StorageService.settingsBox.toMap();
      
      // 创建备份数据
      final backupData = BackupData(
        version: _backupVersion,
        signature: _backupSignature,
        timestamp: DateTime.now(),
        userConfig: userConfig,
        aiProviders: aiProviders,
        valueTemplates: valueTemplates,
        promptTemplates: promptTemplates,
        settings: settings,
        metadata: {
          'deviceInfo': await _getDeviceInfo(),
          'appVersion': '1.0.0',
          'exportedBy': 'user',
        },
      );
      
      return backupData;
    } catch (e) {
      throw BackupException('导出数据失败: $e');
    }
  }
  
  /// 导出到文件
  Future<String> exportToFile(BackupData backupData, {String? customPath}) async {
    try {
      final directory = customPath != null 
          ? Directory(customPath)
          : await getApplicationDocumentsDirectory();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'value_filter_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      // 转换为JSON并加密（可选）
      final jsonData = backupData.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      
      // 写入文件
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw BackupException('导出到文件失败: $e');
    }
  }
  
  /// 从文件导入
  Future<BackupData> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw BackupException('备份文件不存在');
      }
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 验证备份文件
      _validateBackupData(jsonData);
      
      return BackupData.fromJson(jsonData);
    } catch (e) {
      throw BackupException('从文件导入失败: $e');
    }
  }
  
  /// 应用备份数据
  Future<void> applyBackupData(BackupData backupData, {
    bool restoreUserConfig = true,
    bool restoreAIProviders = true,
    bool restoreValueTemplates = true,
    bool restorePromptTemplates = true,
    bool restoreSettings = true,
  }) async {
    try {
      // 备份当前数据（以防恢复失败）
      final currentBackup = await exportAllData();
      
      try {
        // 恢复用户配置
        if (restoreUserConfig && backupData.userConfig != null) {
          await UserConfigService.saveUserConfig(backupData.userConfig!);
        }
        
        // 恢复AI服务提供商
        if (restoreAIProviders && backupData.aiProviders.isNotEmpty) {
          final aiBox = StorageService.aiProviderBox;
          await aiBox.clear();
          for (final provider in backupData.aiProviders) {
            await aiBox.put(provider.id, provider);
          }
        }
        
        // 恢复价值观模板
        if (restoreValueTemplates && backupData.valueTemplates.isNotEmpty) {
          final valueBox = StorageService.valueTemplateBox;
          await valueBox.clear();
          for (final template in backupData.valueTemplates) {
            await valueBox.put(template.id, template);
          }
        }
        
        // 恢复Prompt模板
        if (restorePromptTemplates && backupData.promptTemplates.isNotEmpty) {
          final promptBox = StorageService.promptTemplateBox;
          await promptBox.clear();
          for (final template in backupData.promptTemplates) {
            await promptBox.put(template.id, template);
          }
        }
        
        // 恢复设置
        if (restoreSettings && backupData.settings.isNotEmpty) {
          final settingsBox = StorageService.settingsBox;
          await settingsBox.clear();
          for (final entry in backupData.settings.entries) {
            await settingsBox.put(entry.key, entry.value);
          }
        }
        
      } catch (e) {
        // 恢复失败，回滚到之前的数据
        await _rollbackData(currentBackup);
        throw BackupException('应用备份数据失败，已回滚: $e');
      }
    } catch (e) {
      throw BackupException('应用备份数据失败: $e');
    }
  }
  
  /// 创建快速备份
  Future<String> createQuickBackup() async {
    try {
      final backupData = await exportAllData();
      return await exportToFile(backupData);
    } catch (e) {
      throw BackupException('创建快速备份失败: $e');
    }
  }
  
  /// 获取备份文件列表
  Future<List<BackupFileInfo>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().toList();
      
      final backupFiles = <BackupFileInfo>[];
      
      for (final file in files) {
        if (file is File && file.path.contains('value_filter_backup_')) {
          try {
            final stat = await file.stat();
            final fileName = file.uri.pathSegments.last;
            
            // 尝试读取备份文件的元数据
            BackupMetadata? metadata;
            try {
              final content = await file.readAsString();
              final jsonData = jsonDecode(content) as Map<String, dynamic>;
              metadata = BackupMetadata.fromJson(jsonData);
            } catch (e) {
              // 忽略无法解析的文件
              continue;
            }
            
            backupFiles.add(BackupFileInfo(
              fileName: fileName,
              filePath: file.path,
              fileSize: stat.size,
              createdAt: stat.modified,
              metadata: metadata,
            ));
          } catch (e) {
            // 忽略无法访问的文件
            continue;
          }
        }
      }
      
      // 按创建时间排序（最新的在前）
      backupFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return backupFiles;
    } catch (e) {
      throw BackupException('获取备份文件列表失败: $e');
    }
  }
  
  /// 删除备份文件
  Future<void> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw BackupException('删除备份文件失败: $e');
    }
  }
  
  /// 清理旧的备份文件
  Future<void> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final backupFiles = await getBackupFiles();
      
      if (backupFiles.length > keepCount) {
        final filesToDelete = backupFiles.skip(keepCount);
        
        for (final fileInfo in filesToDelete) {
          await deleteBackupFile(fileInfo.filePath);
        }
      }
    } catch (e) {
      throw BackupException('清理旧备份失败: $e');
    }
  }
  
  /// 验证备份数据
  void _validateBackupData(Map<String, dynamic> data) {
    if (data['signature'] != _backupSignature) {
      throw BackupException('无效的备份文件格式');
    }
    
    if (data['version'] == null) {
      throw BackupException('备份文件缺少版本信息');
    }
    
    // 检查版本兼容性
    final backupVersion = data['version'] as String;
    if (!_isVersionCompatible(backupVersion)) {
      throw BackupException('备份文件版本不兼容: $backupVersion');
    }
  }
  
  /// 检查版本兼容性
  bool _isVersionCompatible(String version) {
    // 简单的版本检查，实际应用中可能需要更复杂的逻辑
    final supportedVersions = ['1.0.0'];
    return supportedVersions.contains(version);
  }
  
  /// 回滚数据
  Future<void> _rollbackData(BackupData rollbackData) async {
    await applyBackupData(
      rollbackData,
      restoreUserConfig: true,
      restoreAIProviders: true,
      restoreValueTemplates: true,
      restorePromptTemplates: true,
      restoreSettings: true,
    );
  }
  
  /// 获取设备信息
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      // 这里应该获取真实的设备信息，为了简化，返回模拟数据
      return {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
      };
    } catch (e) {
      return {'error': 'Unable to get device info'};
    }
  }
  
  /// 生成数据校验和
  String _generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// 备份数据模型
class BackupData {
  final String version;
  final String signature;
  final DateTime timestamp;
  final UserConfigModel? userConfig;
  final List<AIProviderModel> aiProviders;
  final List<ValueTemplateModel> valueTemplates;
  final List<PromptTemplateModel> promptTemplates;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;
  
  BackupData({
    required this.version,
    required this.signature,
    required this.timestamp,
    this.userConfig,
    this.aiProviders = const [],
    this.valueTemplates = const [],
    this.promptTemplates = const [],
    this.settings = const {},
    this.metadata = const {},
  });
  
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'signature': signature,
      'timestamp': timestamp.toIso8601String(),
      'userConfig': userConfig?.toJson(),
      'aiProviders': aiProviders.map((p) => p.toJson()).toList(),
      'valueTemplates': valueTemplates.map((t) => t.toJson()).toList(),
      'promptTemplates': promptTemplates.map((t) => t.toJson()).toList(),
      'settings': settings,
      'metadata': metadata,
    };
  }
  
  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] as String,
      signature: json['signature'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userConfig: json['userConfig'] != null 
          ? UserConfigModel.fromJson(json['userConfig'] as Map<String, dynamic>)
          : null,
      aiProviders: (json['aiProviders'] as List? ?? [])
          .map((p) => AIProviderModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      valueTemplates: (json['valueTemplates'] as List? ?? [])
          .map((t) => ValueTemplateModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      promptTemplates: (json['promptTemplates'] as List? ?? [])
          .map((t) => PromptTemplateModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 备份文件信息
class BackupFileInfo {
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;
  final BackupMetadata? metadata;
  
  BackupFileInfo({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
    this.metadata,
  });
  
  String get formattedSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

/// 备份元数据
class BackupMetadata {
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  BackupMetadata({
    required this.version,
    required this.timestamp,
    this.metadata = const {},
  });
  
  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      version: json['version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 备份异常
class BackupException implements Exception {
  final String message;
  
  BackupException(this.message);
  
  @override
  String toString() => 'BackupException: $message';
}"