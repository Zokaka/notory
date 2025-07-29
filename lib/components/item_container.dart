import 'package:flutter/material.dart';

class ItemContainer extends StatelessWidget {
  final double? height;
  final Widget child;

  const ItemContainer({
    super.key,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, // 为空时会自动根据 child 高度撑开
      margin: const EdgeInsets.symmetric(horizontal: 15), // ✅ 设置左右外边距
      decoration: BoxDecoration(
        color: Colors.white,
        // 圆角
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6), // 必须和外层一致
        child: child,
      ),
    );
  }
}
