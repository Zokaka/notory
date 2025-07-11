import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const Avatar({super.key, required this.imageUrl, this.radius = 32});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : const AssetImage('assets/images/default_avatar.png')
              as ImageProvider,
      radius: radius,
      backgroundColor: Colors.grey[200],
      onBackgroundImageError: (_, __) {
        // 可以打印错误日志
      },
    );
  }
}
