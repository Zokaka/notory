import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/components/avatar.dart';
import 'package:notory/views/mine/controller.dart';

class MinePage extends GetView<MineController> {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx(() => ...) 是 GetX 的响应式组件，只要里面用到的响应式变量变化，页面就会重新渲染
    return Obx(
      () => Scaffold(
        body: Column(
          children: [
            // Banner 区域
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blueAccent,
              child: Row(
                children: [
                  Avatar(imageUrl: controller.state.avatar.value),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.state.username.value,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        controller.state.role.value,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  )),
                  ElevatedButton(
                    onPressed: controller.toggleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.state.signedIn.value == 1
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    child: Text(
                        controller.state.signedIn.value == 1 ? '签到' : '已签到'),
                  )
                ],
              ),
            ),
            // item 列表
            Expanded(
              child: ListView(
                children: [
                  _buildItem(Icons.history, '历史记录'),
                  _buildItem(Icons.star, '我的收藏'),
                  _buildItem(Icons.settings, '设置'),
                ],
              ),
            ),
            // 退出按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(45),
                ),
                child: const Text("退出登录"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
