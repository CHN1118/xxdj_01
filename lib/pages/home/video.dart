// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_typing_uninitialized_variables, must_be_immutable, deprecated_member_use, unused_element, unused_local_variable, non_constant_identifier_names
// ignore_for_file: unnecessary_import, depend_on_referenced_packages, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:xxdj/apis/home.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final PageController _pageController = PageController(initialPage: 0);
  var videoData = [];
  var data;
  void _addData() {
    for (var i = 0; i < 200; i++) {
      videoData.add(i);
    }
  }

  // 处理视频播放结束事件
  void handleVideoPlay() {
    // 执行需要的操作
    print('视频播放结束');
    // 判断是否是最后一集
    if (_pageController.page == videoData.length - 1) {
      // 如果是最后一集，就返回上一页
      Get.back();
    } else {
      // 如果不是最后一集，就播放下一集
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  void initState() {
    super.initState();
    _addData();
    setState(() {
      data = Get.arguments;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          children: videoData.map<Widget>((item) {
            // 如果item是数字，就返回一个Container
            var index = videoData.indexOf(item);
            var length = videoData.length;
            if (item is int) {
              return const SizedBox();
            } else {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: VideoBody(
                    url: item,
                    index: index,
                    length: length,
                    onEnd: handleVideoPlay),
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
  Function? onEnd;

  VideoBody({
    Key? key,
    required this.url,
    required this.index,
    required this.length,
    this.onEnd,
  }) : super(key: key);

  @override
  State<VideoBody> createState() => _VideoBodyState();
}

class _VideoBodyState extends State<VideoBody> {
  late InAppWebViewController Controller;
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    videoUrl = widget.url["mp4_url"] ??
        widget.url["video_url"] ??
        widget.url["video_src"];
    // 监听视频播放事件
    // 倒计时1秒后监听
    Future.delayed(const Duration(seconds: 1), () {
      Controller.addJavaScriptHandler(
          handlerName: 'videoEnded',
          callback: (args) {
            if (widget.onEnd != null) {
              widget.onEnd!();
            }
          });
    });
  }

  @override
  dispose() {
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
          SizedBox(height: statusBarHeight),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(videoUrl)),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      supportZoom: false, // 禁止缩放
                      mediaPlaybackRequiresUserGesture: false, // 媒体播放需要用户手势
                    ),
                    ios: IOSInAppWebViewOptions(),
                  ),
                  initialSettings: InAppWebViewSettings(
                    allowsInlineMediaPlayback: true, // 允许内联媒体播放
                    mediaPlaybackRequiresUserGesture: false, // 媒体播放需要用户手势
                    underPageBackgroundColor: Colors.black,
                  ),
                  onContentSizeChanged: (controller, width, height) async {
                    setState(() {
                      Controller = controller;
                    });

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
                    video.style.height = '100%';
                    video.setAttribute('webkit-playsinline', 'true');
                    video.setAttribute('playsinline', 'true');
                    video.setAttribute('x5-video-player-type', 'true');
                    video.setAttribute('poster', 'true');
                    video.addEventListener('ended', function() {
                    window.flutter_inappwebview.callHandler('videoEnded');
                    });

                    //监听视频加载完成
                    video.addEventListener('loadeddata', function() {
                      // 视频加载完成后，隐藏加载动画
                      video.controls = false; 
                    });

                    // 视屏区域点击事件
                    video.addEventListener('click', function() {
                      if (video.controls) {
                        return;
                      }
                      // 播放状态
                      if (video.paused) {
                        video.play();
                        video.controls = false; // 显示控制条
                      } else {
                        video.pause();
                        video.controls = true; // 隐藏控制条
                      }
                    });

                    // 今天视频播放区域双击
                    video.addEventListener('dblclick', function() {
                     if (video.paused) {
                        video.play();
                      } else {
                        video.pause();
                      }
                    });

                    """);
                  },
                  onWebViewCreated: (controller) {
                    setState(() {
                      Controller = controller;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '第 ${widget.index + 1} 集',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 20,
                              width: 1,
                              color: Colors.white.withOpacity(1),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '更新至: ${widget.length} 集',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  //选择集数
                  GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            '选集',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
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
                  const SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
