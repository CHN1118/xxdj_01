// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Scaffold(
        // 去掉底部导航栏的阴影
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Colors.white54.withOpacity(0.25), width: 0.5),
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed, // 适配多个按钮
                  backgroundColor: Colors.black.withOpacity(0.5),
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
                        width: 30,
                        height: 30,
                        color: _page == 0 ? Colors.white : Colors.white38,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svgs/home.svg',
                        width: 30,
                        height: 30,
                        color: _page == 1 ? Colors.white : Colors.white38,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/svgs/mine.svg',
                        width: 30,
                        height: 30,
                        color: _page == 2 ? Colors.white : Colors.white38,
                      ),
                      label: '',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      _page = index;
                    });
                  },
                )),
          ),
        ),
        body: IndexedStack(
          index: _page,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(_page.toString(), textScaleFactor: 10.0),
                    ElevatedButton(
                      child: Text('Go To Page of index 1'),
                      onPressed: () {
                        final BottomNavigationBar navigationBar =
                            _bottomNavigationKey.currentWidget
                                as BottomNavigationBar;
                        navigationBar.onTap!(1);
                      },
                    )
                  ],
                ),
              ),
            ),
            HomePage(),
            Center(
              child: Text('Compare'),
            ),
          ],
        ));
  }
}
