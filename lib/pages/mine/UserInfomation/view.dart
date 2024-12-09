import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class UserinfomationPage extends GetView<UserinfomationController> {
  const UserinfomationPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      Gap(AppSpace.page),
      Obx(() => ImUtil.getAvatarWidget(UserService.to.profile.avatar))
          /*(UserService.to.profile.avatar == null ||
                  UserService.to.profile.avatar!.isEmpty)
              ? const ImageWidget.asset(
                  AssetsImages.avatarDefaultPng,
                  fit: BoxFit.fill,
                )
              : ImageWidget.url(
                  UserService.to.profile.avatar ?? "",
                  fit: BoxFit.fill,
                ))
                */
          .tightSize(100.w)
          .onTap(() {
            controller.onAvatarTapped();
          })
          .backgroundColor(AppColors.onInverseSurface)
          .clipRRect(all: 10),
      Gap(AppSpace.card),
      const TextWidget.body2("更换头像"),
      Gap(AppSpace.card),
      Obx(
        () => OptionListCell(
          title: '昵称',
          content: UserService.to.profile.nickname ?? "",
        ).height(50).onTap(() {
          controller.onChangeNameTapped();
        }),
      ),
      if(UserService.to.profile.isSystemUser())
        OptionListCell(
          title: '二维码',
          suffix: const IconWidget(iconData: Icons.qr_code_2_outlined),
        ).height(50).onTap(() {
          controller.onQRCodeTapped();
        }),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserinfomationController>(
      init: UserinfomationController(),
      id: "userinfomation",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '用户信息',
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
