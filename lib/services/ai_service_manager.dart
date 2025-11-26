import 'dart:async';
import 'dart:developer';
import '../models/ai_provider_model.dart';
import '../models/prompt_template_model.dart';
import 'storage_service.dart';
import 'ai_service_interface.dart';
import 'openai_compatible_service.dart';
import 'ai_simulation_service.dart';

/// AI服务管理器 - 统一管理所有AI服务提供商
class AIServiceManager {
  static final AIServiceManager _instance = AIServiceManager._internal();
  factory AIServiceManager() => _instance;
  AIServiceManager._internal();

  final Map<String, AIService> _services = {};
  final Map<String, DateTime> _lastHealthCheck = {};
  final Map<String, bool> _healthStatus = {};

  /// 初始化AI服务管理器
  Future<void> initialize() async {
    await _loadAIProviders();
    await _performHealthChecks();
  }

  /// 加载AI服务提供商
  Future<void> _loadAIProviders() async {
    final box = StorageService.aiProviderBox;
    final providers = box.values.where((provider) => provider.enabled).toList();

    _services.clear();
    
    for (final provider in providers) {
      try {
        final service = _createService(provider);
        _services[provider.id] = service;
      } catch (e) {
        log('创建AI服务失败 ${provider.id}: $e', name: 'AIServiceManager');
      }
    }
  }

  /// 创建AI服务实例
  AIService _createService(AIProviderModel provider) {
    // 根据provider的类型创建对应的服务
    switch (provider.name.toLowerCase()) {
      case 'simulation':
        return AISimulationService();
      default:
        // 默认使用OpenAI兼容的服务
        return OpenAICompatibleService(provider);
    }
  }

  /// 获取AI服务
  AIService? getService(String providerId) {
    return _services[providerId];
  }

  /// 获取可用的AI服务列表
  List<AIService> getAvailableServices() {
    return _services.values
        .where((service) => _healthStatus[service.provider.id] == true)
        .toList();
  }

  /// 获取最佳可用服务（按优先级）
  AIService? getBestAvailableService() {
    final availableServices = getAvailableServices();
    if (availableServices.isEmpty) return null;

    // 按优先级排序
    availableServices.sort((a, b) => a.provider.priority.compareTo(b.provider.priority));
    return availableServices.first;
  }

  /// 根据功能选择最佳服务
  AIService? selectServiceForTask(PromptFunction task) {
    final availableServices = getAvailableServices();
    if (availableServices.isEmpty) return null;

    // 可以根据不同任务类型选择最适合的AI服务
    // 目前简单按优先级选择
    return getBestAvailableService();
  }

