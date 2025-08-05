import 'package:get/get.dart';
import 'package:notory/views/noteDetail/controller.dart';

// 注入控制器（controller）到页面中
class NoteDetailBinding implements Bindings {
  @override
  void dependencies() {
    /// 在页面加载的时候，延迟注册一个 Controller（类似 Vue 中的 setup 函数、React 中的 useXxx 逻辑
    Get.lazyPut<NoteDetailController>(() => NoteDetailController());
  }
}
