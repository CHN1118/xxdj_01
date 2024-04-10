// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

import 'home/index.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 1;
  final GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const color = Color.fromARGB(212, 255, 255, 255);
    return Scaffold(
        // 去掉底部导航栏的阴影
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed, // 适配多个按钮
                backgroundColor: Colors.black.withOpacity(0.96),
                key: _bottomNavigationKey,
                currentIndex: _page,
                elevation: 0,
                iconSize: 30,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/svgs/lsjl.svg',
                      width: _page == 0 ? 30 : 26,
                      height: _page == 0 ? 30 : 26,
                      color: _page == 0 ? color : Colors.white38,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/svgs/home.svg',
                      width: _page == 1 ? 30 : 26,
                      height: _page == 1 ? 30 : 26,
                      color: _page == 1 ? color : Colors.white38,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/svgs/mine.svg',
                      width: _page == 2 ? 30 : 26,
                      height: _page == 2 ? 30 : 26,
                      color: _page == 2 ? color : Colors.white38,
                    ),
                    label: '',
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    _page = index;
                    GetStorage().remove('history');
                  });
                },
              )),
        ),
        body: IndexedStack(
          index: _page,
          children: const <Widget>[
            Center(
              child: Text(
                '历史记录😯',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            HomePage(),
            Center(
              child: Text(
                '我的😯',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
  }
}

// onPressed: () {
// final BottomNavigationBar navigationBar =
// _bottomNavigationKey.currentWidget
// as BottomNavigationBar;
// navigationBar.onTap!(1);
// }