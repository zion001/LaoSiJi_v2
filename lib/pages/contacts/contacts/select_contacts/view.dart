import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class SelectContactsPage extends GetView<SelectContactsController> {
  const SelectContactsPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    if (controller.operation == 1) {
      return [
        CustomScrollView(
          slivers: _buildContactList(),
        ).expanded(),
        [
          ButtonWidget.text(
            '全消',
            textColor: AppColors.primary,
            width: 50.w,
            height: 30.w,
            onTap: controller.onTapCancelAll,
          ),
          Gap(16.w),
          ButtonWidget.textFilled(
            '全选',
            width: 50.w,
            height: 30.w,
            onTap: controller.onTapSelectAll,
          ),
          Gap(16.w),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.end)
            .backgroundColor(Colors.black12)
            .tight(height: 45.w),
      ].toColumn();
    } else {
      return CustomScrollView(
        slivers: _buildContactList(),
      );
    }
  }

  // 好友列表项
  List<Widget> _buildContactList() {
    var cells = controller.allUsers.map((group) => _buildGroup(group));
    return cells.map((e) => e.sliverBox).toList();
  }

  // 一个分组
  Widget _buildGroup(ContactGroup group) {
    var items = group.list.map((friend) => _buildConact(friend)).toList();
    items.insert(
      0,
      TextWidget.title3(
        group.groupTitle,
        color: AppColors.primary,
      )
          .marginSymmetric(horizontal: AppSpace.page)
          .backgroundColor(AppColors.primaryContainer),
    );

    return items.toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  // 一个联系人
  Widget _buildConact(FriendListItemModel friend) {
    var avatar = ImUtil.getAvatarWidget(friend.user_profile?.avatar);
    /*friend.user_profile?.avatar == null
        ? const ImageWidget.asset(AssetsImages.avatarDefaultPng)
        : ImageWidget.url(friend.user_profile?.avatar ?? '');
        */
    //'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${friend.user_profile?.avatar ?? ''}');
    var online = friend.isOnline ?? false
        ? LocaleKeys.commonOnline.tr
        : LocaleKeys.commonOffline.tr;
    var onlineColor = friend.isOnline ?? false
        ? AppColors.primary
        : AppColors.onSecondaryContainer;
    // 显示昵称或备注
    var showName = (friend.remark == null || friend.remark!.isEmpty)
        ? friend.user_profile?.nickname
        : friend.remark;
    // 选中状态图标
    var statusIcon = IconWidget.icon(
      Icons.check_circle_outline,
      color: Colors.white.withOpacity(0.0),
    ); // 不显示
    if (friend.selectedStatus == 0) {
      //未选中
      statusIcon = IconWidget.icon(
        Icons.circle_outlined,
        color: Colors.grey,
      );
    } else if (friend.selectedStatus == 1) {
      //已选中
      statusIcon = IconWidget.icon(
        Icons.check_circle_outline,
        color: AppColors.primary,
      );
    } else if (friend.selectedStatus == -1) {
      // 禁止选择
      statusIcon = IconWidget.icon(
        Icons.stop_circle_outlined,
        color: AppColors.shadow,
      );
    }

    var content = <Widget>[
      avatar.tightSize(40.w),
      Gap(AppSpace.listRow),
      TextWidget.body1(showName ?? '').expanded(),
      /*    TextWidget.body2(
        '($online)',
        color: onlineColor,
      ),
      */
      statusIcon,
    ].toRow().marginSymmetric(
          horizontal: AppSpace.page,
          vertical: AppSpace.listView,
        );

    return <Widget>[
      content.onTap(() {
        controller.onTapContact(friend);
      }),
      Container(
        height: 1,
        color: Colors.black12,
      ).paddingOnly(left: AppSpace.page + 40.w, right: AppSpace.page),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectContactsController>(
      init: SelectContactsController(),
      id: "select_contacts",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            controller.title,
            actions: ButtonWidget.textFilled(
                controller.selectedMemberUid.isEmpty
                    ? '确定'
                    : '确定(${controller.selectedMemberUid.length})'),
            rightCallback: controller.onSubmitTapped,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}

/*

            actions: IconWidget.icon(
              Icons.add_circle_outline,
              color: AppColors.onPrimary,
            ),
            rightCallback: controller.onTapAddFriend,


*/
