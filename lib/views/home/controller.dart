// views/home/controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:notory/views/home/state.dart';

class HomeController extends GetxController {
  HomeController();

  final state = HomeState();

  late TextEditingController searchController;

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
  void onSearch() {
    final text = searchController.text.trim();
    if (text.isEmpty) return;

    // 这里可以调用实际的搜索API
    // 暂时添加到搜索历史
    final newItem = SearchHistoryItem(word: text, meaning: '搜索结果: $text');

    // 避免重复添加
    state.searchHistory.removeWhere((item) => item.word == text);
    state.searchHistory.insert(0, newItem);

    // 清空输入框和建议
    searchController.clear();
    state.showSuggestions.value = false;
    state.suggestions.clear();

    print('搜索: $text');
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
