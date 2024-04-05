import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    var btn = IconButton(
      onPressed: () async {
        var url = Uri.parse('https://api.next.bspapp.com/client');
        var headers = {
          'x-serverless-sign': '41b793a33ea47601bbf37f309720e483',
        };
        // 设置请求体
        // var data = {
        //   "method": "serverless.auth.user.anonymousAuthorize",
        //   "params": "{}",
        //   "spaceId": "mp-1a88af2d-74d0-4b55-9cc2-007b1fa75cad",
        //   "timestamp": '1712253493717'
        // };
        var data = {
          "method": "serverless.function.runtime.invoke",
          "params":
              "{\"functionTarget\":\"hedian\",\"functionArgs\":{\"\$url\":\"client/pages/pub/index_appdata\",\"data\":{\"appid\":\"wx737f8c91176795ee\"},\"clientInfo\":{\"PLATFORM\":\"mp-weixin\",\"\":\"\",\"APPID\":\"__UNI__F03A80D\",\"DEVICEID\":\"\",\"scene\":1089,\"albumAuthorized\":true,\"benchmarkLevel\":-1,\"bluetoothEnabled\":false,\"cameraAuthorized\":true,\"locationAuthorized\":true,\"locationEnabled\":true,\"microphoneAuthorized\":true,\"notificationAuthorized\":true,\"notificationSoundEnabled\":true,\"power\":100,\"safeArea\":{\"bottom\":736,\"height\":736,\"left\":0,\"right\":414,\"top\":0,\"width\":414},\"screenHeight\":736,\"screenWidth\":414,\"statusBarHeight\":0,\"theme\":\"light\",\"wifiEnabled\":true,\"windowHeight\":736,\"windowWidth\":414,\"enableDebug\":false,\"devicePixelRatio\":2,\"deviceId\":\"\",\"safeAreaInsets\":{\"top\":0,\"left\":0,\"right\":0,\"bottom\":0},\"appId\":\"__UNI__F03A80D\",\"appName\":\"青短剧\",\"appVersion\":\"1.0.0\",\"appVersionCode\":\"201\",\"appLanguage\":\"zh-Hans\",\"uniCompileVersion\":\"3.8.12\",\"uniRuntimeVersion\":\"3.8.12\",\"uniPlatform\":\"mp-weixin\",\"deviceBrand\":\"apple\",\"deviceModel\":\"MacBookPro18,1\",\"deviceType\":\"pc\",\"osName\":\"mac\",\"osVersion\":\"OS\",\"hostTheme\":\"light\",\"hostVersion\":\"3.8.5\",\"hostLanguage\":\"zh-CN\",\"hostName\":\"WeChat\",\"hostSDKVersion\":\"3.0.2\",\"hostFontSizeSetting\":15,\"windowTop\":0,\"windowBottom\":0,\"locale\":\"zh-Hans\",\"LOCALE\":\"zh-Hans\"},\"uniIdToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI2NjBlZDhjNzg2MjA2NjdiYjQyODY1NWUiLCJyb2xlIjpbXSwicGVybWlzc2lvbiI6W10sImlhdCI6MTcxMjI2MDY2MywiZXhwIjoxNzEyODU1NDYzfQ.3G6wqiDQwMVBoKjcPFd2K03Bng3eDOv71mnS6GxlJe8\"}}",
          "spaceId": "mp-1a88af2d-74d0-4b55-9cc2-007b1fa75cad",
          "timestamp": "1712250715430",
          "token": "1df7d5f7-284a-4f54-8ba6-f68f04b4069b"
        };
        // 发送请求
        var response =
            await http.post(url, headers: headers, body: jsonEncode(data));
        // 打印响应结果
        print(response.body);
      },
      icon: Icon(Icons.add),
    );

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: btn,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
