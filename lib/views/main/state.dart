import 'package:get/get.dart';

class MainState {
  RxString str = "hello, this is main page".obs;

  //  当前索引
  RxInt tabIndex = 0.obs;
}
