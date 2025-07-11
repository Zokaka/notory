import 'package:get/get.dart';

class NotesState {
  RxString demo = "111".obs;

  /// 分页参数
  RxInt pageNum = 1.obs;
  RxInt pageSize = 10.obs;

  /// 数据列表
  RxList<Map<String, String>> list = <Map<String, String>>[].obs;

  /// 是否正在加载更多
  RxBool isLoadingMore = false.obs;

  /// 是否还有更多数据
  RxBool hasMore = true.obs;
}
