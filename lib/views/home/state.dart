// views/home/state.dart
import 'package:get/get.dart';

class HomeState {
  /// 查询历史列表
  RxList<String> searchHistory = ['abandon'].obs;
}
