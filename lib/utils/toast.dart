import 'package:flutter/material.dart';
import 'package:notory/main.dart';

/// 全平台兼容的 toast 提示
void toastInfo(String msg, {Color backgroundColor = Colors.black}) {
  final context = navigatorKey.currentContext;

  if (context == null) {
    debugPrint('❌ toastInfo: context is null');
    return;
  }

  ScaffoldMessenger.of(context).clearSnackBars(); // 清除旧的
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2),
    ),
  );
}
