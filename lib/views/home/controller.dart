// views/home/controller.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/api/chat/index.dart';
import 'package:notory/utils/logger.dart';
import 'package:notory/views/home/state.dart';

class HomeController extends GetxController {
  HomeController();

  final state = HomeState();

  late TextEditingController searchController;
  late CancelToken cancelToken;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _suggestionOverlay;

  LayerLink get layerLink => _layerLink;

  void _showOverlaySuggestions(BuildContext context) {
    _removeOverlay();

    _suggestionOverlay = OverlayEntry(
      builder: (_) => Positioned(
        width: MediaQuery.of(context).size.width - 32, // 留边距
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 58), // TextField 高度 + 间距
          showWhenUnlinked: false,
          child: Obx(() {
            if (!state.showSuggestions.value || state.suggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: state.suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final suggestion = state.suggestions[index];
                  return ListTile(
                    dense: true,
                    title:
                        Text(suggestion, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSuggestionSelected(suggestion),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );

    Overlay.of(context).insert(_suggestionOverlay!);
  }

  void _removeOverlay() {
    _suggestionOverlay?.remove();
    _suggestionOverlay = null;
  }

  void onSearchTextChangedWithOverlay(BuildContext context) {
    final text = searchController.text.trim();
    state.searchText.value = text;

    if (text.isEmpty) {
      state.suggestions.clear();
      state.showSuggestions.value = false;
      _removeOverlay();
      return;
    }

    _searchSuggestions(text);
    _showOverlaySuggestions(context);
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();

    // 监听输入框文本变化
    searchController.addListener(_onSearchTextChanged);

    // 初始化一些示例数据
    _initializeSearchHistory();
  }

  @override
  void onClose() {
    _removeOverlay();
    searchController.dispose();
    super.onClose();
  }

  void _initializeSearchHistory() {
    state.searchHistory.addAll([
      SearchHistoryItem(word: 'abandon', meaning: '放弃'),
      SearchHistoryItem(word: 'apple', meaning: '苹果'),
    ]);
  }

  // 监听搜索框文本变化
  void _onSearchTextChanged() {
    final text = searchController.text.trim();
    state.searchText.value = text;

    if (text.isEmpty) {
      state.showSuggestions.value = false;
      state.suggestions.clear();
      return;
    }

    // 搜索匹配的词语
    _searchSuggestions(text);
  }

  // 搜索建议词语
  void _searchSuggestions(String query) {
    if (query.isEmpty) {
      state.suggestions.clear();
      state.showSuggestions.value = false;
      return;
    }

    // 从词库中查找匹配的词语
    final matches = state.wordDatabase
        .where((word) => word.toLowerCase().contains(query.toLowerCase()))
        .take(5) // 最多显示5个建议
        .toList();

    state.suggestions.value = matches;
    state.showSuggestions.value = matches.isNotEmpty;
  }

  // 选择建议词语
  void onSuggestionSelected(String suggestion) {
    searchController.text = suggestion;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    state.showSuggestions.value = false;
    state.suggestions.clear();
  }

  // 执行搜索
  void onSearch() async {
    final text = searchController.text.trim();
    if (text.isEmpty) return;
    getWordMeaning(text);
    // 这里可以调用实际的搜索API(暂时废弃)
    // 暂时添加到搜索历史
    // final newItem = SearchHistoryItem(word: text, meaning: '搜索结果: $text');
    //
    // // 避免重复添加
    // state.searchHistory.removeWhere((item) => item.word == text);
    // state.searchHistory.insert(0, newItem);
    //
    // // 清空输入框和建议
    // searchController.clear();
    // state.showSuggestions.value = false;
    // state.suggestions.clear();
    // try {
    //   final data = await AuthAPI.wordSearch(text);
    //   logger.i('查询单词结果：$data');
    // } catch (e) {
    //   print('查询单词结果：$e');
    //   toastInfo('查询失败！');
    // }
  }

  void getWordMeaning(String word) async {
    final word = searchController.text.trim();
    if (word.isEmpty) return;

    state.isOutputting.value = true;
    state.aiResponseText.value = '';
    cancelToken = CancelToken(); // ✅ 赋值给 controller 的成员变量
    logger.i("准备调用接口");
    await ChatApi.getDefinitionStream(
      word: word,
      cancelToken: cancelToken,
      onData: (chunk) {
        state.aiResponseText.value += chunk;
        logger.i("流式内容：$state.aiResponseText.value");
      },
      onDone: () {
        state.isOutputting.value = false;
      },
      onError: (err) {
        state.isOutputting.value = false;
        state.aiResponseText.value = "出错了: ${err.toString()}";
      },
    );
  }

  void cancelStream() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
  }

  void onItemTap(String word) {
    // 你可以处理点击行为，比如跳转或弹窗等
    print('点击了单词：$word');
  }

  // 可以添加：增加历史记录等逻辑方法
  void addHistory(String word) {
    // if (!state.searchHistory.contains(word)) {
    //   state.searchHistory.insert(0, word);
    // }
  }

  // 清空搜索框
  void clearSearch() {
    searchController.clear();
    state.showSuggestions.value = false;
    state.suggestions.clear();
  }
}
