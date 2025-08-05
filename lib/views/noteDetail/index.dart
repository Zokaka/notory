// views/note_detail/index.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class NoteDetailPage extends GetView<NoteDetailController> {
  const NoteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.state.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.state.hasError.value) {
          return _buildErrorView();
        }

        if (controller.state.noteDetail.isEmpty) {
          return const Center(child: Text('暂无数据'));
        }

        return _buildDetailView();
      }),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            controller.state.errorMessage.value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  /// 构建详情视图
  Widget _buildDetailView() {
    final note = controller.state.noteDetail;

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareNote,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreOptions,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: _buildCoverImage(note),
            ),
          ),
        ),

        // 内容区域
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(note),
                _buildDivider(),
                _buildAuthorInfo(note),
                _buildDivider(),
                _buildContent(note),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage(Map<String, dynamic> note) {
    final coverImage = note['coverImage'];

    if (coverImage != null && coverImage.isNotEmpty) {
      return Image.network(
        coverImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultCover();
        },
      );
    }

    return _buildDefaultCover();
  }

  /// 构建默认封面
  Widget _buildDefaultCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article,
          size: 64,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  /// 构建头部信息
  Widget _buildHeader(Map<String, dynamic> note) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            note['title'] ?? '无标题',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 时间和ID信息
          _buildMetaInfo(note),

          // 标签
          if (note['isPinned'] == true) ...[
            const SizedBox(height: 12),
            _buildTags(note),
          ],
        ],
      ),
    );
  }

  /// 构建元信息
  Widget _buildMetaInfo(Map<String, dynamic> note) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          controller.formattedPublishTime,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.tag,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          'ID: ${note['ID']}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建标签
  Widget _buildTags(Map<String, dynamic> note) {
    return Wrap(
      spacing: 8,
      children: [
        if (note['isPinned'] == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.push_pin,
                  size: 14,
                  color: Colors.orange[800],
                ),
                const SizedBox(width: 4),
                Text(
                  '置顶',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (note['status'] == '1')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '已发布',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建作者信息
  Widget _buildAuthorInfo(Map<String, dynamic> note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue[100],
            child: Text(
              _getAuthorInitial(note['authorId']),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 作者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '作者 ${note['authorId'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '发布于 ${controller.formattedPublishTime}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 关注按钮
          OutlinedButton(
            onPressed: _followAuthor,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              '关注',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建正文内容
  Widget _buildContent(Map<String, dynamic> note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '正文',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              note['content'] ?? '暂无内容',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }

  /// 获取作者头像首字母
  String _getAuthorInitial(dynamic authorId) {
    if (authorId == null) return 'A';
    final id = authorId.toString();
    if (id.isEmpty) return 'A';
    return id[0].toUpperCase();
  }

  /// 分享笔记
  void _shareNote() {
    Get.snackbar(
      '分享',
      '分享功能待开发',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }

  /// 显示更多选项
  void _showMoreOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Get.back();
                _editNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('收藏'),
              onTap: () {
                Get.back();
                _bookmarkNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Get.back();
                _reportNote();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 关注作者
  void _followAuthor() {
    Get.snackbar(
      '关注',
      '关注功能待开发',
      snackPosition: SnackPosition.TOP,
    );
  }

  /// 编辑笔记
  void _editNote() {
    Get.snackbar('编辑', '编辑功能待开发');
  }

  /// 收藏笔记
  void _bookmarkNote() {
    Get.snackbar('收藏', '收藏成功');
  }

  /// 举报笔记
  void _reportNote() {
    Get.snackbar('举报', '举报功能待开发');
  }
}
