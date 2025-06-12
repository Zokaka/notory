import 'package:flutter/material.dart';

/*
* StatelessWidget: 无状态组件,可以把它类比为 Vue 中没有响应式数据的组件
* 这个组件的 UI 是静态的，只根据构造函数传入的数据渲染，一旦创建之后，自己不会更新
* 如果希望组件能根据用户操作或异步数据变化而更新，需要使用 StatefulWidget
* */
class HomePage extends StatelessWidget {
  /*
  * 类的 构造函数，用来创建 HomePage 组件实例
  * const：表示这是一个 常量构造函数，如果传入的参数不变，这个组件可以被复用，减少内存分配，提升性能
  * {super.key}：把父类 StatelessWidget 的 key 属性，自动传给它
  * 在 Vue 或 React 中你可以写 <MyComponent key="123" /> 来给组件一个唯一标识，这里也是类似的概念
  * */
  const HomePage({super.key});

  /*
  * Widget 是 Flutter 中最基本的 UI 单元,一切皆 Widget
  * Flutter 的按钮、文本、布局、页面，全部都是 Widget
  * */
  Widget _buildListItem(String title, String subTitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subTitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        print('TODO something');
      },
    );
  }

  /*
  * 是 Dart 中的一个 注解，表示你正在重写父类的方法
  * */
  @override
  Widget build(BuildContext context) {
    /*
    * Scaffold 是一个非常常用的 布局组件，用于构建基础的应用页面结构。
    * 顶部的 AppBar/底部的 BottomNavigationBar/FloatingActionButton（悬浮按钮）/页面主体 body 等
    * */
    return Scaffold(
      // 整体背景渐变色，与搜索框背景一致
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF22C6C5), Color(0xFF39CBC1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 增加顶部 padding 和渐变背景下的搜索框
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入单词查询',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // 内容部分带圆角 + 背景白色
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '查询结果',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildListItem('单词', 'abandon'), // 修正错别字
                    ],
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
