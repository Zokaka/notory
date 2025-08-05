// views/home/controller.dart
import 'dart:convert';

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
  }

  /// 👇 修改：SSE 数据解析方法
  String _parseSSEData(String chunk) {
    try {
      // 🔍 调试：打印原始数据
      logger.i("🔍 原始SSE数据: '$chunk'");

      final lines = chunk.split('\n');
      String content = '';

      for (String line in lines) {
        line = line.trim();

        if (line.isEmpty || !line.startsWith('data: ')) {
          continue;
        }

        final jsonStr = line.substring(6);
        if (jsonStr == '[DONE]') {
          continue;
        }

        try {
          final jsonData = json.decode(jsonStr);

          if (jsonData is Map<String, dynamic> &&
              jsonData['choices'] is List &&
              jsonData['choices'].isNotEmpty) {
            final choice = jsonData['choices'][0];
            if (choice is Map<String, dynamic> &&
                choice['delta'] is Map<String, dynamic> &&
                choice['delta']['content'] is String) {
              final deltaContent = choice['delta']['content'] as String;
              content += deltaContent;

              // 🔍 调试：检查内容是否包含 Markdown 符号
              if (deltaContent.contains('*') || deltaContent.contains('#')) {
                logger.i("🔍 检测到Markdown符号: '$deltaContent'");
              }
            }
          }
        } catch (e) {
          logger.w("⚠️ JSON 解析失败: $e, 原始数据: $jsonStr");
        }
      }

      // 🔍 调试：打印最终解析的内容
      if (content.isNotEmpty) {
        logger.i("🔍 解析后的内容: '$content'");
      }

      return content;
    } catch (e) {
      logger.e("❌ SSE 数据解析错误: $e");
      return '';
    }
  }

  /// 👇 修改：获取单词含义的方法
  void getWordMeaning(String word) async {
    final word = searchController.text.trim();
    if (word.isEmpty) return;

    state.isOutputting.value = true;
    state.aiResponseText.value = '';
    cancelToken = CancelToken();

    logger.i("🚀 准备调用接口，查询单词: $word");

    await ChatApi.getDefinitionStream(
      word: word,
      cancelToken: cancelToken,
      onData: (chunk) {
        // 🔥 关键修改：解析 SSE 数据并提取内容
        final content = _parseSSEData(chunk);

        if (content.isNotEmpty) {
          // 只有解析出内容时才更新 UI
          state.aiResponseText.value += content;
          logger.i("📝 累积内容长度: ${state.aiResponseText.value.length}");
        }
      },
      onDone: () {
        state.isOutputting.value = false;
        logger.i("✅ 流式传输完成，最终内容长度: ${state.aiResponseText.value.length}");
      },
      onError: (err) {
        state.isOutputting.value = false;
        state.aiResponseText.value = "出错了: ${err.toString()}";
        logger.e("❌ 流式传输错误: $err");
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
