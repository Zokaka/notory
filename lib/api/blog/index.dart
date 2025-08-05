import 'package:notory/api/blog/types.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/utils/request.dart';

class BlogAPI {
  /// 获取博客文章列表
  /// [page] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  static Future<BlogListResponse> getBlogList({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await HttpClient.get<Map<String, dynamic>>(
        '/blogArticles/getBlogArticlesList',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final blogListResponse = BlogListResponse.fromJson(response.data!);
        return blogListResponse;
      } else {
        throw RequestException(
          code: response.code,
          message: response.message,
        );
      }
    } on RequestException {
      rethrow;
    } catch (e) {
      logger.e("获取博客文章列表异常：$e");
      throw RequestException(
        code: -1,
        message: '获取博客文章列表失败',
        details: e.toString(),
      );
    }
  }

  /// 获取博客文章详情
  /// [id] 文章ID
  static Future<BlogArticle> getBlogDetail(int id) async {
    try {
      logger.i("获取博客文章详情：id=$id");

      final response = await HttpClient.get<Map<String, dynamic>>(
        '/blogArticles/findBlogArticles',
        queryParameters: {'ID': id},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final article = BlogArticle.fromJson(response.data!);
        logger.i("博客文章详情获取成功：${article.title}");
        return article;
      } else {
        throw RequestException(
          code: response.code,
          message: response.message,
        );
      }
    } on RequestException {
      rethrow;
    } catch (e) {
      logger.i("获取博客文章详情异常：$e");
      throw RequestException(
        code: -1,
        message: '获取博客文章详情失败',
        details: e.toString(),
      );
    }
  }
}
