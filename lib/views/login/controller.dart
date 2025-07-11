import 'dart:convert';

import 'package:get/get.dart';
import 'package:notory/api/auth/index.dart';
import 'package:notory/router/route.dart';
import 'package:notory/utils/storage.dart';
import 'package:notory/utils/toast.dart';
import 'package:notory/views/login/state.dart';

class LoginController extends GetxController {
  LoginController();

  /// 变量对象
  final state = LoginState();

  @override
  void onInit() {
    super.onInit();
    getCaptcha();
  }

  /// 获取验证码
  void getCaptcha() async {
    try {
      final data = await AuthAPI.getCaptcha();
      state.captchaId.value = data['captchaId'];
      state.captchaImg.value = data['picPath'];
    } catch (e) {
      print('获取验证码失败：');
      toastInfo('验证码加载失败');
    }
  }

  /// 登录操作
  void onLogin() async {
    if (!(state.formKey.currentState?.validate() ?? false)) return;

    final data = {
      'username': state.username.value,
      'password': state.password.value,
      'captcha': state.captcha.value,
      'captchaId': state.captchaId.value,
      'openCaptcha': true,
      'smsCaptcha': '',
      'confirmPassword': ''
    };

    try {
      final res = await AuthAPI.login(data);
      await SPUtils.setString('AppAuthToken', res['token']);
      // jsonEncode需要引入dart:convert
      await SPUtils.setString('UserInfo', jsonEncode(res['user']));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      getCaptcha(); // 刷新验证码
    }
  }
}
