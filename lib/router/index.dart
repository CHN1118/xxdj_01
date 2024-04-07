// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors

import 'package:get/get.dart';

import '../pages/home/video.dart';
import '../pages/index.dart';

class AppPages {
  static List<GetPage> pages = [
    GetPage(
      name: '/',
      page: () => const Home(),
    ),
    GetPage(
      name: '/video',
      page: () => VideoPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
