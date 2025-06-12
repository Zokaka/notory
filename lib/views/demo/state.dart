import 'package:get/get.dart';

/// RxString demo = "111".obs 是一个响应式变量（可以自动监听变化并更新 UI）
/// .obs 是 GetX 提供的 响应式包装器，让普通变量变成“响应式”状态，像 Vue 的 ref 或 React 的 useState
class DemoState {
  RxString demo = "111".obs;
}
