import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class MinePage extends GetView<MineController> {
  const MinePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return EasyRefresh(
      onRefresh: () async {},
      child: [
        buildHeader(),
        Gap(AppSpace.listRow),
        buildListItem('账号和安全', ""),
        const Gap(1),
        if(UserService.to.profile.isSystemUser())
          buildListItem('隐私设置', ""),
        Gap(AppSpace.listRow),
//        buildListItem('消息通知', ""),
//        Gap(AppSpace.listRow),
//        buildListItem('清理缓存', "0.0MB"),
//        const Gap(1),
        buildListItem('关于我们', ""),
        const Gap(1),
        buildListItem('检查版本', ConfigService.to.version, needArrow: false),
        Gap(AppSpace.listRow),
        buildLogout(),
      ].toColumn().marginSymmetric(horizontal: AppSpace.page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MineController>(
      init: MineController(),
      id: "mine",
      builder: (_) {
        return Scaffold(
//          appBar: AppBar(title: const Text("mine")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  // 头部
  Widget buildHeader() {
    var avatar = Obx(
      () => ImUtil.getAvatarWidget(UserService.to.profile.avatar)
          .tightSize(100.w)
          .onTap(() {
            controller.onTapAvatar();
          })
          .backgroundColor(AppColors.onInverseSurface)
          .clipRRect(all: 10),
    );

    var cotent = [
      Gap(AppSpace.page * 5),
      [avatar].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ButtonWidget.text(
        UserService.to.profile.nickname,
        textSize: 20.w,
        textColor: AppColors.primary,
      ),
      TextWidget.body2(
        '${LocaleKeys.username.tr}:${UserService.to.profile.username ?? ''}',
        textAlign: TextAlign.center,
      ),
      Gap(AppSpace.page * 2),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);

    return UserService.to.profile.isSystemUser()
        ? [
            cotent,
            ButtonWidget.icon(
              IconWidget.image(
                AssetsImages.scanPng,
                size: 25.w,
              ),
              onTap: controller.onQrScanTapped,
            )
                .tight(width: 35.w, height: 35.w)
                .positioned(right: AppSpace.page * 3, top: AppSpace.page),
            ButtonWidget.icon(
              Icon(
                Icons.qr_code_2_outlined,
                size: 25.w,
                color: Colors.black54,
              ),
              onTap: controller.onQrCodeTapped,
            )
                .tight(width: 35.w, height: 35.w)
                .positioned(right: 0, top: AppSpace.page),
          ].toStack()
        : [
            cotent,
            ButtonWidget.icon(
              IconWidget.image(
                AssetsImages.scanPng,
                size: 25.w,
              ),
              onTap: controller.onQrScanTapped,
            )
                .tight(width: 35.w, height: 35.w)
                .positioned(right: 0, top: AppSpace.page),
          ].toStack();
/*
    return [
      Gap(AppSpace.page * 2),
      avatar,
      ButtonWidget.text(
        UserService.to.profile.nickname,
        textSize: 20.w,
        textColor: AppColors.primary,
      ),
      TextWidget.body2(
          '${LocaleKeys.username.tr}:${UserService.to.profile.username ?? ''}'),
      Gap(AppSpace.page * 2),
    ].toColumn();
    */
  }

  // 列表项
  Widget buildListItem(String title, String detail, {bool needArrow = true}) {
    return [
      Gap(AppSpace.listItem),
      TextWidget.body1(title).expanded(),
      TextWidget.body2(
        detail,
        color: AppColors.secondary,
      ),
      needArrow
          ? IconWidget.icon(
              Icons.arrow_right_sharp,
              color: AppColors.shadow,
              size: 25,
            )
          : Container(
              width: 25,
            ),
      Gap(AppSpace.listItem),
    ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
      controller.onListItemTapped(title);
    });
  }

  // 退出按钮
  Widget buildLogout() {
    return [
      const TextWidget.body1(
        '退出登录',
        textAlign: TextAlign.center,
      ).expanded()
    ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
      controller.onLogoutTapped();
    });
  }
}
