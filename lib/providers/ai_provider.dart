import 'package:flutter/material.dart';
import '../models/ai_provider_model.dart';
import '../services/ai_service_manager.dart';
import '../services/ai_service_interface.dart';
import '../services/storage_service.dart';

/// AI服务Provider - 管理AI服务相关状态
class AIProvider extends ChangeNotifier {
  final AIServiceManager _serviceManager = AIServiceManager();
  
  List<AIProviderModel> _providers = [];
  Map<String, bool> _healthStatus = {};
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentRequestId;

  // Getters
  List<AIProviderModel> get providers => List.unmodifiable(_providers);
  Map<String, bool> get healthStatus => Map.unmodifiable(_healthStatus);
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAvailableServices => _healthStatus.values.any((healthy) => healthy);
  
  /// 获取启用的服务提供商
  List<AIProviderModel> get enabledProviders => 
      _providers.where((provider) => provider.enabled).toList();
  
  /// 获取健康的服务提供商
  List<AIProviderModel> get healthyProviders => 
      _providers.where((provider) => 
          provider.enabled && (_healthStatus[provider.id] ?? false)).toList();

  /// 初始化AI Provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      await _serviceManager.initialize();
      await _loadProviders();
      
      // 如果没有任何AI服务，自动添加模拟服务
      if (_providers.isEmpty || !_providers.any((p) => p.enabled)) {
        await _addSimulationService();
        await _loadProviders();
      }
      
      await _updateHealthStatus();
      
