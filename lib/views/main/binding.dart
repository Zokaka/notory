import 'package:get/get.dart';
import 'package:notory/views/home/controller.dart';
import 'package:notory/views/main/controller.dart';
import 'package:notory/views/mine/controller.dart';
import 'package:notory/views/notes/controller.dart';

// 注入控制器（controller）到页面中
class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MineController>(() => MineController());
    Get.lazyPut<NotesController>(() => NotesController());
  }
}
