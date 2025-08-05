// api_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as get_x;
import 'package:notory/router/route.dart';

import 'constant.dart';
import 'logger.dart';
import 'storage.dart';
import 'toast.dart';

// api_response.dart
/// 统一的API响应格式
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final bool success;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  }) : success = code == 0;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] ?? -1,
      message: json['msg'] ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }

  /// 创建成功响应
  factory ApiResponse.success(T data, {String message = '操作成功'}) {
    return ApiResponse<T>(
      code: 0,
      message: message,
      data: data,
    );
  }

  /// 创建失败响应
  factory ApiResponse.error(int code, String message) {
    return ApiResponse<T>(
      code: code,
      message: message,
    );
  }

  @override
  String toString() =>
      'ApiResponse(code: $code, message: $message, data: $data)';
}

// request_exception.dart
/// 请求异常类
class RequestException implements Exception {
  final int code;
  final String message;
  final String? details;

  RequestException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'RequestException(code: $code, message: $message)';
}

/// API请求服务类（单例）
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late Dio _dio;
  CancelToken cancelToken = CancelToken();

  ApiService._internal() {
    _initDio();
  }

  void _initDio() {
    BaseOptions options = BaseOptions(
      baseUrl: HttpConfig.apiServiceUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    _dio = Dio(options);

    // Web 环境不使用 CookieManager
    if (!kIsWeb) {
      CookieJar cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    _dio.interceptors.add(_createInterceptor());
  }

  /// 创建拦截器
  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证头
        final authHeaders = await _getAuthorizationHeader();
        options.headers.addAll(authHeaders);

        // logger.d('请求: ${options.method} ${options.baseUrl}${options.path}');
        // logger.d('请求头: ${options.headers}');
        if (options.data != null) {
          logger.d('请求体: ${options.data}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.responseType != ResponseType.stream) {
          _handleResponse(response);
        }
        handler.next(response);
      },
      onError: (DioException e, handler) {
        _handleError(e);
        handler.next(e);
      },
    );
  }

  /// 处理响应
  void _handleResponse(Response response) {
    final data = response.data;

    // 处理非标准格式响应
    if (data is List) {
      logger.i('接口返回数组格式');
      return;
    }

    if (data is Map<String, dynamic>) {
      final code = data['code'];
      final message = data['msg'] ?? '';

      logger.i('响应: code=$code, message=$message');

      // 根据不同的code做处理
      switch (code) {
        case 0:
          // 成功，不做特殊处理
          break;
        case 7:
          // 业务提示信息
          if (message.isNotEmpty) {
            toastInfo(message);
          }
          break;
        case 401:
          // 未授权，跳转到登录页
          _handleUnauthorized();
          break;
        default:
          // 其他错误码
          if (message.isNotEmpty) {
            toastInfo(message);
          }
          break;
      }
    }
  }

  /// 处理错误
  void _handleError(DioException error) {
    String message;
    int code;

    switch (error.type) {
      case DioExceptionType.cancel:
        message = "请求已取消";
        code = -1;
        break;
      case DioExceptionType.connectionTimeout:
        message = "连接超时";
        code = -2;
        break;
      case DioExceptionType.sendTimeout:
        message = "发送超时";
        code = -3;
        break;
      case DioExceptionType.receiveTimeout:
        message = "接收超时";
        code = -4;
        break;
      case DioExceptionType.badResponse:
        code = error.response?.statusCode ?? -5;
        message = error.response?.statusMessage ?? "服务器错误";
        break;
      default:
        code = -6;
        message = error.message ?? "网络异常";
        break;
    }

    logger.e('请求错误: code=$code, message=$message');

    // 显示错误提示
    toastInfo(message);
  }

  /// 处理未授权
  void _handleUnauthorized() {
    logger.w('用户未授权，跳转到登录页');
    SPUtils.remove('AppAuthToken');
    get_x.Get.offAllNamed(AppRoutes.login);
  }

  /// 获取认证请求头
  Future<Map<String, dynamic>> _getAuthorizationHeader() async {
    var headers = <String, dynamic>{};
    String? token = SPUtils.getString('AppAuthToken');
    if (token != null && token.isNotEmpty) {
      headers['X-Token'] = token;
    }
    return headers;
  }

  /// 创建带baseUrl的Dio实例
  Dio _createDioWithBaseUrl(String? baseUrl) {
    if (baseUrl == null || baseUrl.isEmpty) {
      return _dio;
    }

    final options = _dio.options.copyWith(baseUrl: baseUrl);
    final newDio = Dio(options);

    // 复制拦截器
    for (var interceptor in _dio.interceptors) {
      newDio.interceptors.add(interceptor);
    }

    return newDio;
  }

  /// 通用请求方法
  Future<ApiResponse<T>> request<T>({
    required String url,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = _createDioWithBaseUrl(baseUrl);
      final requestOptions = options ?? Options();

      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(
            url,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        case 'POST':
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        case 'PUT':
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        default:
          throw ArgumentError('不支持的请求方法: $method');
      }

      // 处理响应数据
      final responseData = response.data;

      // 如果是标准格式的响应
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('code')) {
        final apiResponse = ApiResponse<T>.fromJson(responseData, fromJson);

        // 如果是业务错误，抛出异常
        if (!apiResponse.success) {
          throw RequestException(
            code: apiResponse.code,
            message: apiResponse.message,
          );
        }

        return apiResponse;
      }

      // 如果是非标准格式，直接包装成功响应
      return ApiResponse<T>.success(
        fromJson != null ? fromJson(responseData) : responseData as T,
      );
    } on DioException catch (e) {
      throw RequestException(
        code: e.response?.statusCode ?? -1,
        message: e.message ?? '网络请求失败',
        details: e.toString(),
      );
    }
  }

  /// 流式请求
  Future<void> streamRequest({
    required String url,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    CancelToken? cancelToken,
    required void Function(String chunk) onData,
    void Function(RequestException error)? onError,
    void Function()? onDone,
  }) async {
    try {
      final dio = _createDioWithBaseUrl(baseUrl);

      final requestOptions = (options ?? Options()).copyWith(
        responseType: ResponseType.stream,
      );

      Response<ResponseBody> response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get<ResponseBody>(
            url,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        case 'POST':
          response = await dio.post<ResponseBody>(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken ?? this.cancelToken,
          );
          break;
        default:
          throw ArgumentError('流式请求暂不支持方法: $method');
      }

      logger.i("✅ 流式连接成功：${response.statusCode}");

      final stream = response.data!.stream;
      final transformer = utf8.decoder.bind(stream);

      await for (final chunk in transformer) {
        if (chunk.trim().isNotEmpty) {
          onData(chunk);
        }
      }

      onDone?.call();
    } on DioException catch (e) {
      final error = RequestException(
        code: e.response?.statusCode ?? -1,
        message: e.message ?? '流式请求失败',
        details: e.toString(),
      );
      logger.e("❌ 流式请求错误：$error");
      onError?.call(error);
    } catch (e) {
      final error = RequestException(
        code: -1,
        message: '流式请求异常',
        details: e.toString(),
      );
      logger.e("❌ 流式请求异常：$error");
      onError?.call(error);
    }
  }
}

