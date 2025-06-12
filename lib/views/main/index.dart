import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/home/index.dart';
import 'package:notory/views/main/controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  // tab 对应的页面内容(虽然可以理解，但是具体是干嘛的不知道？？)
  Widget _buildTabView(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const Center(child: Text('笔记'));
      case 2:
        return const Center(child: Text('我的'));
      default:
        return const Center(child: Text('未知页面'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obx(() => ...) 是 GetX 的响应式组件，只要里面用到的响应式变量变化，页面就会重新渲染
    return Obx(
      () => Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //   title: const Text("main page"),
        // ),
        body: _buildTabView(controller.state.tabIndex.value),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.state.tabIndex.value, //  int一定要加value么？？
          onTap: controller.changeTab,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
            BottomNavigationBarItem(icon: Icon(Icons.note), label: '笔记'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ),
    );
  }
}
