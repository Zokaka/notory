// stful
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/views/demo/controller.dart';

/// DemoPage extends GetView<DemoController> 说明这个页面和 DemoController 自动绑定好了
/// 就像 Vue 的 setup 函数用到了 inject 进来的东西
class DemoPage extends GetView<DemoController> {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx(() => ...) 是 GetX 的响应式组件，只要里面用到的响应式变量变化，页面就会重新渲染
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text("Bar"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // controller.state.demo 就是你绑定的响应式变量
            Text("Body ${controller.state.demo}"),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: controller.updateDemoText,
                child: const Text("点击修改")),
          ],
        ),
      ),
    );
  }
}
