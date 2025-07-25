// stful
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/login/controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  // ✅ 抽取统一样式输入框
  Widget _buildInputField({
    required String hintText,
    bool obscureText = false,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            // ✅ 增加 Form 包裹
            key: state.formKey, // ✅ 绑定 key
            child: Column(
              // 待补充
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Logo 图片
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                // ✅ 项目名
                const Text(
                  'Notory',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '专注记录每一个灵感',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // ✅ 输入框：账号
                _buildInputField(
                  hintText: '请输入用户名或手机号',
                  onChanged: (v) => state.username.value = v,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '请输入账号' : null,
                ),
                const SizedBox(height: 12),
                // ✅ 输入框：密码
                _buildInputField(
                  hintText: '请输入密码',
                  obscureText: true,
                  onChanged: (v) => state.password.value = v,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '请输入密码' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        hintText: '请输入验证码',
                        onChanged: (v) => state.captcha.value = v,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? '请输入验证码' : null,
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
                const SizedBox(height: 32),
                // ✅ 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.onLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('登录'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // padding: const EdgeInsets.all(24)
      ),
    );
  }
}
