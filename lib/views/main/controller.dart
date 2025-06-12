import 'package:get/get.dart';
import 'package:notory/views/main/state.dart';

class MainController extends GetxController {
  MainController();

  final state = MainState();

  void changeTab(int index) {
    state.tabIndex.value = index;
  }
}
