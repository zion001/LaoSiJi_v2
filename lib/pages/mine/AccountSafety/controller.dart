import 'package:get/get.dart';
import 'package:im_flutter/common/routers/names.dart';

class AccountsafetyController extends GetxController {
  AccountsafetyController();

  _initData() {
    update(["accountsafety"]);
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

  void onChangePasswordTapped() {
    Get.toNamed(RouteNames.mineChangePassword);
  }
}
