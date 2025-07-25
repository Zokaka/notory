// views/home/index.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/home/controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  Widget _buildListItem(String title, String subTitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subTitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => controller.onItemTap(subTitle),
    );
  }

  // 构建搜索建议列表
  Widget _buildSuggestionsList() {
    return Obx(() {
      if (!controller.state.showSuggestions.value ||
          controller.state.suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: controller.state.suggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = controller.state.suggestions[index];
            return ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.search, size: 20, color: Colors.grey),
              title: Text(
                suggestion,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () => controller.onSuggestionSelected(suggestion),
            );
          },
        ),
      );
    });
  }

// 修复后的搜索框构建方法
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: '请输入单词查询',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              // 方法1：只在有文本时才显示 suffixIcon
              suffixIcon: Obx(() {
                if (controller.state.searchText.value.isNotEmpty) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: controller.clearSearch,
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, size: 20),
                        onPressed: controller.onSearch,
                      ),
                    ],
                  );
                }
                // 返回空的 SizedBox 而不是 null
                return const SizedBox.shrink();
              }),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF249CF2)),
              ),
            ),
            onSubmitted: (value) => controller.onSearch(),
          ),
          // 搜索建议列表
          _buildSuggestionsList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF249CF2), Color(0xFF39CBC1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 搜索框区域
              _buildSearchField(),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(() => ListView(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '查询记录',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              for (var item in controller.state.searchHistory)
                                _buildListItem(item.word, item.meaning),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
