// views/home/binding.dart
import 'package:get/get.dart';
import 'package:notory/views/home/controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
