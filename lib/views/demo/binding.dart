import 'package:get/get.dart';
import 'package:notory/views/demo/controller.dart';

// 注入控制器（controller）到页面中
class DemoBinding implements Bindings {
  @override
  void dependencies() {
    /// 在页面加载的时候，延迟注册一个 Controller（类似 Vue 中的 setup 函数、React 中的 useXxx 逻辑
    /// DemoBinding 的作用是在路由跳转时注入依赖，让页面可以访问对应的控制器
    Get.lazyPut<DemoController>(() => DemoController());
  }
}
