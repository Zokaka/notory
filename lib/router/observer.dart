import 'package:flutter/material.dart';
import 'package:notory/utils/logger.dart';

import 'index.dart';

//继承 RouteObserver，监听导航事件（比如 push、pop、replace）并更新 history
class AppRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  //  跳转页面,记录当前页面名到 AppPages.history
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    var name = route.settings.name ?? '';
    if (name.isNotEmpty) AppPages.history.add(name);
    logger.i('didPush');
    logger.i(AppPages.history);
  }

  //  返回页面, 从 history 里移除当前页面
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppPages.history.remove(route.settings.name);

    logger.i('页面的名字: ${previousRoute?.settings.name}');

    // 在这里调用 Controller 的方法更新数据
    // if (previousRoute?.settings.name == '/') {
    //   final controller = Get.find<ProfileController>();
    //   controller.fetchData(); // 更新数据
    // }

    logger.i('didPop');
    logger.i(AppPages.history);
  }

  // 替换页面,在 history 中更新老页面为新页面
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      var index = AppPages.history.indexWhere((element) {
        return element == oldRoute?.settings.name;
      });
      var name = newRoute.settings.name ?? '';
      if (name.isNotEmpty) {
        if (index > 0) {
          AppPages.history[index] = name;
        } else {
          AppPages.history.add(name);
        }
      }
    }
    logger.i('didReplace');
    logger.i(AppPages.history);
  }

  // 移除页面,页面从导航栈中被移除（不等于返回),从 history 中删除
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AppPages.history.remove(route.settings.name);
    logger.i('didRemove');
    logger.i(AppPages.history);
  }

  // 监听用户的手势开始
  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.i('didStartUserGesture');
    super.didStartUserGesture(route, previousRoute);
  }

  // 监听用户的手势结束
  @override
  void didStopUserGesture() {
    logger.i('didStopUserGesture');
    super.didStopUserGesture();
  }
}
