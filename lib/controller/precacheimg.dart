// ignore_for_file: camel_case_types, prefer_const_constructors
//图片预加载
import 'package:flutter/material.dart';

class precacheImg {
  void getImg(context) {
    precacheImage(AssetImage('assets/images/signin_bgc.png'), context);
  }
}
