// views/home/controller.dart
import 'package:get/get.dart';
import 'package:notory/views/home/state.dart';

class HomeController extends GetxController {
  HomeController();

  final state = HomeState();

  void onItemTap(String word) {
    // 你可以处理点击行为，比如跳转或弹窗等
    print('点击了单词：$word');
  }

  // 可以添加：增加历史记录等逻辑方法
  void addHistory(String word) {
    if (!state.searchHistory.contains(word)) {
      state.searchHistory.insert(0, word);
    }
  }
}
