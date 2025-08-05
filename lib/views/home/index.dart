import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:notory/views/home/controller.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // 历史记录列表项
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subTitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
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

  // 搜索框
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

  // 查询记录模块
  Widget _buildSearchHistory() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '查询记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        for (var item in controller.state.searchHistory)
          _buildListItem(item.word, item.meaning),
        if (controller.state.searchHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.search, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无查询记录',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '输入单词开始查询吧！',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 🎨 优化的 Markdown 样式
  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      // 标题样式
      h1: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.4,
      ),
      h2: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.4,
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.3,
      ),

      // 正文样式
      p: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.black87,
      ),

      // 强调文本
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.black87,
      ),

      // 代码样式
      code: TextStyle(
        fontSize: 14,
        fontFamily: 'Courier',
        backgroundColor: Colors.grey[100],
        color: Colors.red[700],
        fontWeight: FontWeight.w500,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      codeblockPadding: const EdgeInsets.all(16),

      // 引用样式
      blockquote: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.grey[700],
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.blue[400]!,
            width: 4,
          ),
        ),
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // 列表样式
      listBullet: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.6,
      ),

      // 链接样式
      a: TextStyle(
        color: Colors.blue[600],
        decoration: TextDecoration.underline,
      ),

      // 表格样式
      tableHead: TextStyle(
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.grey[100],
      ),
      tableBody: const TextStyle(
        fontSize: 15,
      ),
      tableBorder: TableBorder.all(
        color: Colors.grey[300]!,
        width: 1,
      ),

      // 段落间距
      pPadding: const EdgeInsets.symmetric(vertical: 6),
      h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h2Padding: const EdgeInsets.only(top: 12, bottom: 6),
      h3Padding: const EdgeInsets.only(top: 8, bottom: 4),
    );
  }

  // 🚀 优化的 Markdown 内容渲染器
  Widget _buildMarkdownContent(BuildContext context) {
    return Obx(() {
      final content = controller.state.aiResponseText.value;
      final isOutputting = controller.state.isOutputting.value;

      if (isOutputting && content.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在查询中...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Markdown 渲染区域
          Expanded(
            child: Markdown(
              data: content.isEmpty ? '暂无内容' : content,
              styleSheet: _buildMarkdownStyleSheet(context),
              physics: const BouncingScrollPhysics(),
              selectable: true,

              // 链接点击支持
              onTapLink: (String text, String? href, String title) async {
                if (href != null) {
                  final uri = Uri.tryParse(href);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
              },
              // 🎯 自定义构建器 - 处理特殊元素
              builders: <String, MarkdownElementBuilder>{
                // 自定义代码块渲染
                'code': CodeElementBuilder(),
                // 可以添加更多自定义构建器
              },
              // 🔥 关键：使用标准的 GitHub 风格扩展
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                <md.InlineSyntax>[
                  md.EmojiSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                ],
              ),
            ),
          ),

          // 输出状态指示器
          if (isOutputting)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI 正在思考中...',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${content.length} 字符',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  // 查询结果模块
  Widget _buildSearchResult(BuildContext context) {
    return Column(
      children: [
        // 结果头部
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '查询结果：${controller.searchController.text}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 操作按钮
              Obx(() {
                if (controller.state.isOutputting.value) {
                  return IconButton(
                    onPressed: controller.cancelStream,
                    icon: const Icon(Icons.stop_circle, color: Colors.red),
                    tooltip: '停止输出',
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                              text: controller.state.aiResponseText.value),
                        );
                        Get.snackbar('复制成功', '内容已复制到剪贴板');
                      },
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      tooltip: '复制内容',
                    ),
                    IconButton(
                      onPressed: () {
                        controller.state.aiResponseText.value = '';
                      },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      tooltip: '关闭结果',
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1),

        // Markdown 内容区域
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildMarkdownContent(context),
          ),
        ),

        // 底部操作栏
        Obx(() {
          if (!controller.state.isOutputting.value &&
              controller.state.aiResponseText.value.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.onSearch();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('重新查询'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.addHistory(controller.searchController.text);
                        Get.snackbar('保存成功', '已添加到查询记录');
                      },
                      icon: const Icon(Icons.bookmark_add, size: 16),
                      label: const Text('保存记录'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF249CF2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
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
                    child: Obx(() {
                      final hasResult =
                          controller.state.aiResponseText.value.isNotEmpty ||
                              controller.state.isOutputting.value;

                      if (hasResult) {
                        return _buildSearchResult(context);
                      } else {
                        return ListView(
                          children: [
                            _buildSearchHistory(),
                          ],
                        );
                      }
                    }),
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

// 🎯 自定义代码块构建器
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SelectableText(
        textContent,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Color(0xFF2D3748),
          height: 1.4,
        ),
      ),
    );
  }
}
