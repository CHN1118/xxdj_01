// ignore_for_file: depend_on_referenced_packages

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
      page: () => const VideoPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
