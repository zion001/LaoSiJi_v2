import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class ChangepasswordController extends GetxController {
  /// 旧密码
  TextEditingController oldPasswordController = TextEditingController();

  /// 新密码
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordAgainController = TextEditingController();

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  final isOldShowObscureIcon = true.obs;
  final isNewShowObscureIcon = true.obs;

  ChangepasswordController();

  _initData() {
    update(["changepassword"]);
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

  /// 修改密码
  Future<void> onChangePasswordTapped() async {
    if (!(formKey.currentState as FormState).validate()) {
      return;
    }

    UserProfileModel? model =
        await UserApi.changePassword(oldPsd: oldPasswordController.text.toMd5, newPsd: newPasswordController.text.toMd5);
    if (model != null) {
      Loading.success('修改密码成功');
      //退出登录
      ImClient.getInstance().disconnect();

      UserService.to.clearLogin();
      Get.offAllNamed(RouteNames.systemSplash);
      Future.delayed(
        //要等待原systemMain释放完毕
        const Duration(milliseconds: 1000),
            () => Get.offAllNamed(RouteNames.systemMain),
      );
    }
  }
}
