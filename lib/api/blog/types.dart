/// 博客文章模型
class BlogArticle {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String content;
  final String alias;
  final String summary;
  final int authorId;
  final bool allowComments;
  final bool isPinned;
  final bool visibility;
  final DateTime publishTime;
  final DateTime lastUpdateTime;
  final String coverImage;
  final String status;

  BlogArticle({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.content,
    required this.alias,
    required this.summary,
    required this.authorId,
    required this.allowComments,
    required this.isPinned,
    required this.visibility,
    required this.publishTime,
    required this.lastUpdateTime,
    required this.coverImage,
    required this.status,
  });

  factory BlogArticle.fromJson(Map<String, dynamic> json) {
    return BlogArticle(
      id: json['ID'] ?? 0,
      createdAt:
          DateTime.parse(json['CreatedAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['UpdatedAt'] ?? DateTime.now().toIso8601String()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      alias: json['alias'] ?? '',
      summary: json['summary'] ?? '',
      authorId: json['authorId'] ?? 0,
      allowComments: json['allowComments'] ?? false,
      isPinned: json['isPinned'] ?? false,
      visibility: json['visibility'] ?? false,
      publishTime: DateTime.parse(
          json['publishTime'] ?? DateTime.now().toIso8601String()),
      lastUpdateTime: DateTime.parse(
          json['lastUpdateTime'] ?? DateTime.now().toIso8601String()),
      coverImage: json['coverImage'] ?? '',
      status: json['status'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'title': title,
      'content': content,
      'alias': alias,
      'summary': summary,
      'authorId': authorId,
      'allowComments': allowComments,
      'isPinned': isPinned,
      'visibility': visibility,
      'publishTime': publishTime.toIso8601String(),
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'coverImage': coverImage,
      'status': status,
    };
  }

  @override
  String toString() => 'BlogArticle(id: $id, title: $title)';
}

// models/blog_list_response.dart
/// 博客文章列表响应模型
class BlogListResponse {
  final List<BlogArticle> list;
  final int total;
  final int page;
  final int pageSize;

  BlogListResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory BlogListResponse.fromJson(Map<String, dynamic> json) {
    return BlogListResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map(
                  (item) => BlogArticle.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }

  /// 是否有更多数据
  bool get hasMore => list.length < total;

  /// 是否为空列表
  bool get isEmpty => list.isEmpty;

  /// 当前页是否为第一页
  bool get isFirstPage => page == 1;

  @override
  String toString() =>
      'BlogListResponse(total: $total, page: $page, count: ${list.length})';
}

extension BlogArticleExtension on BlogArticle {
  String get formattedDate =>
      "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
}
