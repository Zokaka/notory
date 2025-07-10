// stful
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/login/controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          // ✅ 增加 Form 包裹
          key: state.formKey, // ✅ 绑定 key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '账号'),
                onChanged: (v) => state.username.value = v,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入账号' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
                onChanged: (v) => state.password.value = v,
                validator: (v) => v == null || v.isEmpty ? '请输入密码' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: '验证码'),
                      onChanged: (v) => state.captcha.value = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? '请输入验证码' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.getCaptcha,
                    child: Obx(() {
                      final img = state.captchaImg.value;
                      if (img.isEmpty) {
                        return const SizedBox(width: 100, height: 40);
                      }
                      return Image.memory(
                        Uri.parse(img).data!.contentAsBytes(),
                        width: 100,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.onLogin,
                child: const Text('登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
