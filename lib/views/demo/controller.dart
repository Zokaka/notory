import 'package:get/get.dart';
import 'package:notory/views/demo/state.dart';

/// GetxController 是 GetX 框架中用于管理页面逻辑的类（类似 Vue 的 setup() 或 React 的 useState + useEffect 组合）
/// DemoController 是写业务逻辑和处理状态变化的地方
/// state 是 DemoState 的实例，用来存放页面的状态
class DemoController extends GetxController {
  DemoController();

  final state = DemoState();

  void updateDemoText() {
    state.demo.value = "你点我啦";
  }
}
