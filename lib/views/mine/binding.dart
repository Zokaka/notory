import 'package:get/get.dart';
import 'package:notory/views/mine/controller.dart';

// 注入控制器（controller）到页面中
class MineBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MineController>(() => MineController());
  }
}