  /// 执行AI请求（带负载均衡和重试）
  Future<AIResponse> executeRequest({
    required String prompt,
    String? providerId,
    String? modelId,
    Map<String, dynamic>? parameters,
    int maxRetries = 2,
  }) async {
    AIService? service;
    
    if (providerId != null) {
      service = getService(providerId);
    } else {
      service = getBestAvailableService();
    }

    if (service == null) {
      throw AIServiceException('没有可用的AI服务');
    }

    // 执行请求，带重试机制
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await service?.chat(
          prompt: prompt,
          modelId: modelId,
          parameters: parameters,
        );
        
        if (response?.success == true) {
          return response!;
        } else {
          throw AIServiceException(response?.errorMessage ?? '请求失败');
        }
      } catch (e) {
        // 标记服务为不健康
        if (service != null) {
          _healthStatus[service.provider.id] = false;
        }
        
        if (attempt == maxRetries) {
          rethrow;
        }
        
        // 尝试使用下一个可用服务
        final availableServices = getAvailableServices();
        if (availableServices.isNotEmpty) {
          service = availableServices.first;
        } else {
          rethrow;
        }
      }
    }

    throw AIServiceException('所有重试都失败了');
  }

  /// 执行流式AI请求
  Stream<String> executeStreamRequest({
    required String prompt,
    String? providerId,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async* {
    AIService? service;
    
    if (providerId != null) {
      service = getService(providerId);
    } else {
      service = getBestAvailableService();
    }

    if (service == null) {
      throw AIServiceException('没有可用的AI服务');
    }

    try {
      yield* service.chatStream(
        prompt: prompt,
        modelId: modelId,
        parameters: parameters,
      );
    } catch (e) {
      // 标记服务为不健康
      _healthStatus[service.provider.id] = false;
          rethrow;
    }
  }

  /// 执行健康检查
  Future<void> _performHealthChecks() async {
    final futures = _services.entries.map((entry) async {
      final providerId = entry.key;
      final service = entry.value;
      
      try {
        final isHealthy = await service.checkAvailability();
        _healthStatus[providerId] = isHealthy;
        _lastHealthCheck[providerId] = DateTime.now();
      } catch (e) {
        _healthStatus[providerId] = false;
        _lastHealthCheck[providerId] = DateTime.now();
      }
    });

    await Future.wait(futures);
  }

  /// 定期健康检查
  void startPeriodicHealthCheck({Duration interval = const Duration(minutes: 5)}) {
    Timer.periodic(interval, (timer) {
      _performHealthChecks();
    });
  }

  /// 添加新的AI服务提供商
  Future<void> addProvider(AIProviderModel provider) async {
    final box = StorageService.aiProviderBox;
    await box.put(provider.id, provider);
    
    if (provider.enabled) {
      try {
        final service = _createService(provider);
        _services[provider.id] = service;
        
        // 立即进行健康检查
        final isHealthy = await service.checkAvailability();
        _healthStatus[provider.id] = isHealthy;
        _lastHealthCheck[provider.id] = DateTime.now();
      } catch (e) {
        log('添加AI服务失败 ${provider.id}: $e', name: 'AIServiceManager');
      }
    }
  }

  /// 更新AI服务提供商
  Future<void> updateProvider(AIProviderModel provider) async {
    final box = StorageService.aiProviderBox;
    await box.put(provider.id, provider);
    
    // 移除旧服务
    final oldService = _services[provider.id];
    if (oldService is OpenAICompatibleService) {
      oldService.dispose();
    }
    _services.remove(provider.id);
    _healthStatus.remove(provider.id);
    _lastHealthCheck.remove(provider.id);
    
    // 添加新服务
    if (provider.enabled) {
      try {
        final service = _createService(provider);
        _services[provider.id] = service;
        
        final isHealthy = await service.checkAvailability();
        _healthStatus[provider.id] = isHealthy;
        _lastHealthCheck[provider.id] = DateTime.now();
      } catch (e) {
        log('更新AI服务失败 ${provider.id}: $e', name: 'AIServiceManager');
      }
    }
  }

  /// 删除AI服务提供商
  Future<void> removeProvider(String providerId) async {
    final box = StorageService.aiProviderBox;
    await box.delete(providerId);
    
    final service = _services[providerId];
    if (service is OpenAICompatibleService) {
      service.dispose();
    }
    
    _services.remove(providerId);
    _healthStatus.remove(providerId);
    _lastHealthCheck.remove(providerId);
  }

  /// 测试AI服务提供商配置
  Future<bool> testProvider(AIProviderModel provider) async {
    try {
      final service = _createService(provider);
      return await service.validateConfiguration();
    } catch (e) {
      log('测试AI服务配置失败: $e', name: 'AIServiceManager');
      return false;
    }
  }

  /// 获取服务健康状态
  Map<String, bool> getHealthStatus() {
    return Map.from(_healthStatus);
  }

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStatistics() {
    final stats = <String, dynamic>{};
    
    stats['totalServices'] = _services.length;
    stats['healthyServices'] = _healthStatus.values.where((healthy) => healthy).length;
    stats['unhealthyServices'] = _healthStatus.values.where((healthy) => !healthy).length;
    
    final serviceDetails = <String, Map<String, dynamic>>{};
    for (final entry in _services.entries) {
      final providerId = entry.key;
      final service = entry.value;
      
      serviceDetails[providerId] = {
        'name': service.provider.displayName,
        'healthy': _healthStatus[providerId] ?? false,
        'lastCheck': _lastHealthCheck[providerId]?.toIso8601String(),
        'priority': service.provider.priority,
        'enabled': service.provider.enabled,
      };
    }
    
    stats['services'] = serviceDetails;
    return stats;
  }

  /// 重新加载所有服务
  Future<void> reloadServices() async {
    // 清理现有服务
    for (final service in _services.values) {
      if (service is OpenAICompatibleService) {
        service.dispose();
      }
    }
    
    _services.clear();
    _healthStatus.clear();
    _lastHealthCheck.clear();
    
    // 重新加载
    await _loadAIProviders();
    await _performHealthChecks();
  }

  /// 释放资源
  void dispose() {
    for (final service in _services.values) {
      if (service is OpenAICompatibleService) {
        service.dispose();
      }
    }
    
    _services.clear();
    _healthStatus.clear();
    _lastHealthCheck.clear();
  }
}