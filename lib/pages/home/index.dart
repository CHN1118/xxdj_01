// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables, prefer_final_fields, avoid_print, no_leading_underscores_for_local_identifiers, must_be_immutable

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xxdj/apis/home.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetStorage box = GetStorage(); // 实例化存储
  var data = [];
  var token;
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  double _offset = 0;

  @override
  @override
  void initState() {
    super.initState();
    setState(() {
      token = box.read('token');
    });
    getData();
    _scrollController.addListener(() {
      setState(() {
        _offset = _scrollController.offset;
      });
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _scrollController.dispose();
  }

  void getData({dynamic endFun}) {
    // 获取青禾数据
    HomeApi.QHToken().then((value) {
      // 存储token
      box.write('token', jsonDecode(value.body)["data"]["accessToken"]);
      setState(() {
        token = jsonDecode(value.body)["data"]["accessToken"];
      });
      HomeApi.QHData(token: jsonDecode(value.body)["data"]["accessToken"])
          .then((value) {
        setState(() {
          data = [
            ...data,
            ...jsonDecode(value.body)["data"]["videoList"],
            ...jsonDecode(value.body)["data"]["dataList"],
            ...jsonDecode(value.body)["data"]["swiperList"],
          ];
          duplicateRemoval();
          endFun?.refreshCompleted();
        });
        // 获取芳钟数据
        HomeApi.FZData().then((value) {
          setState(() {
            data = [...data, ...jsonDecode(value.body)["data"]];
          });
          duplicateRemoval();
          endFun?.refreshCompleted();
        });
        // 获取短剧数据
        HomeApi.DJData().then((value) {
          setState(() {
            data = [...data, ...jsonDecode(value.body)["data"]];
            duplicateRemoval();
          });
          endFun?.refreshCompleted();
        });
      });
    });
  }

  String loadImage(dynamic item) {
    var imageUrl =
        item["tv_image"] ?? item["cover_url"] ?? item["vertical_cover"];
    if ((imageUrl.endsWith('.jpg') || imageUrl.endsWith('.png')) ||
        imageUrl.startsWith('https://qiniu.rongjuwh.cn')) {
      // 如果是图片 URL，直接返回 Image.network
      return imageUrl;
    } else {
      // 如果不是图片 URL，返回默认照片
      return 'https://ts1.cn.mm.bing.net/th/id/R-C.c080d2ec112dcd89c3f45e243381c6e3?rik=tPyoq5Tzr3w1Zw&riu=http%3a%2f%2fwww.sucaijishi.com%2fuploadfile%2f2017%2f0510%2f20170510104939937.jpg%3fimageMogr2%2fformat%2fjpg%2fblur%2f1x0%2fquality%2f60&ehk=6SSZzYZrUHwwpIyAexpPAcYNKnzCViNeAl6U7CQgFYE%3d&risl=&pid=ImgRaw&r=0';
    }
  }

  void _onRefresh() async {
    getData(endFun: _refreshController);
    print(data.length);
  }

  void duplicateRemoval() {
    //根据id和title判断去掉重复数据 保留最新数据 使用遍历的方式
    for (var i = 0; i < data.length; i++) {
      for (var j = i + 1; j < data.length; j++) {
        if (data[i]["id"] == data[j]["id"] &&
            data[i]["title"] == data[j]["title"]) {
          data.removeAt(j);
        }
      }
    }
  }

  String checkTitle(dynamic item) {
    return item["tv_name"] ?? item["title"];
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    double appBarHeight = AppBar().preferredSize.height; // appBar 高度
    double statusBarHeight = MediaQuery.of(context).padding.top; // 状态栏高度
    double bottomBarHeight = MediaQuery.of(context).padding.bottom; // 底部导航栏高度

    return Scaffold(
      backgroundColor: Colors.white10,
      body: Stack(
        children: [
          SmartRefresher(
            enablePullDown: true, // 下拉刷新
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: MasonryGridView.count(
              padding: EdgeInsets.only(
                  top: appBarHeight + statusBarHeight + 5,
                  left: 5,
                  right: 5,
                  bottom: bottomBarHeight + 5),
              controller: _scrollController,
              shrinkWrap: false,
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              itemCount: data.length,
              itemBuilder: (context, index) {
                // 倒计时1秒
                return GestureDetector(
                  onTap: () {
                    Get.toNamed('/video', arguments: data[index]);
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CartItem(
                        title: checkTitle(data[index]),
                        imageUrl: loadImage(data[index]),
                        item: data[index],
                      )),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: SizedBox(
                height: appBarHeight + statusBarHeight,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.white54.withOpacity(0.25),
                            width: 0.5),
                      ),
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(
                            top: statusBarHeight, left: 20, right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  print('点击了搜索');
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 13),
                                        child: SvgPicture.asset(
                                          'assets/svgs/search.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          '搜索',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ),
          // 回到顶部按钮
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            right: _offset > 100 ? 10 : -100, // 根据滚动距离判断是否显示按钮
            bottom: 10 + bottomBarHeight,
            child: FloatingActionButton(
              backgroundColor: Colors.black.withOpacity(0.8),
              elevation: 10,
              shape: const CircleBorder(),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: const Icon(Icons.arrow_upward),
            ),
          )
        ],
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  var title;

  var imageUrl;
  dynamic item;

  CartItem({super.key, this.title, this.imageUrl, this.item});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 监听组件的大小
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 300), () {
        final RenderBox renderBox =
            _containerKey.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        widget.item['height'] = size.height;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      constraints: const BoxConstraints(minHeight: 260),
      height: widget.item['height'],
      decoration: BoxDecoration(
        color: const Color.fromARGB(52, 248, 248, 248),
        borderRadius: BorderRadius.circular(6),
        // 最小高度
      ),
      child: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl, // 包含图片.jpg .png 等后缀
              fit: BoxFit.cover,
              width: double.infinity,
              fadeOutDuration: const Duration(milliseconds: 50),
              fadeInDuration: const Duration(milliseconds: 50),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(widget.title,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
