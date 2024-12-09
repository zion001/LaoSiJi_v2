import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:im_flutter/common/index.dart';

class ImDialog {
  // 含确定取消对话框
  static void confirmDialog(
      String title, String content, VoidCallback onConfirmTapped) {
    Get.defaultDialog(
      title: title,
      middleText: content,
      cancel: ButtonWidget.textRoundFilled(
        '取消',
        textColor: AppColors.primary,
        bgColor: Colors.white,
        width: 55.w,
        height: 35.w,
        borderRadius: 5,
        borderColor: AppColors.primary,
        onTap: () => Get.back(),
      ).paddingRight(15.w),
      confirm: ButtonWidget.textFilled(
        '确定',
        bgColor: AppColors.primary,
        textColor: Colors.white,
        width: 55.w,
        height: 35.w,
        onTap: () {
          //Get.back();
          onConfirmTapped();
          Get.back();
        },
      ).paddingLeft(15.w),
    );
  }
}
