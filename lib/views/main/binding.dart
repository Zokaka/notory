import 'package:get/get.dart';
import 'package:notory/views/main/controller.dart';

// 注入控制器（controller）到页面中
class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
  }
}
