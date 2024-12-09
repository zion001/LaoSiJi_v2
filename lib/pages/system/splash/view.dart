import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageWidget.asset(AssetsImages.logoPng,
            width: 80, height: 80, fit: BoxFit.contain),
        TextWidget.title1(LocaleKeys.appName.tr,
                color: Color(0XFF007C7A), size: 32)
            .paddingTop(AppSpace.page),
        Container().tight(height: 200)
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      id: "splash",
      builder: (_) {
        return Scaffold(
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
