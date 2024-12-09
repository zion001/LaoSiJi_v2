import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class AboutusController extends GetxController {
  AboutusController();

  _initData() {
    update(["aboutus"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  /// 隐私政策
  void onPrivacyTapped(BuildContext context) async{
    Loading.show();
    Map? sysAgreementConfig = await SystemApi.getSysAgreementConfig();
    Loading.dismiss();
    if(sysAgreementConfig is Map)
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ImWebview(
            htmlContent:sysAgreementConfig!['privacy_policy']!,
            title: '隐私政策',
          ),
        ),
      );
  }

  /// 服务协议
  void onServiceTapped(BuildContext context) async{
    Loading.show();
    Map? sysAgreementConfig = await SystemApi.getSysAgreementConfig();
    Loading.dismiss();
    if(sysAgreementConfig is Map)
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ImWebview(
            htmlContent:sysAgreementConfig!['user_service_agreement']!,
            title: '服务协议',
          ),
        ),
      );
  }
}
