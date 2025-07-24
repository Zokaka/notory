import 'package:flutter/material.dart';

class MineItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;
  final bool showArrow;

  const MineItem({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // 设置背景色，确保 InkWell 效果可见
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(iconPath, width: 24, height: 24),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(fontSize: 16)),
                ],
              ),
              if (showArrow)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.chevron_right),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
