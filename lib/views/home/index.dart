// views/home/index.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/home/controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // 历史记录
  Widget _buildListItem(String title, String subTitle) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => controller.onItemTap(subTitle),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ space-between
            crossAxisAlignment: CrossAxisAlignment.center,     // ✅ align-items: center
            children: [
              // 左侧：title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // ✅ 垂直居中
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subTitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 修复后的搜索框构建方法
  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CompositedTransformTarget(
        link: controller.layerLink,
        child: TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: '请输入单词查询',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
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
          onChanged: (_) => controller.onSearchTextChangedWithOverlay(context),
          onSubmitted: (_) => controller.onSearch(),
        ),
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
              _buildSearchField(context),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Obx(() => ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