// http_client.dart
/// HTTP客户端封装
class HttpClient {
  static final ApiService _apiService = ApiService();

  /// GET请求
  static Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    return _apiService.request<T>(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// POST请求
  static Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    return _apiService.request<T>(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// PUT请求
  static Future<ApiResponse<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    return _apiService.request<T>(
      url: url,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// PATCH请求
  static Future<ApiResponse<T>> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    return _apiService.request<T>(
      url: url,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// DELETE请求
  static Future<ApiResponse<T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    return _apiService.request<T>(
      url: url,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// 表单提交
  static Future<ApiResponse<T>> postForm<T>(
    String url, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) {
    final formData = FormData.fromMap(data);
    return post<T>(
      url,
      data: formData,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// 文件上传
  static Future<ApiResponse<T>> upload<T>(
    String url, {
    required Map<String, dynamic> data,
    required List<File> files,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
    String fileFieldName = 'files',
  }) async {
    final formData = FormData.fromMap(data);

    // 添加文件
    for (var file in files) {
      formData.files.add(MapEntry(
        fileFieldName,
        await MultipartFile.fromFile(file.path),
      ));
    }

    return post<T>(
      url,
      data: formData,
      baseUrl: baseUrl,
      options: options,
      fromJson: fromJson,
      cancelToken: cancelToken,
    );
  }

  /// 下载文件
  static Future<Response> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Object? data,
    Options? options,
  }) async {
    final dio = _apiService._createDioWithBaseUrl(baseUrl);

    return dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken ?? _apiService.cancelToken,
      deleteOnError: deleteOnError,
      data: data,
      options: options,
    );
  }

  /// 流式POST请求
  static Future<void> postStream(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    CancelToken? cancelToken,
    required void Function(String chunk) onData,
    void Function(RequestException error)? onError,
    void Function()? onDone,
  }) {
    return _apiService.streamRequest(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      cancelToken: cancelToken,
      onData: onData,
      onError: onError,
      onDone: onDone,
    );
  }

  /// 流式GET请求
  static Future<void> getStream(
    String url, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    CancelToken? cancelToken,
    required void Function(String chunk) onData,
    void Function(RequestException error)? onError,
    void Function()? onDone,
  }) {
    return _apiService.streamRequest(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      cancelToken: cancelToken,
      onData: onData,
      onError: onError,
      onDone: onDone,
    );
  }
}
