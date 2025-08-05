import 'package:dio/dio.dart';
import 'package:notory/utils/request.dart';

class ChatApi {
  /// 方式1：使用 Http.postStream（推荐）
  static Future<void> getDefinitionStream({
    required String word,
    required void Function(String chunk) onData,
    void Function(dynamic error)? onError,
    void Function()? onDone,
    CancelToken? cancelToken,
  }) async {
    await Http.postStream(
      '/toolTranslationWords/createToolTranslationWords',
      data: {
        'word': word,
        'stream': true,
      },
      cancelToken: cancelToken,
      onData: onData,
      onError: onError,
      onDone: onDone,
    );
  }
}
