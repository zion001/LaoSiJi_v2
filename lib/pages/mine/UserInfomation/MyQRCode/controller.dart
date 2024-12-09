import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'dart:ui' as ui;

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class MyqrcodeController extends GetxController {
  GlobalKey imageKey = GlobalKey();

  MyqrcodeController();

  _initData() {
    update(["myqrcode"]);
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

  void onQRCodeLongPressed() {
    Get.bottomSheet(
      <Widget>[
        // 从相册选择
        const TextWidget.title2("保存二维码").paddingAll(AppSpace.card).onTap(() {
          _saveQrcode();
          Get.back();
        }),
        Gap(AppSpace.page),
      ]
          .toColumn(
            mainAxisSize: MainAxisSize.min,
          )
          .backgroundColor(AppColors.background),
    );
  }

  // 保存二维码
  Future<void> _saveQrcode() async {
    RenderRepaintBoundary boundary =
        imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      if (result['isSuccess']) {
        Loading.success("保存成功");
      } else {
        Loading.error("保存失败");
      }
    }
  }

  /// 保存图片的权限校验
  checkPermission(Future<dynamic> fun) async {
    bool mark = await requestPermission();
    mark ? fun : null;
  }

  /// 动态申请权限
  Future<bool> requestPermission() async {
    late PermissionStatus status;
    // 读取系统权限弹窗
    if (Platform.isIOS) {
      status = await Permission.photosAddOnly.request();
    } else if (Platform.isAndroid) {
      status = await Permission.storage.request();
    }
    // 点击NOT ALLOW后，下次不会再出现系统弹框，需要自己加一个弹框
    if (status != PermissionStatus.granted) {
      Get.dialog(
        AlertDialog(
          title: Text('提示'),
          content: Text('需要您的手机打开相关权限'),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const TextWidget.title2("确定")),
          ],
        ),
      );
    } else {
      return true;
    }
    return false;
  }
}
