import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notory/router/index.dart';
import 'package:notory/router/route.dart';
import 'package:notory/utils/storage.dart';

void main() async {
  // 启动前绑定
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化本地存储
  await SPUtils.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return GetMaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            // 路由配置
            initialRoute: snapshot.data as String,
            getPages: AppPages.routes,
            navigatorObservers: [AppPages.observer],
          );
        });
  }

  /// 判断登录状态，返回初始页面路径
  Future<String> _getInitialRoute() async {
    final token = SPUtils.getString('AppAuthToken');
    return (token == null || token.isEmpty) ? AppRoutes.login : AppRoutes.main;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Text('跳转'),
              onTap: () => Get.toNamed(AppRoutes.demo),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
