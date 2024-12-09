import 'package:get/get.dart';

import '../../../common/index.dart';

class StyleIndexController extends GetxController {
  StyleIndexController();

  _initData() {
    update(["style_index"]);
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

  // 多语言
  void onLanguageSelected() {
    var en = Translation.supportedLocales[0];
    var zh = Translation.supportedLocales[1];

    ConfigService.to.onLocaleUpdate(
        ConfigService.to.locale.toLanguageTag() == en.toLanguageTag()
            ? zh
            : en);
    update(['styles_index']);
  }

  // 主题
  void onThemeSelected() async {
    await ConfigService.to.switchThemeModel();
    update(['styles_index']);
  }
}
