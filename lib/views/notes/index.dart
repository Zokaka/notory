// views/notes/index.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/api/blog/types.dart';
import 'package:notory/router/route.dart';
import 'package:notory/utils/formats.dart';
import 'package:notory/views/notes/controller.dart';

class NotesPage extends GetView<NotesController> {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Obx(() {
            if (state.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.getList,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.extentAfter < 100 &&
                      state.hasMore.value) {
                    controller.loadMoreNotes();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.list.length + (state.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.list.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final note = state.list[index];
                    final formattedTime = formatDate(note.createdAt);
                    return _buildNoteCard(note, formattedTime);
                  },
                ),
              ),
            );
          }),
        ));
  }

  Widget _buildNoteCard(BlogArticle note, String formattedTime) {
    return InkWell(
      onTap: () => _navigateToDetail(note),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              note.content ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 跳转到详情页
void _navigateToDetail(BlogArticle note) {
  // 获取笔记ID
  final noteId = note.id;

  if (noteId == null) {
    Get.snackbar(
      '错误',
      '笔记ID不存在',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
    );
    return;
  }

  // 或者使用路径参数的方式
  Get.toNamed('${AppRoutes.noteDetail}/$noteId');
}
