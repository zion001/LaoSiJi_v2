import 'package:get/get.dart';

class VersioncheckController extends GetxController {
  VersioncheckController();

  _initData() {
    update(["versioncheck"]);
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
