import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/value_template_model.dart';
import '../services/storage_service.dart';

/// 用户价值观档案模型
class UserValuesProfile {
  final String userId;
  final Map<String, double> templateWeights;
  final List<String> blacklist;
  final List<String> whitelist;
  final Map<String, List<String>> customCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserValuesProfile({
    required this.userId,
    required this.templateWeights,
    required this.blacklist,
    required this.whitelist,
    required this.customCategories,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建一个新的UserValuesProfile实例，替换指定的字段
  UserValuesProfile copyWith({
    String? userId,
    Map<String, double>? templateWeights,
    List<String>? blacklist,
    List<String>? whitelist,
    Map<String, List<String>>? customCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserValuesProfile(
      userId: userId ?? this.userId,
      templateWeights: templateWeights ?? this.templateWeights,
      blacklist: blacklist ?? this.blacklist,
      whitelist: whitelist ?? this.whitelist,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'templateWeights': templateWeights,
      'blacklist': blacklist,
      'whitelist': whitelist,
      'customCategories': customCategories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// 从JSON创建实例
  factory UserValuesProfile.fromJson(Map<String, dynamic> json) {
    return UserValuesProfile(
      userId: json['userId'],
      templateWeights: Map<String, double>.from(json['templateWeights'] ?? {}),
      blacklist: List<String>.from(json['blacklist'] ?? []),
      whitelist: List<String>.from(json['whitelist'] ?? []),
      customCategories: (json['customCategories'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// 价值观管理Provider - 管理用户价值观模板和偏好
class ValuesProvider extends ChangeNotifier {
  @visibleForTesting
  List<ValueTemplateModel> _templates = [];
  UserValuesProfile? _userProfile;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ValueTemplateModel> get templates => List.unmodifiable(_templates);
  UserValuesProfile? get userProfile => _userProfile;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// 获取启用的模板
  List<ValueTemplateModel> get enabledTemplates => 
      _templates.where((template) => template.enabled).toList();
  
  /// 获取自定义模板
  List<ValueTemplateModel> get customTemplates => 
      _templates.where((template) => template.isCustom).toList();
  
  /// 获取预设模板
  List<ValueTemplateModel> get presetTemplates => 
      _templates.where((template) => !template.isCustom).toList();

  /// 按分类获取模板
  Map<String, List<ValueTemplateModel>> get templatesByCategory {
    final grouped = <String, List<ValueTemplateModel>>{};
    for (final template in _templates) {
      grouped.putIfAbsent(template.category, () => []).add(template);
    }
    return grouped;
  }

  /// 初始化价值观Provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      await _loadTemplates();
      await _loadUserProfile();
      
      _isInitialized = true;
      _clearError();
      notifyListeners(); // 确保初始化完成后通知监听器
    } catch (e) {
      _setError('价值观系统初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 用于测试的Box替代方法
  @visibleForTesting
  Box<ValueTemplateModel>? _testBox;
  
  // 获取当前使用的Box（测试时可能是_testBox）
  Box<ValueTemplateModel> get _currentBox => _testBox ?? StorageService.valueTemplateBox;
  
  /// 仅用于测试：设置自定义的测试Box
  @visibleForTesting
  void setTestBox(Box<ValueTemplateModel> box) {
    _testBox = box;
  }
  
  /// 加载价值观模板
  Future<void> _loadTemplates() async {
    final box = _currentBox;
    _templates = box.values.toList()
      ..sort((a, b) {
        // 先按分类排序，再按优先级排序
        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) return categoryCompare;
        return a.priority.compareTo(b.priority);
      });
  }

  /// 加载用户价值观档案
  Future<void> _loadUserProfile() async {
    // 从存储中加载用户价值观档案
    // 这里简化为创建默认档案
    _userProfile = UserValuesProfile(
      userId: 'default_user',
      templateWeights: {},
      blacklist: [],
      whitelist: [],
      customCategories: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 添加价值观模板
  Future<void> addTemplate(ValueTemplateModel template) async {
    _setLoading(true);
    
    try {
      final box = _currentBox;
      await box.put(template.id, template);
      
      // 优化：直接在内存中添加模板并重新排序，避免重新加载所有数据
      _templates.add(template);
      _sortTemplates();
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('添加价值观模板失败: $e');
      // 出错时重新加载以确保数据一致性
      await _loadTemplates();
    } finally {
      _setLoading(false);
    }
  }
  
  /// 对模板列表进行排序的辅助方法
  void _sortTemplates() {
    _templates.sort((a, b) {
      // 先按分类排序，再按优先级排序
      final categoryCompare = a.category.compareTo(b.category);
      if (categoryCompare != 0) return categoryCompare;
      return a.priority.compareTo(b.priority);
    });
  }

  /// 更新价值观模板
  Future<void> updateTemplate(ValueTemplateModel template) async {
    _setLoading(true);
    
    try {
      final updatedTemplate = template.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final box = _currentBox;
      await box.put(updatedTemplate.id, updatedTemplate);
      
      // 优化：直接在内存中更新模板并重新排序，避免重新加载所有数据
      final index = _templates.indexWhere((t) => t.id == updatedTemplate.id);
      if (index != -1) {
        _templates[index] = updatedTemplate;
        _sortTemplates();
      } else {
        // 如果找不到模板（可能是新加的），添加并排序
        _templates.add(updatedTemplate);
        _sortTemplates();
      }
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('更新价值观模板失败: $e');
      // 出错时重新加载以确保数据一致性
      await _loadTemplates();
    } finally {
      _setLoading(false);
    }
  }

  /// 删除价值观模板
  Future<void> removeTemplate(String templateId) async {
    _setLoading(true);
    
    try {
      final box = _currentBox;
      await box.delete(templateId);
      await _loadTemplates();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('删除价值观模板失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 启用/禁用模板
  Future<void> toggleTemplate(String templateId) async {
    final template = getTemplate(templateId);
    if (template != null) {
      final updatedTemplate = template.copyWith(
        enabled: !template.enabled,
        updatedAt: DateTime.now(),
      );
      await updateTemplate(updatedTemplate);
    }
  }

  /// 设置模板权重
  Future<void> setTemplateWeight(String templateId, double weight) async {
    final template = getTemplate(templateId);
    if (template != null) {
      final updatedTemplate = template.copyWith(
        weight: weight.clamp(0.0, 1.0),
        updatedAt: DateTime.now(),
      );
      await updateTemplate(updatedTemplate);
    }
  }

  /// 获取模板
  ValueTemplateModel? getTemplate(String templateId) {
    try {
      return _templates.firstWhere((template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }

  /// 创建自定义价值观模板
  ValueTemplateModel createCustomTemplate({
    required String name,
    required String category,
    required String description,
    List<String> keywords = const [],
    List<String> negativeKeywords = const [],
    double weight = 0.5,
  }) {
    return ValueTemplateModel(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      category: category,
      description: description,
      keywords: keywords,
      negativeKeywords: negativeKeywords,
      weight: weight,
      enabled: true,
      isCustom: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 更新用户价值观权重
  Future<void> updateUserWeight(String templateId, double weight) async {
    if (_userProfile != null) {
      final newWeights = Map<String, double>.from(_userProfile!.templateWeights);
      newWeights[templateId] = weight.clamp(0.0, 1.0);
      
      _userProfile = _userProfile!.copyWith(
        templateWeights: newWeights,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }

  /// 添加黑名单关键词
  Future<void> addBlacklistKeyword(String keyword) async {
    if (_userProfile != null && !_userProfile!.blacklist.contains(keyword)) {
      final newBlacklist = List<String>.from(_userProfile!.blacklist)..add(keyword);
      
      _userProfile = _userProfile!.copyWith(
        blacklist: newBlacklist,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }

  /// 移除黑名单关键词
  Future<void> removeBlacklistKeyword(String keyword) async {
    if (_userProfile != null) {
      final newBlacklist = List<String>.from(_userProfile!.blacklist)..remove(keyword);
      
      _userProfile = _userProfile!.copyWith(
        blacklist: newBlacklist,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }

  /// 添加白名单关键词
  Future<void> addWhitelistKeyword(String keyword) async {
    if (_userProfile != null && !_userProfile!.whitelist.contains(keyword)) {
      final newWhitelist = List<String>.from(_userProfile!.whitelist)..add(keyword);
      
      _userProfile = _userProfile!.copyWith(
        whitelist: newWhitelist,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }

  /// 移除白名单关键词
  Future<void> removeWhitelistKeyword(String keyword) async {
    if (_userProfile != null) {
      final newWhitelist = List<String>.from(_userProfile!.whitelist)..remove(keyword);
      
      _userProfile = _userProfile!.copyWith(
        whitelist: newWhitelist,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }

  /// 计算内容与用户价值观的匹配度
  double calculateMatchScore(
    String content, {
    Map<String, double>? customWeights,
  }) {
    if (_templates.isEmpty) return 0.5; // 默认中性分数
    
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    for (final template in enabledTemplates) {
      final templateWeight = customWeights?[template.id] ?? 
                            _userProfile?.templateWeights[template.id] ?? 
                            template.weight;
      
      // 计算关键词匹配分数
      double matchScore = _calculateKeywordMatch(content, template);
      
      totalScore += matchScore * templateWeight;
      totalWeight += templateWeight;
    }
    
    if (totalWeight == 0) return 0.5;
    
    double finalScore = totalScore / totalWeight;
    
    // 检查黑白名单
    finalScore = _applyBlackWhiteList(content, finalScore);
    
    return finalScore.clamp(0.0, 1.0);
  }

  /// 计算关键词匹配
  double _calculateKeywordMatch(String content, ValueTemplateModel template) {
    final contentLower = content.toLowerCase();
    double positiveMatch = 0.0;
    double negativeMatch = 0.0;
    
    // 正面关键词匹配
    for (final keyword in template.keywords) {
      if (contentLower.contains(keyword.toLowerCase())) {
        positiveMatch += 1.0;
      }
    }
    
    // 负面关键词匹配
    for (final keyword in template.negativeKeywords) {
      if (contentLower.contains(keyword.toLowerCase())) {
        negativeMatch += 1.0;
      }
    }
    
    if (template.keywords.isEmpty && template.negativeKeywords.isEmpty) {
      return 0.5; // 中性分数
    }
    
    // 计算匹配分数
    final totalKeywords = template.keywords.length + template.negativeKeywords.length;
    final score = (positiveMatch - negativeMatch) / totalKeywords;
    
    // 转换为0-1分数
    return (score + 1.0) / 2.0;
  }

  /// 应用黑白名单
  double _applyBlackWhiteList(String content, double baseScore) {
    if (_userProfile == null) return baseScore;
    
    final contentLower = content.toLowerCase();
    
    // 检查黑名单
    for (final keyword in _userProfile!.blacklist) {
      if (contentLower.contains(keyword.toLowerCase())) {
        return 0.0; // 强制为最低分
      }
    }
    
    // 检查白名单
    for (final keyword in _userProfile!.whitelist) {
      if (contentLower.contains(keyword.toLowerCase())) {
        return 1.0; // 强制为最高分
      }
    }
    
    return baseScore;
  }

  /// 获取价值观分析报告
  Map<String, dynamic> getValueAnalysisReport() {
    final enabledCount = enabledTemplates.length;
    final customCount = customTemplates.length;
    final categoryCount = templatesByCategory.length;
    
    final weightDistribution = <String, double>{};
    for (final template in enabledTemplates) {
      final weight = _userProfile?.templateWeights[template.id] ?? template.weight;
      weightDistribution[template.category] = 
          (weightDistribution[template.category] ?? 0.0) + weight;
    }
    
    return {
      'totalTemplates': _templates.length,
      'enabledTemplates': enabledCount,
      'customTemplates': customCount,
      'categories': categoryCount,
      'weightDistribution': weightDistribution,
      'blacklistKeywords': _userProfile?.blacklist.length ?? 0,
      'whitelistKeywords': _userProfile?.whitelist.length ?? 0,
      'lastUpdated': _userProfile?.updatedAt.toIso8601String(),
    };
  }

  /// 导出价值观配置
  Map<String, dynamic> exportValues() {
    return {
      'templates': _templates.map((t) => t.toJson()).toList(),
      'userProfile': _userProfile?.toJson(),
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// 导入价值观模板列表
  Future<void> importTemplates(List<ValueTemplateModel> templates) async {
    _setLoading(true);
    
    try {
      final box = _currentBox;
      
      for (final template in templates) {
        await box.put(template.id, template);
      }
      
      await _loadTemplates();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('导入价值观模板失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    _setLoading(true);
    
    try {
      final box = StorageService.valueTemplateBox;
      
      // 清除所有自定义模板
      final keysToDelete = <String>[];
      for (final template in _templates) {
        if (template.isCustom) {
          keysToDelete.add(template.id);
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      // 重置用户档案
      _userProfile = UserValuesProfile(
        userId: 'default_user',
        templateWeights: {},
        blacklist: [],
        whitelist: [],
        customCategories: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _loadTemplates();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('重置设置失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 导入价值观配置
  Future<bool> importValues(Map<String, dynamic> data) async {
    _setLoading(true);
    
    try {
      if (data.containsKey('templates')) {
        final templates = (data['templates'] as List)
            .map((json) => ValueTemplateModel.fromJson(json))
            .toList();
        
        final box = StorageService.valueTemplateBox;
        await box.clear();
        
        for (final template in templates) {
          await box.put(template.id, template);
        }
      }
      
      await _loadTemplates();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('导入价值观配置失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
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

}