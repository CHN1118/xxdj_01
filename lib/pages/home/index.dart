// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xxdj/apis/home.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetStorage box = GetStorage(); // 实例化存储
  var data;
  var token;

  @override
  void initState() {
    setState(() {
      data = box.read('qh_data');
      token = box.read('token');
    });
    HomeApi.QHToken().then((value) {
      box.write('token', jsonDecode(value.body)["data"]["accessToken"]);
      setState(() {
        token = jsonDecode(value.body)["data"]["accessToken"];
      });
      HomeApi.QHData(token: jsonDecode(value.body)["data"]["accessToken"])
          .then((value) {
        setState(() {
          data = [
            ...jsonDecode(value.body)["data"]["videoList"],
            ...jsonDecode(value.body)["data"]["dataList"],
            ...jsonDecode(value.body)["data"]["videoList"]
          ];
        });
        box.write('qh_data', data);
      });
    });
    print(data);
    print(token);
    super.initState();
  }

  String loadImage(String imageUrl) {
    if (imageUrl != null &&
        (imageUrl.endsWith('.jpg') || imageUrl.endsWith('.png'))) {
      // 如果是图片 URL，直接返回 Image.network
      return imageUrl;
    } else {
      // 如果不是图片 URL，返回默认照片
      return 'https://ts1.cn.mm.bing.net/th/id/R-C.c080d2ec112dcd89c3f45e243381c6e3?rik=tPyoq5Tzr3w1Zw&riu=http%3a%2f%2fwww.sucaijishi.com%2fuploadfile%2f2017%2f0510%2f20170510104939937.jpg%3fimageMogr2%2fformat%2fjpg%2fblur%2f1x0%2fquality%2f60&ehk=6SSZzYZrUHwwpIyAexpPAcYNKnzCViNeAl6U7CQgFYE%3d&risl=&pid=ImgRaw&r=0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('剧场', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: StaggeredGridView.countBuilder(
          shrinkWrap: false,
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print(index);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: loadImage(
                              data[index]["tv_image"]), // 包含图片.jpg .png 等后缀
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        Text(data[index]["tv_name"],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    )),
              ),
            );
          },
          staggeredTileBuilder: (int index) =>
              const StaggeredTile.fit(1), // 固定宽高
        ),
      ),
    );
  }
}
