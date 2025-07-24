import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/components/avatar.dart';
import 'package:notory/components/shadow_container.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/views/mine/controller.dart';

import '../../components/mine_item.dart';

class MinePage extends GetView<MineController> {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx(() => ...) 是 GetX 的响应式组件，只要里面用到的响应式变量变化，页面就会重新渲染
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF7F8FA), // ✅ 设置页面背景色
        body: ListView(
          children: [
            // Banner 区域
            SizedBox(
              width: double.infinity,
              height: 270, // 固定高度可以更好的显示图片
              child: Stack(
                children: [
                  // 背景图
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/background/bg01.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3))
                          ]),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ✅ 顶部对齐
                        children: [
                          Avatar(imageUrl: controller.state.avatar.value),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.state.username.value,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black87),
                                ),
                                Text(
                                  controller.state.role.value,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: controller.toggleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.state.signedIn.value == 1
                                      ? const Color(0xFF249CF2) // 签到背景色
                                      : Colors.grey, // 已签到背景色
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  controller.state.signedIn.value == 1
                                      ? 'assets/icons/icon01.png'
                                      : 'assets/icons/icon02.png',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  controller.state.signedIn.value == 1
                                      ? '签到'
                                      : '已签到',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.state.signedIn.value == 1
                                        ? Colors.white // ✅ 签到字体颜色
                                        : const Color(0xFF707070), // ✅ 已签到字体颜色
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            ShadowContainer(
              height: 50,
              child: Column(
                children: [
                  MineItem(
                    title: '钱包',
                    iconPath: 'assets/icons/icon03.png',
                    onTap: () => logger.i('点击钱包'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ShadowContainer(
              child: Column(
                children: [
                  // 收藏项
                  MineItem(
                    title: '收藏',
                    iconPath: 'assets/icons/icon04.png',
                    onTap: () => logger.i('点击收藏'),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFF999999),
                  ),
                  // 设置项
                  MineItem(
                    title: '设置',
                    iconPath: 'assets/icons/icon05.png',
                    onTap: () => logger.i('点击设置'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ShadowContainer(
              height: 50,
              child: Material(
                color: Colors.transparent, // 保持背景透明
                child: InkWell(
                  onTap: controller.logout,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/icon06.png',
                            width: 24, height: 24),
                        const SizedBox(width: 10),
                        const Text('退出', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
