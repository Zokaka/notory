import 'dart:convert';

import 'package:get/get.dart';
import 'package:notory/api/auth/index.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/storage.dart';
import 'package:notory/utils/toast.dart';
import 'package:notory/views/login/state.dart';

import '../../router/route.dart';

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
      // logger.i('验证码信息：$data');
      state.captchaId.value = data?['captchaId'];
      state.captchaImg.value = data?['picPath'];
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
      logger.i('登录返回：$res');
      await SPUtils.setString('AppAuthToken', res['token']);
      await SPUtils.setString('UserInfo', jsonEncode(res['user']));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      getCaptcha(); // 刷新验证码
    }
  }
}
