// dio_service.dart
// 封装 Dio 的 API 管理类，统一管理请求方法、异常处理、拦截器、认证等逻辑。

import 'dart:convert';
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

/// API服务类（单例）
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  late Dio _dio;
  CancelToken cancelToken = CancelToken();

  /// 构造函数（初始化 Dio 配置）
  ApiService._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: HttpConfig.apiServiceUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
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

  /// 请求拦截器（包含请求、响应、错误处理）
  InterceptorsWrapper _defaultInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onResponse: (response, handler) => handler.next(response),
      onError: (DioException e, handler) {
        ErrorEntity eInfo = createErrorEntity(e);
        onError(eInfo);
        return handler.next(e);
      },
    );
  }

  /// 异常处理逻辑
  void onError(ErrorEntity eInfo) {
    logger.i('error.code -> ${eInfo.code}, error.message -> ${eInfo.message}');
    switch (eInfo.code) {
      case 401:
        get_x.Get.offAllNamed(AppRoutes.login);
        break;
      default:
        // toastInfo("未知错误");
        break;
    }
  }

  /// 构造 ErrorEntity
  ErrorEntity createErrorEntity(DioException error) {
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

  /// 取消请求
  void cancelRequests(CancelToken token) => token.cancel("cancelled");

  /// 获取认证请求头
  Future<Map<String, dynamic>> getAuthorizationHeader() async {
    var headers = <String, dynamic>{};
    String? token = SPUtils.getString('AppAuthToken');
    if (token != null && token.isNotEmpty) headers['X-Token'] = token;
    return headers;
  }

  // ================================
  // ========== HTTP 方法 ===========
  // ================================

  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool refresh = false,
    bool noCache = HttpConfig.cacheEnable,
    bool list = false,
    String cacheKey = '',
    bool cacheDisk = false,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra = {
      "refresh": refresh,
      "noCache": noCache,
      "list": list,
      "cacheKey": cacheKey,
      "cacheDisk": cacheDisk,
    };
    requestOptions.headers = (await getAuthorizationHeader());

    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final headers = await getAuthorizationHeader();
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options())..headers = headers,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async =>
      _dio
          .put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: (options ?? Options())
              ..headers = await getAuthorizationHeader(),
            cancelToken: cancelToken,
          )
          .then((r) => r.data);

  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async =>
      _dio
          .patch(
            path,
            data: data,
            queryParameters: queryParameters,
            options: (options ?? Options())
              ..headers = await getAuthorizationHeader(),
            cancelToken: cancelToken,
          )
          .then((r) => r.data);

  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async =>
      _dio
          .delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: (options ?? Options())
              ..headers = await getAuthorizationHeader(),
            cancelToken: cancelToken,
          )
          .then((r) => r.data);

  /// 表单提交 postForm
  Future postForm(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async =>
      _dio
          .post(
            path,
            data: FormData.fromMap(data),
            queryParameters: queryParameters,
            options: (options ?? Options())
              ..headers = await getAuthorizationHeader(),
            cancelToken: cancelToken,
          )
          .then((r) => r.data);

  /// 下载文件
  Future getDownload(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async =>
      _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

  /// 流式请求（用于 SSE 等场景）
  Future<void> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancel,
    required void Function(dynamic) onData,
    void Function(dynamic)? onError,
    void Function()? onDone,
  }) async {
    final headers = await getAuthorizationHeader();
    final requestOptions = (options ?? Options())
      ..headers = headers
      ..responseType = ResponseType.stream
      ..headers!["Accept"] = "text/event-stream";

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancel,
      );

      final stream = utf8.decoder.bind(response.data.stream);
      String buffer = '';

      stream.listen(
        (chunk) {
          buffer += chunk;
          while (buffer.contains('\n\n')) {
            final splitIndex = buffer.indexOf('\n\n');
            final rawEvent = buffer.substring(0, splitIndex);
            buffer = buffer.substring(splitIndex + 2);

            if (rawEvent.startsWith('data:')) {
              final dataLines = rawEvent
                  .split('\n')
                  .where((line) => line.startsWith('data:'))
                  .map((line) => line.substring(5).trim())
                  .join('\n');

              try {
                final decodedData = jsonDecode(dataLines);
                onData(decodedData);
              } catch (e) {
                logger.i("数据解析错误\n\$dataLines");
                toastInfo("数据解析错误");
              }
            }
          }
        },
        onError: onError,
        onDone: onDone,
      );
    } catch (e) {
      if (cancel?.isCancelled == true) {
        onError?.call('请求已被取消');
      } else {
        onError?.call(e);
        rethrow;
      }
    }
  }

  /// 上传文件接口
  Future postWithFiles(
    String url, {
    required dynamic data,
    required List<File> files,
  }) async {
    final formData = FormData.fromMap(data);
    final response = await _dio.post(url, data: formData);
    toastInfo("上传成功: \${response.data}");
    return response.data;
  }
}

/// 异常类
class ErrorEntity implements Exception {
  int code;
  String message;

  ErrorEntity({required this.code, required this.message});

  @override
  String toString() =>
      message.isEmpty ? "Exception" : "Exception: code \$code, \$message";
}
