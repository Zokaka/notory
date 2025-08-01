// views/home/state.dart
import 'package:get/get.dart';

class WordItem {
  final String word;
  final String meaning;

  WordItem({required this.word, required this.meaning});
}

class SearchHistoryItem {
  final String word;
  final String meaning;

  SearchHistoryItem({required this.word, required this.meaning});
}

class HomeState {
  //  搜索历史
  RxList searchHistory = [].obs;

  // 自动完成相关状态
  final RxString searchText = ''.obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxBool showSuggestions = false.obs;

  final RxBool isOutputting = false.obs;
  final RxString aiResponseText = ''.obs;

  // 示例词库 - 实际项目中可以从API获取
  final List<String> wordDatabase = [
    'apple',
    'application',
    'apply',
    'approach',
    'appropriate',
    'book',
    'booking',
    'books',
    'bookmark',
    'cat',
    'catch',
    'category',
    'catalog',
    'dog',
    'document',
    'download',
    'domain',
    'hello',
    'help',
    'health',
    'heart',
    'world',
    'work',
    'word',
    'worry',
    'test',
    'text',
    'technology',
    'teacher',
    'love',
    'lovely',
    'lover',
    'low',
    'high',
    'highlight',
    'history',
    'hit',
    'good',
    'google',
    'go',
    'goal',
  ];
}
