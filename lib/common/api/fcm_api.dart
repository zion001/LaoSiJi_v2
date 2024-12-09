import 'package:im_flutter/common/index.dart';

class FcmApi {
  /// 绑定FCM TOKEN
  static Future<bool> setFcm(String fcmToken) async {
    Resource res = await HttpUtil.post('users/setFcmToken', params: {'push_token' : fcmToken});
    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 解绑FCM TOKEN
  static Future<bool> cancelFcm() async {
    Resource res = await HttpUtil.get('users/setFcmToken', params: {'push_token' : ''});
    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

}