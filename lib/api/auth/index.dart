import 'package:notory/utils/logger.dart';
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
    final res = await _http.post('/base/login', data: data);
    return res['data'];
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    final res = await _http.get('/user/getUserInfo');
    return res;
  }

  /// 签到
  static Future<Map<String, dynamic>> checkIn() async {
    final res = await _http.post('/walletBase/getDailyReward');
    logger.i("签到结果：$res");
    return res;
  }
}
