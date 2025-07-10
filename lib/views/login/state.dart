import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginState {
  RxString username = ''.obs;
  RxString password = ''.obs;
  RxString captcha = ''.obs;
  RxString captchaId = ''.obs;
  RxString captchaImg = ''.obs;

  // 好像是'package:flutter/material.dart'的内置方法
  final formKey = GlobalKey<FormState>();
}
