import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';

class GroupManagePage extends GetView<GroupManageController> {
  const GroupManagePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    bool isOwner = controller.groupProfile?.isOwner() ?? false;

    List<Widget> children = isOwner
        ? [
            [
              const TextWidget.body1('群头像').expanded(),
              ImUtil.getAvatarWidget(controller.groupProfile?.avatar)
                  .tight(width: 45.w, height: 45.w),
/*        ImageWidget.url(
          controller.groupProfile?.avatar ?? '')
            .tight(width: 45.w, height: 45.w)
            */
            ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
              controller.onGroupAvatarTapped();
            }).paddingHorizontal(AppSpace.page),
            const Divider(
              height: 1,
            ).paddingHorizontal(AppSpace.page),
            [
              const TextWidget.body1('群主转让').expanded(),
              IconWidget.icon(Icons.arrow_right_sharp)
            ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
              controller.onGroupOwnerTransferTapped();
            }).paddingHorizontal(AppSpace.page),
            const Divider(
              height: 1,
            ).paddingHorizontal(AppSpace.page),
            [
              const TextWidget.body1('群成员配置').expanded(),
              IconWidget.icon(Icons.arrow_right_sharp)
            ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
              controller.onGroupMemberManageTapped();
            }).paddingHorizontal(AppSpace.page),
          ]
        : [
            [
              const TextWidget.body1('群头像').expanded(),
              ImageWidget.url(controller.groupProfile?.avatar ?? '')
                  .tight(width: 45.w, height: 45.w)
            ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
              controller.onGroupAvatarTapped();
            }).paddingHorizontal(AppSpace.page),
            const Divider(
              height: 1,
            ).paddingHorizontal(AppSpace.page),
            [
              const TextWidget.body1('群成员配置').expanded(),
              IconWidget.icon(Icons.arrow_right_sharp)
            ].toRow().tight(height: 50).backgroundColor(Colors.white).onTap(() {
              controller.onGroupMemberManageTapped();
            }).paddingHorizontal(AppSpace.page),
          ];

    return children.toColumn();
/*
    return const Center(
      child: Text("GroupManagePage"),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupManageController>(
      init: GroupManageController(),
      id: "group_manage",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群管理',
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
