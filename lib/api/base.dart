/// 基础分页参数类
/// 所有需要分页的接口参数类都可以继承此类
class BasePageParams {
  final int page;
  final int pageSize;

  BasePageParams({
    this.page = 1,
    this.pageSize = 10,
  });

  /// 转换为Map，供queryParameters使用
  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'pageSize': pageSize,
    };
  }

  /// 复制并修改参数
  BasePageParams copyWith({
    int? page,
    int? pageSize,
  }) {
    return BasePageParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  String toString() {
    return 'BasePageParams{page: $page, pageSize: $pageSize}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasePageParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode => page.hashCode ^ pageSize.hashCode;
}

/// 基础搜索分页参数类
/// 包含搜索关键词的分页参数基类
class BaseSearchParams extends BasePageParams {
  final String? keyword;

  BaseSearchParams({
    int page = 1,
    int pageSize = 10,
    this.keyword,
  }) : super(page: page, pageSize: pageSize);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    if (keyword != null && keyword!.isNotEmpty) {
      map['keyword'] = keyword;
    }
    return map;
  }

  /// 复制并修改参数
  BaseSearchParams copyWith({
    int? page,
    int? pageSize,
    String? keyword,
  }) {
    return BaseSearchParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  String toString() {
    return 'BaseSearchParams{page: $page, pageSize: $pageSize, keyword: $keyword}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BaseSearchParams &&
          runtimeType == other.runtimeType &&
          keyword == other.keyword;

  @override
  int get hashCode => super.hashCode ^ keyword.hashCode;
}

/// 基础时间范围分页参数类
/// 包含时间范围筛选的分页参数基类
class BaseTimeRangeParams extends BasePageParams {
  final DateTime? startTime;
  final DateTime? endTime;

  BaseTimeRangeParams({
    int page = 1,
    int pageSize = 10,
    this.startTime,
    this.endTime,
  }) : super(page: page, pageSize: pageSize);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    if (startTime != null) {
      map['startTime'] = startTime!.toIso8601String();
    }
    if (endTime != null) {
      map['endTime'] = endTime!.toIso8601String();
    }
    return map;
  }

  /// 复制并修改参数
  BaseTimeRangeParams copyWith({
    int? page,
    int? pageSize,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return BaseTimeRangeParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'BaseTimeRangeParams{page: $page, pageSize: $pageSize, startTime: $startTime, endTime: $endTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BaseTimeRangeParams &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => super.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}
