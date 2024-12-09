import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

/// 用户信息页面

class UserDetailPage extends GetView<UserDetailController> {
  const UserDetailPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    var array = <Widget>[];
    array.addAll([
      Gap(20.w),
      [
        ImUtil.getAvatarWidget(controller.userBasic?.userProfile?.avatar ?? '')
            .tightSize(120.w)
      ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      /*
      ImageWidget.url(
        controller.userBasic?.userProfile?.avatar ?? '',
        placeholder: const ImageWidget.asset(
          AssetsImages.avatarDefaultPng,
          fit: BoxFit.fitHeight,
        ).tightSize(120.w),
      ).tightSize(120.w),
      */
      Gap(20.w),
      TextWidget.title2(
        controller.userBasic?.userProfile?.nickname ?? '',
        textAlign: TextAlign.center,
      ),
    ]);
    if(controller.userBasic?.targetUid != UserService.to.profile.user_id) {
      //如果是好友，则有“备注”,“发送消息”,"删除好友"
      if (controller.userBasic?.isFriend ?? false) {
        array.add(Gap(20.w));
        //备注
        array.add(OptionListCell(
          title: LocaleKeys.commonRemark.tr,
          content: controller.userBasic?.remark ??
              '无备注', //controller.userInfoDetail?.remark ?? '无备注',
        ).tight(height: 50.w).onTap(() {
          controller.onTapRemark();
        }));
        array.add(Gap(4.w));
        //删除好友
        array.add(OptionListCell(title: LocaleKeys.contactDeleteFriend.tr)
            .tight(height: 50.w)
            .onTap(() {
          ImDialog.confirmDialog('提示', '删除好友?', () {
            controller.deleteFriend();
          });
        }));
        array.add(Gap(40.w));
        //发送消息
        array.add(ButtonWidget.textFilled(
          LocaleKeys.commonSendMessage.tr,
          onTap: controller.onTapMessage,
        ).tight(height: 50.w));
      } else {
        //如果不是好友，则"添加好友"
        array.add(Gap(40.w));
        //添加好友
        array.add(ButtonWidget.textFilled(
          LocaleKeys.contactAddFriend.tr,
          onTap: () => controller.addFriend(),
        ).tight(height: 50.w));
      }
    }
    return array
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .marginOnly(left: 10, right: 10);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserDetailController>(
      init: UserDetailController(),
      id: "userdetail",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(context, '用户详情'),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
