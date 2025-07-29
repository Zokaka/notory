import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/request.dart'; // 👈 关键：使用你封装好的请求系统

class ChatApi {
  static Future<void> getDefinitionStream({
    required String word,
    required void Function(String chunk) onData,
    void Function(dynamic error)? onError,
    void Function()? onDone,
    CancelToken? cancelToken,
  }) async {
    final dio = ApiService()._dio(); // 👈 使用默认 baseUrl
    try {
      final response = await dio.post<ResponseBody>(
        '/toolTranslationWords/createToolTranslationWords',
        data: {
          'word': word,
          'stream': true,
        },
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      logger.i("✅ 正常连接流：${response.statusCode}");

      final stream = response.data!.stream;
      final transformer = utf8.decoder.bind(stream);
      await for (final line in transformer) {
        if (line.trim().isNotEmpty) {
          onData(line);
        }
      }

      onDone?.call();
    } catch (e) {
      logger.i("❌ 流式内容报错：$e");
      onError?.call(e);
    }
  }
}
