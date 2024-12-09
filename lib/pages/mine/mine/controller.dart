import 'dart:async';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:im_flutter/common/utils/huawei_obs/obs_client.dart';
import 'package:im_flutter/common/utils/huawei_obs/obs_config.dart';
import 'package:im_flutter/common/utils/huawei_obs/obs_response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MineController extends GetxController {
  MineController();
  StreamSubscription? subscription;

  _initData() {
    subscription =
        EventBusUtils.shared.on<RefreshProfileEvent>().listen((event) {
      update(["mine"]);
    });
    update(["mine"]);
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

  @override
  void onClose() {
    super.onClose();
    subscription?.cancel();
  }

  // 头像点击
  void onTapAvatar() {
    Get.toNamed(RouteNames.mineUserInfo);
  }

  /// 列表项点击
  void onListItemTapped(String itemName) {
    switch (itemName) {
      case "账号和安全":
        Get.toNamed(RouteNames.mineAccountSafety);
        break;
      case "隐私设置":
        Get.toNamed(RouteNames.minePrivacySetting);
        break;
      case "消息通知":
        Get.toNamed(RouteNames.mineMessageNotification);
        break;
      case "清理缓存":
        Loading.toast("开发中...");
        break;
      case "关于我们":
        Get.toNamed(RouteNames.mineAboutUs);
        break;
      case "当前版本":
        //     Get.toNamed(RouteNames.mineVersionCheck);
        break;
      default:
        return;
    }
  }

  /// 退出
  void onLogoutTapped() {
    ImDialog.confirmDialog('提示', '您确定退出吗?', () async {
    
      Loading.show();
      bool flag = await UserApi.logout( loginId: UserService.to.loginId, fcmToken: FcmManager.token() );
      Loading.dismiss();
      //if (flag)
      {
        ImClient.getInstance().disconnect();
        UserService.to.clearLogin();
        Get.offAllNamed(RouteNames.systemSplash);
        Future.delayed(
          //要等待原systemMain释放完毕
          const Duration(milliseconds: 1000),
          () => Get.offAllNamed(RouteNames.systemMain),
        );
      }
    });
    /*
    ImClient.getInstance().disconnect();
    UserService.to.clearLogin();
    Get.offAllNamed(RouteNames.systemSplash);
    Future.delayed(
      //要等待原systemMain释放完毕
      const Duration(milliseconds: 1000),
      () => Get.offAllNamed(RouteNames.systemMain),
    );
    */
  }

  /// 二维码
  void onQrCodeTapped() {
    Get.toNamed(RouteNames.mineQRCode);
  }

  /// 扫描二维码
  Future<void> onQrScanTapped() async {
    Get.toNamed(RouteNames.systemQrcodeScanner);
  }
}
