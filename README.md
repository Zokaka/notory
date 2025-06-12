# notory

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 创建各平台工程文件(ignore忽略的部分文件)，顺便会执行flutter pub get

flutter create --project-name notory --org com.zoka .

# 网络请求相关依赖

dio: ^5.8.0+1
dio_cookie_manager: ^3.2.0
cookie_jar: ^4.0.8

# 页面逻辑（以DemoPage为例）

          用户打开 DemoPage（跳转路由）
                    │
         ┌──────────┴──────────┐
         ↓                     ↓
    binding.dart           index.dart (DemoPage)
    注入 Controller         渲染页面结构
        │                      │
        ↓                      ↓
    controller.dart       Obx 监听 state.demo
    创建 Controller 实例         ↓
        │           demo 改变 → 自动刷新 UI
        ↓
    state.dart
    创建状态（包含 demo 变量）

# 页面执行顺序

    1.  binding.dart（依赖注入）
        当你路由跳转到 DemoPage 时，DemoBinding 会先被执行。
        通过 Get.lazyPut 把 DemoController 注册进 GetX 管理器，这样在页面里你可以直接使用 controller
    2.  controller.dart（逻辑控制器）
        绑定注入时（步骤一），DemoController 会被懒加载并实例化
        创建 state 实例，持有页面状态
        编写操作状态的方法，比如 updateDemoText()
    3.  state.dart（页面状态）
        DemoController 被实例化时，它会 new 一个 DemoState() 实例。
        存储所有的响应式变量（页面要展示和交互的内容）
        使用 .obs 包装变量，使其成为可监听的
    4.  index.dart（页面视图）
        当你跳转到该页面后，Flutter 会构建并渲染 DemoPage
        使用 Obx() 监听状态变化
        显示 demo 的值
        响应按钮点击事件，调用 controller 方法更新状态

# getX依赖简介

get: ^4.7.2
GetX 是 Flutter 的一个集成式解决方案，集状态管理、路由管理、依赖注入于一体，轻便、快速、简单
（就像vue的ref/reactive + vue-router + provide/inject）
/
| GetX 概念 | 用法示例 | 类比前端 |
|-------------------| --------------------------- | ---------------------------------- |
| `.obs`            | `var count = 0.obs`         | `ref(0)`                           |
| `Obx()`           | `Obx(() => Text("$count"))` | `<template>{{ count }}</template>` |
| `GetxController`  | `管理状态逻辑`                | `setup()` / `store module`         |
| `Get.put()`       | `立即注册一个 controller`     | `provide(controller)`              |
| `Get.lazyPut()`   | `懒加载 controller `         | `懒加载注入对象`                      |
| `GetView<T>`      | `视图层访问controller的简写`   | `inject + useXxx`                  |
| `Get.to(...)`     | `页面跳转 `                   | `router.push()`                    |
| `Bindings`        | `路由跳转时自动注入依赖`        |  `router.beforeEnter`              |

# getX页面跳转执行流程图

    ┌──────────────────────────────┐
    │        用户执行跳转指令         │
    │     Get.toNamed('/demo')     │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │   在 AppPages.routes 中查找    │
    │        匹配的 GetPage         │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │     如果该页面配置了 binding    │
    │执行 DemoBinding.dependencies()│
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │ Get.lazyPut<DemoController>(() =>  │
    │     DemoController());             │
    │  → 注入 DemoController 到内存中      │
    └────────────┬───────────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │       创建页面 Widget          │
    │       page: () => DemoPage() │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │ DemoPage 继承自 GetView        │
    │ 自动获取绑定的 DemoController   │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │    执行 DemoPage.build()      │
    │    页面开始构建渲染             │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌──────────────────────────────┐
    │  Obx(() => Text(...)) 被执行  │
    │ 监听 controller.state 中的值   │
    └────────────┬─────────────────┘
                 │
                 ▼
    ┌────────────────────────────────┐
    │ AppRouteObserver.didPush 被触发 │
    │ 记录跳转历史 → AppPages.history  │
    └────────────────────────────────┘




