// models/user_info.dart
import 'package:notory/api/auth/types.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/request.dart';

// apis/auth_api.dart
/// 认证相关API
class AuthAPI {
  static const String _baseUrl = ''; // 使用默认baseUrl

  /// 获取验证码
  static Future<Map<String, dynamic>?> getCaptcha() async {
    try {
      final response = await HttpClient.post<Map<String, dynamic>>(
        '/base/captcha',
      );
      // logger.i('API-获取验证码-RES $response');
      // 直接返回验证码图片base64或URL
      return response.data;
    } on RequestException catch (e) {
      logger.i('获取验证码失败: ${e.message}');
      rethrow;
    }
  }

  /// 登录
  static Future<Map<String, dynamic>> login(
    Map<String, dynamic>? data, {
    String? username,
    String? password,
    String? captcha,
  }) async {
    try {
      // 处理参数
      Map<String, dynamic> loginData;

      if (data != null) {
        // 使用传入的data对象
        loginData = data;
      } else {
        // 使用具体参数构建data
        if (username == null || password == null) {
          throw RequestException(
            code: -1,
            message: '用户名和密码不能为空',
          );
        }

        loginData = {
          'username': username,
          'password': password,
          if (captcha != null) 'captcha': captcha,
        };
      }

      logger.i("登录请求：${loginData.keys.toList()}"); // 只打印键名，不打印敏感信息

      final response = await HttpClient.post<Map<String, dynamic>>(
        '/base/login',
        data: loginData,
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw RequestException(
          code: response.code,
          message: response.message,
        );
      }
    } on RequestException {
      rethrow;
    } catch (e) {
      logger.e("登录异常：$e");
      throw RequestException(
        code: -1,
        message: '登录失败: ${e.toString()}',
      );
    }
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await HttpClient.get<Map<String, dynamic>>(
        '/user/getUserInfo',
      );

      if (response.success && response.data != null) {
        logger.i('获取用户信息：$response');
        return response.data!;
      } else {
        throw RequestException(
          code: response.code,
          message: response.message,
        );
      }
    } on RequestException {
      rethrow;
    }
  }

  /// 签到
  static Future<UserInfo> checkIn() async {
    try {
      final response = await HttpClient.post<Map<String, dynamic>>(
        '/walletBase/getDailyReward',
      );

      if (response.success && response.data != null) {
        return UserInfo.fromJson(response.data!);
      } else {
        throw RequestException(
          code: response.code,
          message: response.message,
        );
      }
    } on RequestException {
      rethrow;
    }
  }
}
