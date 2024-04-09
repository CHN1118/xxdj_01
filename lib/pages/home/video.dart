// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_typing_uninitialized_variables, must_be_immutable, deprecated_member_use, unused_element, unused_local_variable, non_constant_identifier_names, avoid_unnecessary_containers, prefer_final_fields, sized_box_for_whitespace
// ignore_for_file: unnecessary_import, depend_on_referenced_packages, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:xxdj/apis/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  PageController _pageController = PageController(initialPage: 0);
  var videoData = [];
  var data;
  void _addData() {
    for (var i = 0; i < 200; i++) {
      videoData.add(i);
    }
  }

  // 处理视频播放结束事件
  Future<void> handleVideoPlay() async {
    // 执行需要的操作
    print('视频播放结束');
    // 判断是否是最后一集
    if (_pageController.page == videoData.length - 1) {
      // 如果是最后一集，就返回上一页
      Get.back();
    } else {
      // 如果不是最后一集，就播放下一集
      await _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
      setHistory(); // 存储观看记录
    }
  }

  @override
  void initState() {
    super.initState();
    _addData(); // 添加数据
    setState(() {
      data = Get.arguments; // 获取传递过来的数据
    });
    getHistory();
    GetData(); // 获取数据
  }

  // 获取数据
  GetData() {
    HomeApi.GetVideo(data).then((value) {
      setState(() {
        if (data['tv_image'] != null) {
          videoData = jsonDecode(value.body)["data"]["series"];
        } else {
          if (jsonDecode(value.body)["data"][0]["theater_num"] != null) {
            videoData = jsonDecode(value.body)["data"];
            videoData
                .sort((a, b) => a["theater_num"].compareTo(b["theater_num"]));
          } else {
            videoData = jsonDecode(value.body)["data"];
          }
        }
      });
    });
    print('获取数据');
  }

  bool isXj = false;
  var controller;

  setXj(var c) {
    setState(() {
      isXj = true;
      controller = c;
    });
  }

  // 存储观看记录到本地
  void setHistory() {
    GetStorage storage = GetStorage();
    var history = storage.read('history') ?? [];
    var time = DateTime.now().millisecondsSinceEpoch;
    var item = {
      "id": '${data["id"] ?? data["tv_id"] ?? data["_id"]}',
      "data": data["tv_name"] ?? data["title"],
      "image": data["tv_image"] ?? data["vertical_cover"] ?? data["cover_url"],
      "time": time,
      "index": _pageController.page!.toInt() + 1,
    };
    // 如果观看记录中已经有这个视频，就删除
    (history).removeWhere((element) =>
        element["id"] == '${data["id"] ?? data["tv_id"] ?? data["_id"]}');
    (history).add(item);
    storage.write('history', (history));
    print('存储观看记录');
  }

  //获取观看记录
  void getHistory() {
    GetStorage storage = GetStorage();
    var history = storage.read('history') ?? [];
    var data = Get.arguments;
    var item = (history).firstWhere(
        (element) =>
            element["id"] == '${data["id"] ?? data["tv_id"] ?? data["_id"]}',
        orElse: () => null);
    if (item != null) {
      print(item);
      _pageController = PageController(initialPage: item?["index"] ?? 0);
    }
    print('获取观看记录');
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: _pageController,
          // 页面翻页后的回调
          onPageChanged: (index) {
            setHistory();
            print('翻页 ${index + 1} ');
          },
          scrollDirection: Axis.vertical,
          // 禁止滑动
          physics: isXj
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          children: videoData.map<Widget>((item) {
            // 如果item是数字，就返回一个Container
            var index = videoData.indexOf(item);
            var length = videoData.length;
            if (item is int) {
              return const SizedBox();
            } else {
              return Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideoBody(
                      url: item,
                      index: index,
                      length: length,
                      title: data["tv_name"] ?? data["title"] ?? '',
                      onEnd: handleVideoPlay,
                      reData: GetData,
                      xj: setXj,
                    ),
                  ),
                  if (isXj)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            isXj = false;
                            controller.evaluateJavascript(
                                source:
                                    "document.querySelector('video').play();");
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 5,
                            bottom: MediaQuery.of(context).size.height / 3.9,
                          ),
                          decoration: BoxDecoration(
                            color: isXj
                                ? Colors.black.withOpacity(.8)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '《 ${data["tv_name"] ?? data["title"]} 》',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5, // 横轴三个子widget
                                    childAspectRatio: 1.6, // 宽高比为1时，子widget
                                  ),
                                  itemCount: length,
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        _pageController.jumpToPage(i);
                                        setState(() {
                                          isXj = false;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          '第 ${i + 1} 集',
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          }).toList()),
    );
  }
}

class VideoBody extends StatefulWidget {
  var url;
  var index;
  var length;
  var title;
  Function? onEnd;
  Function? reData;
  Function? xj;

  VideoBody({
    Key? key,
    required this.url,
    required this.index,
    required this.length,
    this.onEnd,
    this.reData,
    this.title,
    this.xj,
  }) : super(key: key);

  @override
  State<VideoBody> createState() => _VideoBodyState();
}

class _VideoBodyState extends State<VideoBody> {
  late InAppWebViewController Controller;
  String videoUrl = '';
  bool js = false;
  List<bool> _visibleList = [true, false];
  Timer? _timer;
  bool titles = false;
  bool isShow = false;

