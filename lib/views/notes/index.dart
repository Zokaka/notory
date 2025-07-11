// views/notes/index.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class NotesPage extends GetView<NotesController> {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
      body: Obx(() => RefreshIndicator(
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
                itemCount: state.list.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.list.length) {
                    if (!state.hasMore.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text("没有更多数据了")),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  }

                  final note = state.list[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(note['title'] ?? ''),
                      subtitle: Text(note['content'] ?? ''),
                    ),
                  );
                },
              ),
            ),
          )),
    );
  }
}
