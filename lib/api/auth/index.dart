import 'package:notory/utils/request.dart';

class AuthAPI {
  static final _http = ApiService();

  /// 获取验证码
  static Future<Map<String, dynamic>> getCaptcha() async {
    final res = await _http.post('/base/captcha');
    return res['data'];
  }

  /// 登录
  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    print('请求体：$data');
    final res = await _http.post('/base/login', data: data);
    print('登录：$res');
    return res['data'];
  }
}
