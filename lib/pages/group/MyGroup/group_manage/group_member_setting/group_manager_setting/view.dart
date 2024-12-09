import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class GroupManagerSettingPage extends GetView<GroupManagerSettingController> {
  const GroupManagerSettingPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    List<GroupMemberModel> mutedMembers =
        controller.groupProfile?.members ?? <GroupMemberModel>[];

    return [
      Gap(AppSpace.page),
      ListView.separated(
        itemBuilder: (context, itemIndex) {
          return memberCell(mutedMembers[itemIndex]);
        },
        separatorBuilder: (context, itemIndex) {
          return const Divider(
            height: 1,
          );
        },
        itemCount: mutedMembers.length,
      ).expanded(),
      Gap(AppSpace.page),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .marginSymmetric(horizontal: AppSpace.page);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupManagerSettingController>(
      init: GroupManagerSettingController(),
      id: "group_manager_setting",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群管理员设置',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  /// 群成员cell
  Widget memberCell(GroupMemberModel member) {
    String action = '';
    Color actionColor = Colors.black;
    String role = "";
    Color roleColor = Colors.black;
    if (member.role == 1) {
      action = "群主";
      actionColor = AppColors.error;
      role = '群主';
      roleColor = AppColors.error;
    } else if (member.role == 2) {
      action = '取消管理员';
      actionColor = Colors.grey;
      role = '管理员';
      roleColor = AppColors.primary;
    } else if (member.role == 3) {
      action = '设置管理员';
      actionColor = Colors.black;
    }
    var roleText = role.isEmpty
        ? Container()
        : TextWidget.body3(
            role,
            color: Colors.white,
          )
            .marginSymmetric(horizontal: 2.w)
            .backgroundColor(roleColor)
            .clipRRect(all: 3.w);
    return [
      //ImageWidget.url(member.avatar ?? '', fit: BoxFit.cover,).tight(height: 40, width: 40),
      [
        ImageWidget.url(
          member.avatar ?? '',
          fit: BoxFit.cover,
        ).tight(width: 40.w, height: 40.w),
        roleText.positioned(top: 0, right: 0),
      ].toStack().tight(width: 40.w, height: 40.w),
      Gap(AppSpace.listItem),
      TextWidget.body1(member.nickname ?? "").expanded(),
      member.user_role == 2 ? 
      ButtonWidget.text(
        action,
        textColor: actionColor,
        onTap: () {
          controller.onSetRoleTapped(member.userId ?? 0, member.role ?? 0);
        },
      ).tight(width: 80, height: 45) : Container(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center).tight(height: 50);
  }
}
