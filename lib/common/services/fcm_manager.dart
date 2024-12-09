

import 'package:im_flutter/common/api/fcm_api.dart';
import 'package:im_flutter/common/index.dart';

/// FCM管理
class FcmManager {

  // token
  static String token() {
    var token = Storage().getString(Constants.storageFcmToken);
    return token;
  }


  /// 绑定FCM TOKEN
  static void setFcm(String fcmToken) {
 //   token = fcmToken;
    Storage().setString(Constants.storageFcmToken, fcmToken);
    FcmApi.setFcm(fcmToken);
  }


      // 读TOKEN
    //token = Storage().getString(Constants.storageToken);

}