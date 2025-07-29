import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as get_x;

import '../router/route.dart';
import 'constant.dart';
import 'logger.dart';
import 'storage.dart';
import 'toast.dart';

/// 请求参数配置
class RequestOptions {
  final String? baseUrl;
  final Map<String, dynamic>? queryParameters;
  final Options? options;
  final bool refresh;
  final bool noCache;
  final bool list;
  final String cacheKey;
  final bool cacheDisk;

  RequestOptions({
    this.baseUrl,
    this.queryParameters,
    this.options,
    this.refresh = false,
    this.noCache = false,
    this.list = false,
    this.cacheKey = '',
    this.cacheDisk = false,
  });
}

/// API请求服务类（单例）
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late Dio _dio;
  CancelToken cancelToken = CancelToken();

  ApiService._internal() {
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
    } else {
      logger.i("Web 环境下不能使用 dio_cookie_manager");
    }

    _dio.interceptors.add(_defaultInterceptor());
  }

  /// 请求拦截器
  InterceptorsWrapper _defaultInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onResponse: (response, handler) {
        _onResponse(response);
        handler.next(response);
      },
      onError: (DioException e, handler) {
        ErrorEntity eInfo = _createErrorEntity(e);
        _onError(eInfo);
        return handler.next(e);
      },
    );
  }

  void _onResponse(Response response) {
    final res = response.data;
    logger.i('封装请求结果：$res');

    // 处理第三方接口返回的非标准格式（直接返回数组或对象）
    if (res is List) {
      // 如果是数组，直接返回，不做额外处理
      logger.i('第三方接口返回数组格式，直接返回');
      return;
    }

    if (res is Map<String, dynamic>) {
      // 检查是否包含标准的code和msg字段
      if (res.containsKey('code') && res.containsKey('msg')) {
        final code = res['code'];
        final msg = res['msg'];
        if (code == 7) {
          toastInfo(msg ?? '发生错误');
        }
      } else {
        // 第三方接口返回的对象格式，没有标准的code/msg结构
        logger.i('第三方接口返回对象格式，无标准code/msg结构');
      }
    }
  }

  void _onError(ErrorEntity eInfo) {
    logger.i('error.code -> ${eInfo.code}, error.message -> ${eInfo.message}');
    switch (eInfo.code) {
      case 401:
        get_x.Get.offAllNamed(AppRoutes.login);
        break;
      default:
        break;
    }
  }

  ErrorEntity _createErrorEntity(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ErrorEntity(code: -1, message: "请求取消");
      case DioExceptionType.connectionTimeout:
        return ErrorEntity(code: -1, message: "连接超时");
      case DioExceptionType.sendTimeout:
        return ErrorEntity(code: -1, message: "请求超时");
      case DioExceptionType.receiveTimeout:
        return ErrorEntity(code: -1, message: "响应超时");
      case DioExceptionType.badResponse:
        int errCode = error.response?.statusCode ?? -1;
        String errMsg = error.response?.statusMessage ?? "未知错误";
        return ErrorEntity(code: errCode, message: errMsg);
      default:
        return ErrorEntity(code: -1, message: error.message ?? "未知异常");
    }
  }

  /// 获取认证请求头
  Future<Map<String, dynamic>> _getAuthorizationHeader() async {
    var headers = <String, dynamic>{};
    String? token = SPUtils.getString('AppAuthToken');
    if (token != null && token.isNotEmpty) headers['X-Token'] = token;
    return headers;
  }

  /// 创建带baseUrl的Dio实例
  Dio _getDioWithBaseUrl(String? baseUrl) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      final options = _dio.options.copyWith(baseUrl: baseUrl);
      final newDio = Dio(options);

      // 复制拦截器
      for (var interceptor in _dio.interceptors) {
        newDio.interceptors.add(interceptor);
      }
      return newDio;
    }
    return _dio;
  }
}

/// 统一请求方法（类似Vue的request函数）
Future<T> request<T>({
  required String url,
  required String method,
  dynamic data,
  Map<String, dynamic>? queryParameters,
  String? baseUrl,
  Options? options,
  bool refresh = false,
  bool noCache = false,
  bool list = false,
  String cacheKey = '',
  bool cacheDisk = false,
}) async {
  final apiService = ApiService();
  final dio = apiService._getDioWithBaseUrl(baseUrl);

  // 准备请求选项
  Options requestOptions = options ?? Options();
  requestOptions.extra = {
    "refresh": refresh,
    "noCache": noCache,
    "list": list,
    "cacheKey": cacheKey,
    "cacheDisk": cacheDisk,
  };
  requestOptions.headers = await apiService._getAuthorizationHeader();

  Response response;

  try {
    switch (method.toLowerCase()) {
      case 'get':
        response = await dio.get(
          url,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: apiService.cancelToken,
        );
        break;
      case 'post':
        response = await dio.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: apiService.cancelToken,
        );
        break;
      case 'put':
        response = await dio.put(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: apiService.cancelToken,
        );
        break;
      case 'patch':
        response = await dio.patch(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: apiService.cancelToken,
        );
        break;
      case 'delete':
        response = await dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: apiService.cancelToken,
        );
        break;
      default:
        throw ArgumentError('不支持的请求方法: $method');
    }

    // 直接返回业务数据，类似Vue项目的习惯
    return response.data as T;
  } catch (e) {
    rethrow;
  }
}

/// 便捷的HTTP方法封装
class Http {
  /// GET请求
  static Future<T> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
    bool refresh = false,
    bool noCache = false,
    bool list = false,
    String cacheKey = '',
    bool cacheDisk = false,
  }) {
    return request<T>(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
      refresh: refresh,
      noCache: noCache,
      list: list,
      cacheKey: cacheKey,
      cacheDisk: cacheDisk,
    );
  }

  /// POST请求
  static Future<T> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
  }) {
    return request<T>(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// PUT请求
  static Future<T> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
  }) {
    return request<T>(
      url: url,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// PATCH请求
  static Future<T> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
  }) {
    return request<T>(
      url: url,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// DELETE请求
  static Future<T> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
  }) {
    return request<T>(
      url: url,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// 表单提交
  static Future<T> postForm<T>(
    String url, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Options? options,
  }) async {
    final formData = FormData.fromMap(data);
    return request<T>(
      url: url,
      method: 'POST',
      data: formData,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// 文件上传
  static Future<T> upload<T>(
    String url, {
    required dynamic data,
    required List<File> files,
    String? baseUrl,
    Options? options,
  }) async {
    final formData = FormData.fromMap(data);
    // 添加文件到FormData
    for (var file in files) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path),
      ));
    }

    return request<T>(
      url: url,
      method: 'POST',
      data: formData,
      baseUrl: baseUrl,
      options: options,
    );
  }

  /// 下载文件
  static Future<Response> download(
    String url,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    final apiService = ApiService();
    final dio = apiService._getDioWithBaseUrl(baseUrl);

    return dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken ?? apiService.cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }
}

/// 异常类
class ErrorEntity implements Exception {
  int code;
  String message;

  ErrorEntity({required this.code, required this.message});

  @override
  String toString() =>
      message.isEmpty ? "Exception" : "Exception: code $code, $message";
}