      // 开始定期健康检查
      _serviceManager.startPeriodicHealthCheck();
      
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('AI服务初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 添加模拟AI服务（用于测试和演示）
  Future<void> _addSimulationService() async {
    final simulationProvider = AIProviderModel(
      id: 'simulation',
      name: 'simulation',
      displayName: '模拟AI服务',
      baseUrl: 'mock://simulation',
      apiKey: 'mock-key',
      supportedModels: [
        ModelConfig(modelId: 'simulation-model', displayName: 'Mock AI Model'),
        ModelConfig(modelId: 'test-model', displayName: 'Test Model'),
      ],
      enabled: true,
      description: '用于测试和演示的模拟AI服务，无需API密钥',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      priority: 99, // 最低优先级
    );
    
    try {
      await _serviceManager.addProvider(simulationProvider);
      print('✅ 已自动添加模拟AI服务用于测试');
    } catch (e) {
      print('⚠️ 添加模拟AI服务失败: $e');
    }
  }

  /// 加载AI服务提供商
  Future<void> _loadProviders() async {
    final box = StorageService.aiProviderBox;
    _providers = box.values.toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// 更新健康状态
  Future<void> _updateHealthStatus() async {
    _healthStatus = _serviceManager.getHealthStatus();
  }

  /// 添加AI服务提供商
  Future<void> addProvider(AIProviderModel provider) async {
    _setLoading(true);
    
    try {
      await _serviceManager.addProvider(provider);
      await _loadProviders();
      await _updateHealthStatus();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('添加AI服务失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新AI服务提供商
  Future<void> updateProvider(AIProviderModel provider) async {
    _setLoading(true);
    
    try {
      await _serviceManager.updateProvider(provider);
      await _loadProviders();
      await _updateHealthStatus();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('更新AI服务失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 删除AI服务提供商
  Future<void> removeProvider(String providerId) async {
    _setLoading(true);
    
    try {
      await _serviceManager.removeProvider(providerId);
      await _loadProviders();
      await _updateHealthStatus();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('删除AI服务失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 测试AI服务提供商
  Future<bool> testProvider(AIProviderModel provider) async {
    _setLoading(true);
    
    try {
      final result = await _serviceManager.testProvider(provider);
      _clearError();
      return result;
    } catch (e) {
      _setError('测试AI服务失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 执行AI请求
  Future<AIResponse?> executeRequest({
    required String prompt,
    String? providerId,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _currentRequestId = requestId;
    
    try {
      notifyListeners(); // 通知开始请求
      
      final response = await _serviceManager.executeRequest(
        prompt: prompt,
        providerId: providerId,
        modelId: modelId,
        parameters: parameters,
      );
      
      await _updateHealthStatus();
      _clearError();
      return response;
    } catch (e) {
      _setError('AI请求失败: $e');
      await _updateHealthStatus();
      return null;
    } finally {
      if (_currentRequestId == requestId) {
        _currentRequestId = null;
        notifyListeners(); // 通知请求结束
      }
    }
  }

  /// 执行流式AI请求
  Stream<String>? executeStreamRequest({
    required String prompt,
    String? providerId,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) {
    try {
      _clearError();
      return _serviceManager.executeStreamRequest(
        prompt: prompt,
        providerId: providerId,
        modelId: modelId,
        parameters: parameters,
      );
    } catch (e) {
      _setError('流式AI请求失败: $e');
      return null;
    }
  }

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStatistics() {
    return _serviceManager.getServiceStatistics();
  }

  /// 刷新服务状态
  Future<void> refreshServices() async {
    _setLoading(true);
    
    try {
      await _serviceManager.reloadServices();
      await _loadProviders();
      await _updateHealthStatus();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('刷新服务状态失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取提供商
  AIProviderModel? getProvider(String providerId) {
    try {
      return _providers.firstWhere((provider) => provider.id == providerId);
    } catch (e) {
      return null;
    }
  }

  /// 获取可用模型列表
  Future<List<ModelConfig>> getAvailableModels(String providerId) async {
    try {
      final service = _serviceManager.getService(providerId);
      if (service != null) {
        return await service.getAvailableModels();
      }
      return [];
    } catch (e) {
      _setError('获取模型列表失败: $e');
      return [];
    }
  }

  /// 设置提供商优先级
  Future<void> setProviderPriority(String providerId, int priority) async {
    final provider = getProvider(providerId);
    if (provider != null) {
      final updatedProvider = provider.copyWith(
        priority: priority,
        updatedAt: DateTime.now(),
      );
      await updateProvider(updatedProvider);
    }
  }

  /// 启用/禁用提供商
  Future<void> toggleProvider(String providerId) async {
    final provider = getProvider(providerId);
    if (provider != null) {
      final updatedProvider = provider.copyWith(
        enabled: !provider.enabled,
        updatedAt: DateTime.now(),
      );
      await updateProvider(updatedProvider);
    }
  }

  /// 创建默认的OpenAI提供商
  AIProviderModel createOpenAIProvider({
    required String apiKey,
    String baseUrl = 'https://api.openai.com/v1',
  }) {
    return AIProviderModel(
      id: 'openai_${DateTime.now().microsecondsSinceEpoch}',
      name: 'openai',
      displayName: 'OpenAI',
      baseUrl: baseUrl,
      apiKey: apiKey,
      supportedModels: [
        ModelConfig(modelId: 'gpt-3.5-turbo', displayName: 'GPT-3.5 Turbo'),
        ModelConfig(modelId: 'gpt-4', displayName: 'GPT-4'),
        ModelConfig(modelId: 'gpt-4-turbo', displayName: 'GPT-4 Turbo'),
      ],
      enabled: true,
      description: 'OpenAI官方API服务',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      priority: 1,
    );
  }

  /// 创建DeepSeek提供商
  AIProviderModel createDeepSeekProvider({
    required String apiKey,
    String baseUrl = 'https://api.deepseek.com/v1',
  }) {
    return AIProviderModel(
      id: 'deepseek_${DateTime.now().microsecondsSinceEpoch}',
      name: 'deepseek',
      displayName: 'DeepSeek',
      baseUrl: baseUrl,
      apiKey: apiKey,
      supportedModels: [
        ModelConfig(modelId: 'deepseek-chat', displayName: 'DeepSeek Chat'),
        ModelConfig(modelId: 'deepseek-coder', displayName: 'DeepSeek Coder'),
      ],
      enabled: true,
      description: 'DeepSeek AI服务',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      priority: 2,
    );
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 检查是否有正在进行的请求
  bool get hasActiveRequest => _currentRequestId != null;

  @override
  void dispose() {
    _serviceManager.dispose();
    super.dispose();
  }
}