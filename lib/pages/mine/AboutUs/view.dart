import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'index.dart';

class AboutusPage extends GetView<AboutusController> {
  const AboutusPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView(BuildContext context) {
    return [
      [
        [
          ImageWidget.asset(
            AssetsImages.logoPng,
            radius: AppRadius.image,
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
          )
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        Gap(AppSpace.card),
        TextWidget.body2('版本号：${ConfigService.to.version}'),
      ]
          .toColumn()
          .center()
          .marginSymmetric(vertical: AppSpace.page * 2)
          .backgroundColor(Colors.white),
      OptionListCell(
        title: '隐私政策',
        color: Colors.white,
      ).height(50).onTap(() {
        controller.onPrivacyTapped(context);
      }),
      OptionListCell(
        title: '服务协议',
        color: Colors.white,
      ).height(50).onTap(() {
        controller.onServiceTapped(context);
      }),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutusController>(
      init: AboutusController(),
      id: "aboutus",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '关于我们',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
