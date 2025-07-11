import 'package:get/get.dart';
import 'package:notory/views/notes/state.dart';

class NotesController extends GetxController {
  NotesController();

  final state = NotesState();

  void updateDemoText() {
    state.demo.value = "你点我啦";
  }

  @override
  void onInit() {
    super.onInit();
    getList(); // 页面初始化加载数据
  }

  Future<List<Map<String, String>>> fetchList(int pageNum, int pageSize) async {
    await Future.delayed(const Duration(seconds: 1)); // 模拟延迟
    if (pageNum > 3) return []; // 模拟最多 3 页数据

    return List.generate(pageSize, (index) {
      final num = (pageNum - 1) * pageSize + index + 1;
      return {'title': '笔记标题 $num', 'content': '这是第 $num 条笔记的内容'};
    });
  }

  /// 初始化 / 下拉刷新
  Future<void> getList() async {
    state.pageNum.value = 1;
    final data = await fetchList(state.pageNum.value, state.pageSize.value);
    state.list.value = data;
    state.hasMore.value = state.pageSize == data.length;
  }

  /// 加载更多
  Future<void> loadMoreNotes() async {
    if (state.isLoadingMore.value || !state.hasMore.value) return;
    state.isLoadingMore.value = true;

    state.pageNum++;
    final data = await fetchList(state.pageNum.value, state.pageSize.value);
    if (data.isNotEmpty) {
      state.list.addAll(data);
    }

    state.hasMore.value = data.length == state.pageSize;
    state.isLoadingMore.value = false;
  }
}