  @override
  void initState() {
    super.initState();
    videoUrl = widget.url["mp4_url"] ??
        widget.url["video_url"] ??
        widget.url["video_src"];
    // 启动闪烁定时器
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _visibleList.insert(0, _visibleList.removeLast());
      });
    });
  }

  // 监听
  void addjavasddd() {
    Controller.addJavaScriptHandler(
        handlerName: 'videoEnded',
        callback: (args) {
          if (widget.onEnd != null) {
            widget.onEnd!();
          }
        });
    Controller.addJavaScriptHandler(
        handlerName: 'videoPlay',
        callback: (args) {
          setState(() {
            titles = false;
          });
        });
    Controller.addJavaScriptHandler(
        handlerName: 'videoPause',
        callback: (args) {
          setState(() {
            titles = true;
          });
        });
    Controller.addJavaScriptHandler(
        handlerName: 'isShow',
        callback: (args) {
          setState(() {
            isShow = true;
          });
        });
  }

  @override
  dispose() {
    print('组件销毁');
    Controller.evaluateJavascript(
        source: "document.querySelector('video').pause();");
    Controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取顶部状态栏高度
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: statusBarHeight - 20),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(videoUrl)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        supportZoom: false, // 禁止缩放
                        mediaPlaybackRequiresUserGesture: false, // 媒体播放需要用户手势
                      ),
                    ),
                    initialSettings: InAppWebViewSettings(
                      allowsInlineMediaPlayback: true, // 允许内联媒体播放
                      mediaPlaybackRequiresUserGesture: false, // 媒体播放需要用户手势
                      underPageBackgroundColor: Colors.black, // 页面背景色
                    ),
                    onReceivedHttpError:
                        (controller, request, errorResponse) async {
                      print(errorResponse);
                      widget.reData!();
                    },
                    onPageCommitVisible: (controller, url) async {
                      controller.evaluateJavascript(source: """
                    var html = document.querySelector('html')
                    var body = document.querySelector('body');
                    html.style.background = 'black';
                    body.style.background = 'black';
                    html.style.margin = '0';
                    body.style.margin = '0';
                    html.style.padding = '0';
                    body.style.padding = '0';
                    let video = document.querySelector('video');
                    // video.controls = false;
                    // video.autoplay = false;
                    video.classList.remove('iPhone');
                    video.classList.remove('audio');
                    video.classList.remove('media-document');
                    video.style.width = '100%';
                    // video.style.height = '100%';
                    //最小高度
                    html.style.height = '100vh';
                    body.style.height = '100vh';
                    video.setAttribute('webkit-playsinline', 'true');
                    video.setAttribute('playsinline', 'true');
                    video.setAttribute('x5-video-player-type', 'true');
                    // video.setAttribute('poster', 'true');
                    video.addEventListener('ended', function() {
                    window.flutter_inappwebview.callHandler('videoEnded');
                    });
                    //监听视频加载完成
                    video.addEventListener('loadeddata', function() {
                      // 视频加载完成后，隐藏加载动画
                      video.controls = false; 
                       window.flutter_inappwebview.callHandler('isShow');
                    });
                    // 视频父组件监听
                    video.parentNode.addEventListener('click', function(e) {
                      video.controls = true; // 隐藏控制条
                    });                    
                    // 视频播放区域双击
                    video.addEventListener('dblclick', function() {
                      // video.webkitRequestFullScreen();
                      // video.controls = true;
                    });
                    // 视频播放监听
                    video.addEventListener('play', function() {
                      window.flutter_inappwebview.callHandler('videoPlay');
                    });
                    // 视频暂停监听
                    video.addEventListener('pause', function() {
                      window.flutter_inappwebview.callHandler('videoPause');
                    });
                    """);
                    },
                    onWebViewCreated: (controller) async {
                      setState(() {
                        Controller = controller;
                      });
                      addjavasddd();
                    },
                  ),
                ),
                Positioned(
                  top: 20,
                  // 定位到中间
                  left: 70,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 140,
                    // color: Colors.black.withOpacity(0.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: (titles & !js)
                          ? 1.0
                          : js
                              ? 0.0
                              : 0.3,
                      child: Text(
                        '《 ${widget.title ?? ''} 》',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isShow)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black,
                      child: const Center(
                        child: CupertinoActivityIndicator(
                          radius: 20,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        js = true;
                      });
                      Controller.evaluateJavascript(
                          source:
                              "document.querySelector('video').playbackRate = 2;");
                      // 震动
                      HapticFeedback.lightImpact();
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        js = false;
                      });
                      Controller.evaluateJavascript(
                          source:
                              "document.querySelector('video').playbackRate = 1;");
                    },
                    child: Container(
                      // color: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 40,
                              child: js
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '2倍加速中',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        AnimatedOpacity(
                                          duration:
                                              const Duration(milliseconds: 800),
                                          opacity: _visibleList[0] ? 1.0 : 0.0,
                                          child: SvgPicture.asset(
                                            'assets/svgs/jia.svg',
                                            width: 18,
                                            height: 18,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          duration:
                                              const Duration(milliseconds: 800),
                                          opacity: _visibleList[1] ? 1.0 : 0.0,
                                          child: SvgPicture.asset(
                                            'assets/svgs/jia.svg',
                                            width: 18,
                                            height: 18,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    )
                                  : AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      opacity: js ? 0.0 : 1.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '第 ${widget.index + 1} 集',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 20,
                                              width: 1,
                                              color:
                                                  Colors.white.withOpacity(1),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '更新至 ${widget.length} 集',
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 100),
                                opacity: js ? 0.0 : 1.0,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '>>长按此处加速播放>>',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.13),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                //选择集数
                GestureDetector(
                  onTap: () {
                    widget.xj!(Controller);
                    Controller.evaluateJavascript(
                        source: "document.querySelector('video').pause();");
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: js ? 0.0 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            '选集',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          SvgPicture.asset(
                            'assets/svgs/xj.svg',
                            width: 30,
                            height: 30,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
