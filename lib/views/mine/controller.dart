import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/api/auth/index.dart';
import 'package:notory/router/route.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/storage.dart';
import 'package:notory/views/mine/state.dart';

class MineController extends GetxController {
  MineController();

  final state = MineState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initUserInfo();
  }

  void initUserInfo() async {
    // ① 优先读取缓存
    final jsonStr = await SPUtils.getString('UserInfo');
    bool hasCache = jsonStr != null && jsonStr.isNotEmpty;
    logger.i('是否存在缓存：$hasCache');
    if (hasCache) {
      final cacheData = jsonDecode(jsonStr);
      logger.i('缓存结果：$cacheData');
      _updateUserState(cacheData); // 渲染页面
    }

    // ② 调用接口刷新
    try {
      final res = await AuthAPI.getUserInfo();
      if (res['code'] == 0 && res['data'] != null) {
        final userInfo = res['data']['userInfo'];
        logger.i('调用结果：$userInfo');
        await SPUtils.setString('UserInfo', jsonEncode(userInfo));

        // 如果没有缓存时，接口返回成功后再渲染一次
        if (!hasCache) _updateUserState(userInfo);
      }
    } catch (e) {
      logger.e('获取用户信息失败：$e');
    }
  }

// 提取一个通用方法用于渲染
  void _updateUserState(Map<String, dynamic> data) {
    state.username.value = data['nickName'] ?? '暂无用户名称';
    state.avatar.value = data['headerImg'] ?? '';
    state.role.value = data['authority']['authorityName'] ?? '';
    state.signedIn.value = data['enable'] ?? 0;
  }

  ///  切换签到状态
  void toggleSignIn() async {
    state.signedIn.value = 0;
    final res = await AuthAPI.checkIn();
    logger.i("调用签到：$res");
  }

  /// 退出登录
  void logout() {
    Get.defaultDialog(
      title: '提示',
      middleText: '确定要退出登录吗？',
      textCancel: '取消',
      textConfirm: '确定',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await SPUtils.remove('AppAuthToken');
        await SPUtils.remove('UserInfo');
        Get.offAllNamed(AppRoutes.login); // 退出后跳转登录页
      },
    );
  }
}
