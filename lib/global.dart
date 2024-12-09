import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/services/user_service.dart';
import 'common/index.dart';

class Global {
  // URL
  //static String SERVER_API_URL = 'http://159.138.150.152:8000/v1/';
  static String SERVER_API_URL = 'http://api.dev-lsj.com/v2/';
  static String SOCKET_HOST = 'ws://socket.dev-lsj.com';

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 工具类
    await Storage().init();
    Loading();
    // 初始化服务
    Get.put<ConfigService>(ConfigService());
    Get.put<HttpService>(HttpService());
    Get.put<UserService>(UserService());
  }
}
