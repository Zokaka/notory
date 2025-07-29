// auth_api.dart
// 重构后的认证API，类似Vue项目风格
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/request.dart';

class AuthAPI {
  // 如果需要使用不同的baseUrl，可以在这里定义
  static const String? _baseUrl =
      "https://api.dictionaryapi.dev/api/v2"; // 为null时使用默认baseUrl

  /// 获取验证码
  static Future<Map<String, dynamic>> getCaptcha() async {
    final response = await Http.post<Map<String, dynamic>>('/base/captcha');
    // 直接返回data字段的内容
    return response['data'];
  }

  /// 登录
  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await Http.post<Map<String, dynamic>>(
      '/base/login',
      data: data,
    );
    return response['data'];
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    final response = await Http.get<Map<String, dynamic>>('/user/getUserInfo');
    // 如果接口直接返回用户信息，不包装在data字段中
    return response;
  }

  /// 签到
  static Future<Map<String, dynamic>> checkIn() async {
    final res = await Http.post('/walletBase/getDailyReward');
    logger.i("签到结果：$res");
    return res;
  }

  /// 单词查询
  static Future<Map<String, dynamic>> wordSearch(String word) async {
    logger.i("查询词语：$word");
    final response = await Http.post<Map<String, dynamic>>(
      '/toolTranslationWords/createToolTranslationWords',
      data: {"word": word},
    );
    return response['data'];
  }
}
