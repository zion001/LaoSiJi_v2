import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class SetGroupAvatarPage extends GetView<SetGroupAvatarController> {
  const SetGroupAvatarPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    //return [ImageWidget.url(url)]
    return [
      Gap(AppSpace.page),
      ImUtil.getAvatarWidget(controller.avatarUrl)
          .tightSize(100.w)
          .onTap(() {
            controller.onAvatarTapped();
          })
          .backgroundColor(AppColors.onInverseSurface)
          .clipRRect(all: 10)
          .center(),
/*
      (controller.avatarUrl == null)
          ? const ImageWidget.asset(
              AssetsImages.avatarDefaultPng,
              fit: BoxFit.fill,
            )
          : ImageWidget.url(
              controller.avatarUrl,
              fit: BoxFit.fill,
            )
              .tightSize(100.w)
              .onTap(() {
                controller.onAvatarTapped();
              })
              .backgroundColor(AppColors.onInverseSurface)
              .clipRRect(all: 10)
              .center(),
              */
      const Gap(40),
      ButtonWidget.textFilled(
        '确定',
        onTap: controller.onSubmitTapped,
      ).tight(height: 50).marginSymmetric(horizontal: AppSpace.page),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetGroupAvatarController>(
      init: SetGroupAvatarController(),
      id: "set_group_avatar",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '设置头像',
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
