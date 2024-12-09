import 'dart:ui';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 配置服务
class ConfigService extends GetxService {
  static ConfigService get to => Get.find();

  PackageInfo? _platform;
  String get version => _platform?.version ?? '-';

  // 多语言
  Locale locale = PlatformDispatcher.instance.locale;

  // 主题
  final RxBool _isDarkModel = Get.isDarkMode.obs;
  bool get isDarkMode => _isDarkModel.value;

  @override
  void onReady() {
    super.onReady();
    getPlatform();
    initLocale();
    initTheme();
    
    /*
    OBSClient.init(ObsConfig.key, ObsConfig.secret,
        'https://${ObsConfig.bucket}.${ObsConfig.endPoint}', ObsConfig.bucket);
        */
/*
    OBSClient.init(ObsConfig.key, ObsConfig.secret,
      'https://${ObsConfig.bucket}.${ObsConfig.endPoint}', ObsConfig.bucket, ObsConfig.host);
  */
  }

  Future<void> getPlatform() async {
    _platform = await PackageInfo.fromPlatform();
  }

  // 切换theme
  Future<void> switchThemeModel() async {
    _isDarkModel.value = !_isDarkModel.value;
    Get.changeTheme(
      _isDarkModel.value == true ? AppTheme.dark : AppTheme.light,
    );
    await Storage().setString(
      Constants.storageThemeCode,
      _isDarkModel.value == true ? 'dark' : 'light',
    );
  }

  // 初始theme
  void initTheme() {
    var themeCode = Storage().getString(Constants.storageThemeCode);
    _isDarkModel.value = themeCode == 'dark' ? true : false;
    Get.changeTheme(
      themeCode == 'dark' ? AppTheme.dark : AppTheme.light,
    );
  }

  // 初始语言
  void initLocale() {
    var langCode = Storage().getString(Constants.storageLanguageCode);
    if (langCode.isEmpty) {
      return;
    }
    var index = Translation.supportedLocales.indexWhere((element) {
      return element.languageCode == langCode;
    });
    if (index < 0) return;
    locale = Translation.supportedLocales[index];
  }

  // 更改语言
  void onLocaleUpdate(Locale value) {
    locale = value;
    Get.updateLocale(value);
    Storage().setString(Constants.storageLanguageCode, value.languageCode);
  }
}
