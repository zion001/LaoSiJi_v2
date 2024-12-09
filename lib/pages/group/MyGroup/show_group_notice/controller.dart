import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class ShowGroupNoticeController extends GetxController {
  late GroupProfile? groupProfile = Get.arguments['groupProfile'];
  TextEditingController noticeController = TextEditingController();

  ShowGroupNoticeController();

  _initData() {
    update(["show_group_notice"]);
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

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
