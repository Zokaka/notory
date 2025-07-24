import 'package:flutter/material.dart';

class ShadowContainer extends StatelessWidget {
  final double? height;
  final Widget child;

  const ShadowContainer({
    super.key,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, // 为空时会自动根据 child 高度撑开
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            // 顶部阴影
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            // 底部阴影
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
