import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/router/route.dart';
import 'package:notory/views/demo/binding.dart';
import 'package:notory/views/demo/index.dart';
import 'package:notory/views/login/binding.dart';
import 'package:notory/views/login/index.dart';
import 'package:notory/views/main/binding.dart';
import 'package:notory/views/main/index.dart';
import 'package:notory/views/noteDetail/binding.dart';
import 'package:notory/views/noteDetail/index.dart';

import 'observer.dart';

// 定义所有路由页面 & 对应的绑定逻辑，供全局使用
class AppPages {
  /// RouteObserver 是 Flutter 提供的路由监听机制
  /// 这里用 AppRouteObserver 实例监听所有页面跳转（比如跳转、返回等）
  /// 类似 Vue 中的 router.beforeEach / afterEach
  static final RouteObserver<Route> observer = AppRouteObserver();

  /// history 是页面访问记录数组，你可以用它来做“返回上一页”、“导航历史栈”等功能
  static List<String> history = [];

  /// GetPage 就是注册页面的方式
  /// name: 路由路径（字符串）；
  /// page: 页面组件
  /// binding: 可选，自动注入 Controller 和状态
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.demo,
      page: () => const DemoPage(),
      binding: DemoBinding(),
    ),
    GetPage(
      name: '${AppRoutes.noteDetail}/:id',
      page: () => const NoteDetailPage(),
      binding: NoteDetailBinding(),
    )
  ];
}
