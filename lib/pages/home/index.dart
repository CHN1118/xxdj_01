// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables, prefer_final_fields, avoid_print, no_leading_underscores_for_local_identifiers, must_be_immutable, non_constant_identifier_names, deprecated_member_use, unused_local_variable, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xxdj/apis/home.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetStorage box = GetStorage(); // 实例化存储
  var data = []; // 数据
  var token; // token
  ScrollController _scrollController = ScrollController(); // 滚动控制器
  RefreshController _refreshController =
      RefreshController(initialRefresh: false); // 下拉刷新控制器
  double _offset = 0; // 滚动距离
  int count = 10;

  @override
  void initState() {
    super.initState();
    getData(); // 获取数据
    _scrollController.addListener(() {
      setState(() {
        _offset = _scrollController.offset;
      });
    });
  }

  @override
  void deactivate() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.deactivate();
  }

  Future<void> getData({RefreshController? endFun}) async {
    await HomeApi.QHToken(); // 获取token
    setState(() {
      token = box.read('token');
    });
    // 获取青禾数据
    await HomeApi.QHData(token: token).then((value) {
      setState(() {
        data = [
          ...data,
          ...jsonDecode(value.body)["data"]["videoList"],
          ...jsonDecode(value.body)["data"]["dataList"],
          ...jsonDecode(value.body)["data"]["swiperList"],
        ];
      });
    });
    // 获取芳钟数据
    HomeApi.FZData().then((value) {
      setState(() {
        data = [...data, ...jsonDecode(value.body)["data"]];
      });
    });
    // 获取短剧数据
    HomeApi.DJData().then((value) {
      setState(() {
        data = [...data, ...jsonDecode(value.body)["data"]];
      });
    });
    endFun?.refreshCompleted();
  }

  var ShimHL = [
    280.0,
    300.0,
    250.0,
    290.0,
    300.0,
    270.0,
    270.0,
    270.0,
    270.0,
    270.0,
  ];

  String loadImage(dynamic item) {
    var imageUrl =
        item["tv_image"] ?? item["cover_url"] ?? item["vertical_cover"];
    if ((imageUrl.endsWith('.jpg') || imageUrl.endsWith('.png')) ||
        imageUrl.startsWith('https://qiniu.rongjuwh.cn')) {
      // 如果是图片 URL，直接返回 Image.network
      return imageUrl;
    } else {
      if (item["tv_name"] == '大圣归来') {
        return 'https://n.sinaimg.cn/transform/20150805/JTnn-fxfpqxf0207416.jpg';
      }
      // 如果不是图片 URL，返回默认照片
      return 'https://ts1.cn.mm.bing.net/th/id/R-C.c080d2ec112dcd89c3f45e243381c6e3?rik=tPyoq5Tzr3w1Zw&riu=http%3a%2f%2fwww.sucaijishi.com%2fuploadfile%2f2017%2f0510%2f20170510104939937.jpg%3fimageMogr2%2fformat%2fjpg%2fblur%2f1x0%2fquality%2f60&ehk=6SSZzYZrUHwwpIyAexpPAcYNKnzCViNeAl6U7CQgFYE%3d&risl=&pid=ImgRaw&r=0';
    }
  }

  void _onRefresh() {
    print('刷新');
    setState(() {
      data = [];
    });
    getData(endFun: _refreshController);
  }

  void _onLoading() {
    print('加载');
    setState(() {
      if ((count + 10) > data.length) {
        count = data.length;
      } else {
        count = count + 10;
      }
    });
    _refreshController.loadComplete();
  }

  String checkTitle(dynamic item) {
    return item["tv_name"] ?? item["title"];
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = AppBar().preferredSize.height; // appBar 高度
    double statusBarHeight = MediaQuery.of(context).padding.top; // 状态栏高度
    double bottomBarHeight = MediaQuery.of(context).padding.bottom; // 底部导航栏高度

    return Scaffold(
      backgroundColor: Color.fromARGB(42, 255, 255, 255),
      body: Stack(
        children: [
          SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            footer: const ClassicFooter(
              loadingText: '加载中...',
              idleText: '上拉加载',
              noDataText: '没有更多数据了',
              failedText: '加载失败',
              canLoadingText: '松开加载更多',
              loadStyle: LoadStyle.ShowWhenLoading,
              textStyle: TextStyle(color: Colors.white),
            ),
            header: const WaterDropHeader(
              complete: Text('刷新完成'),
              failed: Text('刷新失败'),
            ),
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
              itemCount: count,
              itemBuilder: (context, index) {
                if (data.isEmpty) {
                  return SizedBox(
                    width: 200.0,
                    height: ShimHL[index],
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(.5),
                      highlightColor: Colors.white.withOpacity(.4),
                      child: Container(
                          decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.5),
                        borderRadius: BorderRadius.circular(6),
                      )),
                    ),
                  );
                }
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
                      color: Colors.black.withOpacity(0.96),
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
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  // color: Colors.pink,
                                  height: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: SvgPicture.asset(
                                              'assets/svgs/search.svg',
                                              width: 17,
                                              height: 17,
                                              color:
                                                  Colors.white.withOpacity(.5)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            '搜索',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(.5),
                                                fontSize: 14),
                                          ),
                                        )
                                      ],
                                    ),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            right: _offset > 100 ? 10 : -100,
            bottom: 10 + bottomBarHeight,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black.withOpacity(0.85),
              elevation: 10,
              shape: const CircleBorder(),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: SvgPicture.asset(
                'assets/svgs/gotop.svg',
                width: 20,
                height: 20,
                color: Colors.white.withOpacity(.5),
              ),
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
    if (widget.item?['height'] == null) {
      Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (_containerKey.currentContext?.findRenderObject() != null &&
            widget.item?['height'] == null) {
          final RenderBox renderBox =
              _containerKey.currentContext?.findRenderObject() as RenderBox;
          final size = renderBox.size;
          if (size.height != 0 && widget.item?['height'] == null) {
            widget.item['height'] = size.height;
            timer.cancel();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      constraints: BoxConstraints(minHeight: widget.item['height'] ?? 300),
      decoration: BoxDecoration(
        color: const Color.fromARGB(52, 248, 248, 248),
        borderRadius: BorderRadius.circular(6),
        // 最小高度
      ),
      child: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              key: _containerKey,
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
                    child: Text('${widget.title}',
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
