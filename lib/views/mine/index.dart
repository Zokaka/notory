import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notory/components/avatar.dart';
import 'package:notory/components/item_container.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/views/mine/controller.dart';

import '../../components/mine_item.dart';

class MinePage extends GetView<MineController> {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // 状态栏白字
      child: Obx(
            () => Scaffold(
          extendBodyBehindAppBar: true, // 内容延伸进状态栏
          backgroundColor: const Color(0xFFF5F5F5),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 顶部 Banner 区域
              SizedBox(
                width: double.infinity,
                height: 270 + statusBarHeight,
                child: Stack(
                  children: [
                    // 背景图延伸至状态栏
                    SizedBox(
                      height: statusBarHeight + 200,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/background/bg01.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 顶部白色信息卡片
                    Positioned(
                      top: statusBarHeight + 150,
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
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            SizedBox(
                              width: 90,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: controller.toggleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  controller.state.signedIn.value == 1
                                      ? const Color(0xFF249CF2)
                                      : const Color(0xFFCFCFC),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
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
                                        color:
                                        controller.state.signedIn.value == 1
                                            ? Colors.white
                                            : const Color(0xFF707070),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ItemContainer(
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
              ItemContainer(
                child: Column(
                  children: [
                    MineItem(
                      title: '收藏',
                      iconPath: 'assets/icons/icon04.png',
                      onTap: () => logger.i('点击收藏'),
                    ),
                    MineItem(
                      title: '设置',
                      iconPath: 'assets/icons/icon05.png',
                      onTap: () => logger.i('点击设置'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ItemContainer(
                height: 50,
                child: Material(
                  color: Colors.transparent,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
