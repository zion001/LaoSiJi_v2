import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/components/index.dart';
import 'package:im_flutter/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'index.dart';

class MyqrcodePage extends GetView<MyqrcodeController> {
  const MyqrcodePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      Gap(AppSpace.page * 2),
      [ImUtil.getAvatarWidget(UserService.to.profile.avatar).tightSize(80.w)]
          .toRow(mainAxisAlignment: MainAxisAlignment.center),
      /*ImageWidget.url(UserService.to.profile.avatar ?? "")
          .tight(width: 80.w, height: 80.w),
          */
      Gap(AppSpace.card),
      TextWidget.title3(
        UserService.to.profile.nickname ?? "",
        textAlign: TextAlign.center,
      ),
      Gap(AppRadius.card * 3),
      RepaintBoundary(
        key: controller.imageKey,
        child: QrImageView(data: '${UserService.to.profile.username}')
            .tight(width: 250.w, height: 250.w)
            .center()
            .onLongPress(() {
          controller.onQRCodeLongPressed();
        }),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyqrcodeController>(
      init: MyqrcodeController(),
      id: "myqrcode",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '二维码',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
