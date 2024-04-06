// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class Controller extends GetxController {
  bool isLogin = false;
  var language = '中文'.obs;
}
