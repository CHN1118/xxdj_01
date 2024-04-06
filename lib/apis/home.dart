// 首页相关接口
// ignore_for_file: depend_on_referenced_packages, unused_local_variable, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeApi {
  static Future<http.Response> QHToken({String sing = ''}) async {
    var url = Uri.parse('https://api.next.bspapp.com/client');
    var headers = {
      'x-serverless-sign': sing,
    };
    // 设置请求体
    var data = {
      "method": "serverless.auth.user.anonymousAuthorize",
      "params": "{}",
      "spaceId": "mp-1a88af2d-74d0-4b55-9cc2-007b1fa75cad",
      "timestamp": '1712253493717'
    };
    var res = await http.post(url, headers: headers, body: jsonEncode(data));
    if (jsonDecode(res.body)["data"] == null) {
      return HomeApi.QHToken(
          sing: jsonDecode(res.body)["error"]["message"].split('is: ')[1]);
    } else {
      return res;
    }
  }

  static Future<http.Response> QHData(
      {String token = '', String sing = ''}) async {
    var url = Uri.parse('https://api.next.bspapp.com/client');
    var headers = {
      'x-serverless-sign': sing,
    };
    var data = {
      "method": "serverless.function.runtime.invoke",
      "params":
          "{\"functionTarget\":\"hedian\",\"functionArgs\":{\"\$url\":\"client/pages/pub/index_appdata\",\"data\":{\"appid\":\"wx737f8c91176795ee\"},\"clientInfo\":{\"PLATFORM\":\"mp-weixin\",\"\":\"\",\"APPID\":\"__UNI__F03A80D\",\"DEVICEID\":\"\",\"scene\":1089,\"albumAuthorized\":true,\"benchmarkLevel\":-1,\"bluetoothEnabled\":false,\"cameraAuthorized\":true,\"locationAuthorized\":true,\"locationEnabled\":true,\"microphoneAuthorized\":true,\"notificationAuthorized\":true,\"notificationSoundEnabled\":true,\"power\":100,\"safeArea\":{\"bottom\":736,\"height\":736,\"left\":0,\"right\":414,\"top\":0,\"width\":414},\"screenHeight\":736,\"screenWidth\":414,\"statusBarHeight\":0,\"theme\":\"light\",\"wifiEnabled\":true,\"windowHeight\":736,\"windowWidth\":414,\"enableDebug\":false,\"devicePixelRatio\":2,\"deviceId\":\"\",\"safeAreaInsets\":{\"top\":0,\"left\":0,\"right\":0,\"bottom\":0},\"appId\":\"__UNI__F03A80D\",\"appName\":\"青短剧\",\"appVersion\":\"1.0.0\",\"appVersionCode\":\"201\",\"appLanguage\":\"zh-Hans\",\"uniCompileVersion\":\"3.8.12\",\"uniRuntimeVersion\":\"3.8.12\",\"uniPlatform\":\"mp-weixin\",\"deviceBrand\":\"apple\",\"deviceModel\":\"MacBookPro18,1\",\"deviceType\":\"pc\",\"osName\":\"mac\",\"osVersion\":\"OS\",\"hostTheme\":\"light\",\"hostVersion\":\"3.8.5\",\"hostLanguage\":\"zh-CN\",\"hostName\":\"WeChat\",\"hostSDKVersion\":\"3.0.2\",\"hostFontSizeSetting\":15,\"windowTop\":0,\"windowBottom\":0,\"locale\":\"zh-Hans\",\"LOCALE\":\"zh-Hans\"},\"uniIdToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI2NjBlZDhjNzg2MjA2NjdiYjQyODY1NWUiLCJyb2xlIjpbXSwicGVybWlzc2lvbiI6W10sImlhdCI6MTcxMjI2MDY2MywiZXhwIjoxNzEyODU1NDYzfQ.3G6wqiDQwMVBoKjcPFd2K03Bng3eDOv71mnS6GxlJe8\"}}",
      "spaceId": "mp-1a88af2d-74d0-4b55-9cc2-007b1fa75cad",
      "timestamp": "1712250715430",
      "token": token
    };
    var res = await http.post(url, headers: headers, body: jsonEncode(data));
    if (jsonDecode(res.body)["data"] == null) {
      return HomeApi.QHData(
          token: token,
          sing: jsonDecode(res.body)["error"]["message"].split('is: ')[1]);
    } else {
      return res;
    }
    // 设置请求体
  }

  static Future<http.Response> FZData() async {
    var url = Uri.parse(
        'https://slb.weilianmenggz.cn/api/old/parent/class/index?page=1&page_size=5000');
    var headers = {
      'app-origin': 'wx09113ce8ec95d642',
    };
    var res = await http.get(url, headers: headers);
    return res;
  }

  static Future<http.Response> DJData() async {
    var url = Uri.parse(
        'https://newapi.mzhapi.com//index/video/search?page=1&limit=2000');
    var headers = {
      'appid': 'wx2636fa16ff27c34c',
      'channel-id': 'dciwpk',
    };
    var res = await http.get(url, headers: headers);
    return res;
  }
}
