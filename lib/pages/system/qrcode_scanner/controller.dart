import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrcodeScannerController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrScannercontroller;

  /// 保存搜索结果
  UserInfoBasic? searchedUserInfo;

  QrcodeScannerController();

  _initData() {
    update(["qrcode_scanner"]);
    qrScannercontroller?.resumeCamera();
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
    qrScannercontroller?.dispose();
  }

  void onQRViewCreated(QRViewController controller) {
    qrScannercontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        searchFriend(scanData.code!);
      }
    });
  }

  /// 搜索好友
  void searchFriend(String username) async {
    searchedUserInfo = await FriendApi.searchFriend(username);
    if (searchedUserInfo == null) {
      Loading.error('未找到用户');
      return;
    } else {
      Get.toNamed(
        RouteNames.contactsContactsUserDetail,
        arguments: {
          'userInfo': searchedUserInfo,
          'source': 2, //好友来源 1搜索添加 2二维码 3群聊
          'username': username,
        },
      );
    }
  }
}
