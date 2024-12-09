import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/services/index.dart';

class ChangenicknameController extends GetxController {
  TextEditingController nicknameController = TextEditingController();

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  ChangenicknameController();

  _initData() {
    nicknameController.text = UserService.to.profile.nickname ?? "";
    update(["changenickname"]);
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

  Future<void> onSubmitBtnTapped() async {
    if (!(formKey.currentState as FormState).validate()) {
      return;
    }

    UserProfileModel? model =
        await UserApi.changeNickname(nickname: nicknameController.text);
    if (model != null) {
      Loading.success('更新成功');
      // 更新用户数据
      UserService.to.updateMyProfile(model);
      // 退出
      Get.back();
    }
  }
}
