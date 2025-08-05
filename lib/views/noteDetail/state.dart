import 'package:get/get.dart';

/// .obs 是 GetX 提供的 响应式包装器，让普通变量变成“响应式”状态，像 Vue 的 ref 或 React 的 useState
class NoteDetailState {
  // 加载状态
  var isLoading = false.obs;

  // 详情数据
  var noteDetail = <String, dynamic>{}.obs;

  // 错误信息
  var errorMessage = ''.obs;

  // 是否加载失败
  var hasError = false.obs;
}
