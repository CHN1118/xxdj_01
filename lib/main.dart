// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xxdj/controller/index.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'router/index.dart';

void main() async {
  await GetStorage.init();
  Get.put(Controller());
  // 锁定竖屏
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 禁止横屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 禁止全屏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '',
      debugShowCheckedModeBanner: false, // 隐藏右上角debug
      theme: ThemeData(
        brightness: Brightness.dark, // 亮色主题
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // 背景色
      ),
      initialRoute: '/',
      routingCallback: (routing) {}, //路由回调
      getPages: AppPages.pages, //路由
    );
  }
}


