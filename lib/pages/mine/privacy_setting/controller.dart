import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class PrivacySettingController extends GetxController {
  MyConfigProfile? profile;

  PrivacySettingController();

  _initData() async {
    profile = await UserApi.getMyConfigProfile();

    update(["privacy_setting"]);
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

  /// 添加好友是否需要验证
  Future<void> onChangeAddSetting(bool value) async {
    Loading.show();
    profile =
        await UserApi.setMyConfigProfile({"add_friend_confirm": value ? 1 : 0});
    if (profile != null) {
      update(["privacy_setting"]);
    }
  }
}
