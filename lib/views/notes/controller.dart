import 'package:get/get.dart';
import 'package:notory/api/blog/index.dart';
import 'package:notory/utils/logger.dart';
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

  Future<void> getList() async {
    state.isLoading.value = true;
    state.pageNum.value = 1;

    try {
      final res = await BlogAPI.getBlogList(
        page: state.pageNum.value,
        pageSize: state.pageSize.value,
      );
      final list = res.list;
      final total = res.total;
      state.list.value = list;
      state.hasMore.value =
          (state.pageNum.value * state.pageSize.value) < total;
    } catch (e) {
      logger.e("加载失败: $e");
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> loadMoreNotes() async {
    if (state.isLoadingMore.value || !state.hasMore.value) return;

    state.isLoadingMore.value = true;
    state.pageNum.value++;

    try {
      final res = await BlogAPI.getBlogList(
        page: state.pageNum.value,
        pageSize: state.pageSize.value,
      );
      final list = res.list;
      final total = res.total;
      state.list.addAll(list);
      state.hasMore.value =
          (state.pageNum.value * state.pageSize.value) < total;
    } catch (e) {
      logger.e("加载失败: $e");
    } finally {
      state.isLoadingMore.value = false;
    }
  }
}
