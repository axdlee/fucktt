import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/ai_provider_model.dart';
import 'ai_service_interface.dart';

/// OpenAI兼容的AI服务实现
/// 支持OpenAI、DeepSeek、通义千问等兼容OpenAI API格式的服务
class OpenAICompatibleService implements AIService {
  final AIProviderModel _provider;
  final Dio _dio;

  OpenAICompatibleService(this._provider) : _dio = Dio() {
    _configureClient();
  }

  @override
  AIProviderModel get provider => _provider;

  void _configureClient() {
    _dio.options.baseUrl = _provider.baseUrl;
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_provider.apiKey}',
      ..._provider.headers,
    });
    
    // 设置超时时间
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 120);
    
    // 添加拦截器用于日志和错误处理
    _dio.interceptors.add(LogInterceptor(
      requestBody: false, // 避免记录敏感信息
      responseBody: false,
    ));
  }

  @override
  Future<bool> checkAvailability() async {
    try {
      final response = await _dio.get('/models');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AIResponse> chat({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final model = modelId ?? _getDefaultModel();
      final request = _buildChatRequest(prompt, model, parameters);
      
      final response = await _dio.post('/chat/completions', data: request);
      
      if (response.statusCode == 200) {
        return _parseResponse(response.data, model);
      } else {
        throw AIServiceException(
          'API请求失败: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      throw AIServiceException(
        _handleDioError(e),
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      throw AIServiceException('请求失败: $e');
    }
  }

  @override
  Stream<String> chatStream({
    required String prompt,
    String? modelId,
    Map<String, dynamic>? parameters,
  }) async* {
    try {
      final model = modelId ?? _getDefaultModel();
      final request = _buildChatRequest(prompt, model, parameters);
      request['stream'] = true;
      
      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        data: request,
        options: Options(responseType: ResponseType.stream),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final stream = response.data!.stream.map((event) => event as List<int>);
        await for (final chunk in stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();
              if (data == '[DONE]') return;
              
              try {
                final json = jsonDecode(data);
                final delta = json['choices']?[0]?['delta'];
                if (delta != null && delta['content'] != null) {
                  yield delta['content'] as String;
                }
              } catch (e) {
                // 忽略解析错误的行
                continue;
              }
            }
          }
        }
      }
    } on DioException catch (e) {
      throw AIServiceException(_handleDioError(e));
    } catch (e) {
      throw AIServiceException('流式请求失败: $e');
    }
  }

  @override
  Future<List<ModelConfig>> getAvailableModels() async {
    try {
      final response = await _dio.get('/models');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] is List) {
          return (data['data'] as List).map((model) {
            return ModelConfig(
              modelId: model['id'] as String,
              displayName: model['id'] as String,
              description: model['object'] as String?,
            );
          }).toList();
        }
      }
      
      // 如果API不支持获取模型列表，返回预配置的模型
      return _provider.supportedModels;
    } catch (e) {
      // 返回预配置的模型作为后备
      return _provider.supportedModels;
    }
  }

  @override
  Future<bool> validateConfiguration() async {
    try {
      // 发送一个简单的测试请求
      final testPrompt = '测试连接，请回复"连接成功"';
      final response = await chat(prompt: testPrompt);
      return response.success && response.content.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String _getDefaultModel() {
    if (_provider.supportedModels.isNotEmpty) {
      return _provider.supportedModels.first.modelId;
    }
    
    // 根据服务商返回默认模型
    switch (_provider.name.toLowerCase()) {
      case 'openai':
        return 'gpt-3.5-turbo';
      case 'deepseek':
        return 'deepseek-chat';
      case 'alibaba':
        return 'qwen-turbo';
      case 'baidu':
        return 'ernie-bot-turbo';
      default:
        return 'gpt-3.5-turbo';
    }
  }

  Map<String, dynamic> _buildChatRequest(
    String prompt,
    String model,
    Map<String, dynamic>? parameters,
  ) {
    final messages = [
      ChatMessage(role: 'user', content: prompt).toJson(),
    ];

    final request = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 2048,
    };

    // 应用自定义参数
    if (parameters != null) {
      request.addAll(parameters);
    }

    // 应用模型特定配置
    final modelConfig = _provider.supportedModels
        .where((config) => config.modelId == model)
        .firstOrNull;
    
    if (modelConfig != null) {
      request['temperature'] = modelConfig.temperature;
      request['max_tokens'] = modelConfig.maxTokens;
      if (modelConfig.topP != null) {
        request['top_p'] = modelConfig.topP;
      }
      if (modelConfig.frequencyPenalty != null) {
        request['frequency_penalty'] = modelConfig.frequencyPenalty;
      }
      if (modelConfig.presencePenalty != null) {
        request['presence_penalty'] = modelConfig.presencePenalty;
      }
      request.addAll(modelConfig.parameters);
    }

    return request;
  }

  AIResponse _parseResponse(Map<String, dynamic> data, String model) {
    try {
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AIServiceException('响应格式错误：缺少choices字段');
      }

      final choice = choices.first;
      final message = choice['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw AIServiceException('响应格式错误：缺少message字段');
      }

      final content = message['content'] as String? ?? '';
      final usage = data['usage'] as Map<String, dynamic>? ?? {};

      return AIResponse(
        content: content,
        modelId: model,
        usage: usage,
        timestamp: DateTime.now(),
        success: true,
        metadata: {
          'finishReason': choice['finish_reason'],
          'rawResponse': data,
        },
      );
    } catch (e) {
      throw AIServiceException('解析响应失败: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络连接';
      case DioExceptionType.sendTimeout:
        return '请求超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        
        if (statusCode == 401) {
          return 'API密钥无效，请检查配置';
        } else if (statusCode == 429) {
          return '请求频率过高，请稍后重试';
        } else if (statusCode == 500) {
          return 'AI服务内部错误，请稍后重试';
        }
        
        if (errorData is Map && errorData.containsKey('error')) {
          final error = errorData['error'];
          if (error is Map && error.containsKey('message')) {
            return error['message'] as String;
          }
        }
        
        return '请求失败 (HTTP $statusCode)';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.unknown:
        return '网络连接失败，请检查网络设置';
      default:
        return '未知错误: ${e.message}';
    }
  }

  void dispose() {
    _dio.close();
  }
}

extension on List<ModelConfig> {
  ModelConfig? get firstOrNull => isEmpty ? null : first;
}