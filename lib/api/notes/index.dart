import 'package:notory/utils/logger.dart';
import 'package:notory/utils/request.dart';

class NotesAPI {
  /// 获取博客文章列表
  /// [page] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  static Future<Map<String, dynamic>> getBlogList({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await Http.get<Map<String, dynamic>>(
      '/blogArticles/getBlogArticlesList',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    logger.i("博客文章列表获取结果：$response");

    // 根据你的返回结构，直接返回data字段
    return response['data'];
  }

  /// 获取博客文章详情
  /// [id] 文章ID
  static Future<Map<String, dynamic>> getBlogDetail(int id) async {
    logger.i("获取博客文章详情：id=$id");

    final response = await Http.get<Map<String, dynamic>>(
      '/blogArticles/findBlogArticles',
      queryParameters: {'ID': id},
    );

    return response['data'];
  }
}
