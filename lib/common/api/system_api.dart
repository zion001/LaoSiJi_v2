import 'package:im_flutter/common/index.dart';

class SystemApi {
  /// 系统配置
  static Future<String?> getSystemConfig() async {
    Resource res = await HttpUtil.get('sys/getConfig');

    if (res.isSuccess()) {
      String str = res.data;
      return str;
    } else {
      return null;
    }
  }

  /// 获取协议配置
  static Future<dynamic> getSysAgreementConfig() async {
    Resource res = await HttpUtil.get('sys/getSysAgreementConfig');

    if (res.isSuccess()) {
      return res.data;
    } else {
      return null;
    }
  }
}
