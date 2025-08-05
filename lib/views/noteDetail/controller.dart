import 'package:get/get.dart';
import 'package:notory/api/blog/index.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/views/noteDetail/state.dart';

/// GetxController 是 GetX 框架中用于管理页面逻辑的类（类似 Vue 的 setup() 或 React 的 useState + useEffect 组合）
class NoteDetailController extends GetxController {
  NoteDetailController();

  final state = NoteDetailState();

  String? noteId;

  @override
  void onInit() {
    super.onInit();
    _getRouteParams();
    if (noteId != null) {
      getNoteDetail();
    }
  }

  /// 获取路由参数
  void _getRouteParams() {
    // 从路径参数获取ID
    noteId = Get.parameters['id'];
    logger.i('获取到笔记ID: $noteId');

    if (noteId == null || noteId!.isEmpty) {
      state.hasError.value = true;
      state.errorMessage.value = '笔记ID不存在';
    }
  }

  /// 获取笔记详情
  Future<void> getNoteDetail() async {
    if (noteId == null) return;

    try {
      state.isLoading.value = true;
      state.hasError.value = false;
      state.errorMessage.value = '';

      // 调用API获取详情 - 这里需要根据你的实际API调整
      final response = await BlogAPI.getBlogDetail(int.parse(noteId!));
      logger.i('文章详情$response');
      if (response != null) {
        state.noteDetail.value = response;
      } else {
        throw Exception('获取数据失败');
      }
    } catch (e) {
      logger.e('获取笔记详情失败: $e');
      state.hasError.value = true;
      state.errorMessage.value = '加载失败，请重试';
    } finally {
      state.isLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await getNoteDetail();
  }

  /// 获取格式化的创建时间
  // String get formattedCreateTime {
  //   final createdAt = state.noteDetail['CreatedAt'];
  //   if (createdAt == null) return '';
  //
  //   try {
  //     final dateTime = DateTime.parse(createdAt);
  //     return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  //   } catch (e) {
  //     return createdAt.toString();
  //   }
  // }

  /// 获取格式化的发布时间
  // String get formattedPublishTime {
  //   final publishTime = state.noteDetail['publishTime'];
  //   if (publishTime == null) return '';
  //
  //   try {
  //     final dateTime = DateTime.parse(publishTime);
  //     return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  //   } catch (e) {
  //     return publishTime.toString();
  //   }
  // }

  /// 返回上一页
  void goBack() {
    Get.back();
  }
}
