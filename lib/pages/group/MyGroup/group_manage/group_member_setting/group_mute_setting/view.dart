import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';

class GroupMuteSettingPage extends GetView<GroupMuteSettingController> {
  const GroupMuteSettingPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    /*  List<GroupMemberModel> mutedMembers =
        (controller.groupProfile?.members ?? <GroupMemberModel>[])
            .where((element) => (element.muteUntil ?? 0) > 0)
            .toList();
            */

    List<GroupMemberModel> mutedMembers =
        controller.groupProfile?.members ?? <GroupMemberModel>[];

    return [
      Gap(AppSpace.page),
      headerWidget(),
      Gap(AppSpace.page),
      const Divider(
        height: 1,
      ),
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
//      ButtonWidget.textFilled('选择成员').tight(height: 50),
      Gap(AppSpace.page),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .marginSymmetric(horizontal: AppSpace.page);
  }

  /// 头部全员禁言
  Widget headerWidget() {
    return [
      [
        const TextWidget.body1('全员禁言'),
        const TextWidget.body2('开启后只允许群主和管理员发言'),
      ]
          .toColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center)
          .expanded(),
      Switch(
          value: (controller.groupProfile?.isMuteAll ?? 0) == 0 ? false : true,
          activeColor: AppColors.primary,
          onChanged: controller.onAllMuteChanged),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center).height(65);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupMuteSettingController>(
      init: GroupMuteSettingController(),
      id: "group_mute_setting",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '设置禁言',
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
    bool isMemberOwner =
        controller.groupProfile?.isOwner(userID: member.userId ?? 0) ?? false;
    bool isMemberManager =
        controller.groupProfile?.isManager(userID: member.userId ?? 0) ?? false;

    bool isMyselfOwner = controller.groupProfile?.isOwner() ?? false;
    bool isMyselfManager = controller.groupProfile?.isManager() ?? false;

    String roleString = '';
    Color roleColor = Colors.white;
    if (member.role == 1) {
      roleString = '群主';
      roleColor = AppColors.error;
    } else if (member.role == 2) {
      roleString = '管理员';
      roleColor = AppColors.primary;
    }

    Widget header = [
      ImUtil.getAvatarWidget(member.avatar).tight(height: 40, width: 40),
      /*ImageWidget.url(
          member.avatar ?? '',
          fit: BoxFit.cover,
        ).tight(height: 40, width: 40),
        */
      TextWidget.body3(
        roleString,
        color: Colors.white,
      ).backgroundColor(roleColor).positioned(top: 2.w, right: 2.w),
    ].toStack();

    // 如果自己是群主
    if (isMyselfOwner) {
      String actionStr = (member.muteUntil ?? 0) > 0 ? '取消禁言' : '禁言';
      if (isMemberOwner) {
        actionStr = '';
      }

      return [
        header,
        Gap(AppSpace.listItem),
        TextWidget.body1(member.nickname ?? "").expanded(),
        ButtonWidget.text(
          actionStr,
          textColor:
              (member.muteUntil ?? 0) > 0 ? AppColors.primary : AppColors.error,
          onTap: () {
            if (!isMemberOwner) {
              // 不是群主时，才响应
              controller.onMuteTapped(member.userId ?? 0);
            }
          },
        ).tight(width: 80, height: 45),
      ].toRow(crossAxisAlignment: CrossAxisAlignment.center).tight(height: 50);
    } else if (isMyselfManager) {
      // 如果自己是管理员
      String actionStr = (member.muteUntil ?? 0) > 0 ? '取消禁言' : '禁言';
      if (isMemberOwner || isMemberManager) {
        actionStr = '';
      }

      return [
        header,
        Gap(AppSpace.listItem),
        TextWidget.body1(member.nickname ?? "").expanded(),
        ButtonWidget.text(
          actionStr,
          textColor:
              (member.muteUntil ?? 0) > 0 ? AppColors.primary : AppColors.error,
          onTap: () {
            if (!isMemberOwner && !isMyselfManager) {
              // 不是群主和管理员时，才响应
              controller.onMuteTapped(member.userId ?? 0);
            }
          },
        ).tight(width: 80, height: 45),
      ].toRow(crossAxisAlignment: CrossAxisAlignment.center).tight(height: 50);
    } else {
      return [
        header,
        Gap(AppSpace.listItem),
        TextWidget.body1(member.nickname ?? "").expanded(),
      ].toRow(crossAxisAlignment: CrossAxisAlignment.center).tight(height: 50);
    }
  }
}
