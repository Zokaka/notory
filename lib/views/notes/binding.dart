import 'package:get/get.dart';
import 'package:notory/views/notes/controller.dart';

// 注入控制器（controller）到页面中
class NotesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesController>(() => NotesController());
  }
}
