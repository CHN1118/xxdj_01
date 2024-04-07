// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_typing_uninitialized_variables, must_be_immutable
// ignore_for_file: unnecessary_import, depend_on_referenced_packages, avoid_print

import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:xxdj/apis/home.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  var videoData = [];
  // ignore: unused_element
  void _addData() {
    for (var i = 0; i < 200; i++) {
      videoData.add(i);
    }
  }

  var data;

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
          videoData = jsonDecode(value.body)["data"];
        }
        // print(videoData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: PageController(initialPage: 1),
          scrollDirection: Axis.vertical,
          children: videoData.map<Widget>((item) {
            // 如果item是数字，就返回一个Container
            if (item is int) {
              return Image.network(
                data["vertical_cover"] ??
                        data["cover_url"] ??
                        data["tv_image"].endsWith('.jpg')
                    ? data["tv_image"]
                    : 'https://ts1.cn.mm.bing.net/th/id/R-C.c080d2ec112dcd89c3f45e243381c6e3?rik=tPyoq5Tzr3w1Zw&riu=http%3a%2f%2fwww.sucaijishi.com%2fuploadfile%2f2017%2f0510%2f20170510104939937.jpg%3fimageMogr2%2fformat%2fjpg%2fblur%2f1x0%2fquality%2f60&ehk=6SSZzYZrUHwwpIyAexpPAcYNKnzCViNeAl6U7CQgFYE%3d&risl=&pid=ImgRaw&r=0',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              );
            } else {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: VideoBody(
                    url: item["mp4_url"] ??
                        item["video_url"] ??
                        item["video_src"]),
              );
            }
          }).toList()),
    );
  }
}

class VideoBody extends StatefulWidget {
  String url;

  VideoBody({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<VideoBody> createState() => _VideoBodyState();
}

class _VideoBodyState extends State<VideoBody> {
  var videoPlayerController;
  var playerWidget;
  var chewieController;
  dynamic _chewie;
  @override
  void initState() {
    super.initState();
    _initVideo().then((value) {
      setState(() {
        _chewie = value;
        // print(value);
      });
    });
  }

  @override
  dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  Future<dynamic> _initVideo() async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await videoPlayerController.initialize();

    // 获取原始视频宽高
    // final Size videoSize = videoPlayerController.value.size;

    // videoPlayerController.value.size = Size(1080, 1920);

    // // 如果需要调整宽高比
    // final double customAspectRatio = 9 / 16;

    // print(videoSize);

    // 设置videoPlayerController 的size
    (videoPlayerController as VideoPlayerController).setVolume(1.0); // 设置音量
    

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false, // 循环播放
      allowFullScreen: true, // 允许全屏
      fullScreenByDefault: false, // 默认全屏
      showControls: true, // 显示控制器
      showControlsOnInitialize: true, // 初始化时显示控制器
      showOptions: true, // 显示选项
      autoInitialize: true, // 自动初始化
      systemOverlaysOnEnterFullScreen: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );

    playerWidget = Chewie(
      controller: chewieController,
    );

    return playerWidget;
  }

  @override
  Widget build(BuildContext context) {
    // 获取顶部状态栏高度
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      // mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: statusBarHeight,
        ),
        Expanded(
            child: _chewie ??
                Center(
                  child: CircularProgressIndicator(
                    color: const Color.fromARGB(255, 233, 173, 255)
                        .withOpacity(0.5),
                  ),
                )),
        Container(
          height: 60,
        ),
      ],
    );
  }
}
