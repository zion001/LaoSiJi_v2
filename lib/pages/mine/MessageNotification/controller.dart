import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class MessagenotificationController extends GetxController {
  MessagenotificationController();

  _initData() {
    update(["messagenotification"]);
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

  /// 声音开关
  void onSoundSwitchValueChanged(bool isOn) {
    Loading.toast('声音开关:${isOn}');
  }

  /// 震动开关
  void onVibrateSwitchValueChanged(bool isOn) {
    Loading.toast('震动开关:${isOn}');
  }
}
