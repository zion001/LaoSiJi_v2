import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';

class GroupDetailPage extends GetView<GroupDetailController> {
  const GroupDetailPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    bool isOwnerOrManager = false;
    isOwnerOrManager = (controller.groupProfile?.isOwner() ?? false) ||
        (controller.groupProfile?.isManager() ?? false);
    List<Widget> children = [
      // 群成员
      groupMembers().sliverBox,
      Gap(AppSpace.page).sliverBox,
      // 群名称
      groupListCell(
        '群名称',
        content: controller.groupProfile?.title,
      ),
      const Divider(
        height: 1,
      ).marginSymmetric(horizontal: AppSpace.page).sliverBox,
      groupListCell(
        '群公告',
        content: controller.groupProfile?.notice ?? '未设置',
      ),
      const Divider(
        height: 1,
      ).marginSymmetric(horizontal: AppSpace.page).sliverBox,
      groupListCell(
        '群管理',
      ),
      Gap(AppSpace.page).sliverBox,
      groupListCell('置顶聊天',
          surfix: Switch(
            value: controller.conversationModel?.is_pinned ?? false,
            activeColor: AppColors.primary,
            onChanged: (value) {
              controller.onTapPin(value);
            },
          )),
      Gap(AppSpace.page).sliverBox,
      groupListCell('我在本群的昵称',
          content: (controller.groupProfile?.selfInfo?.nick ?? '').isEmpty
              ? '未设置'
              : (controller.groupProfile?.selfInfo?.nick ?? '')),
      Gap(AppSpace.page).sliverBox,
      // 清空聊天记录
      TextWidget.title3(
        '清空聊天记录',
        color: AppColors.primary,
      ).center().tight(height: 55.w).backgroundColor(Colors.white).onTap(() {
        controller.clearHistoryMessage();
      }).sliverBox,
      const Divider(
        height: 1,
      ).marginSymmetric(horizontal: AppSpace.page).sliverBox,
      TextWidget.title3(
        isOwnerOrManager ? '解散群组' : '退出群组', //'解散群聊',
        color: AppColors.primary,
      ).center().tight(height: 55.w).backgroundColor(Colors.white).onTap(() {
        controller.onDissmisGroupTapped();
      }).sliverBox,
    ];

    if (!isOwnerOrManager) {
      children.removeAt(6);
    }

    return EasyRefresh(
      onRefresh: () async {
        //controller.refreshGroupList();
      },
      child: CustomScrollView(
        slivers: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupDetailController>(
      init: GroupDetailController(),
      id: "group_detail",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群信息(${controller.groupProfile?.members.length ?? 0})',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  /// 群成员模块
  Widget groupMembers() {
    var membersCell = (controller.groupProfile?.members ?? <GroupMemberModel>[])
        .map((e) => memberCell(e))
        .toList();

    // 如果是群主或管理员，则增加两项‘增加成员’和'删除成员'
    bool isOwnerOrManager = false;
    isOwnerOrManager = (controller.groupProfile?.isOwner() ?? false) ||
        (controller.groupProfile?.isManager() ?? false);
    var operationCnt = isOwnerOrManager ? 2 : 0;

    return GridView.builder(
        padding: EdgeInsets.all(AppSpace.page),
        shrinkWrap: true,
        itemCount: membersCell.length + operationCnt,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemBuilder: (context, index) {
          if (index < membersCell.length) {
            return membersCell[index];
          } else if (index == membersCell.length) {
            return operateCell("加入成员").onTap(() {
              controller.onTapAddMembers();
            });
          } else if (index == membersCell.length + 1) {
            return operateCell("移出成员").onTap(() {
              controller.onTapRemoveMembers();
            });
          } else {
            return const TextWidget.body1('ERR');
          }
        }).backgroundColor(Colors.white);
  }

  /// 列表项
  Widget groupListCell(String? title, {String? content, Widget? surfix}) {
    return [
      TextWidget.body1(title ?? ""),
      Gap(AppSpace.listRow),
      TextWidget.body2(
        content ?? "",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.right,
      ).expanded(),
      surfix ?? IconWidget.icon(Icons.arrow_right_sharp),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
        .paddingSymmetric(horizontal: AppSpace.page)
        .tight(height: 50.w)
        .backgroundColor(Colors.white)
        .onTap(() {
      controller.onListTapped(title);
    }).sliverBox;
  }

  /// 群成员单元格
  Widget memberCell(GroupMemberModel member) {
    // 名字（需要显示好友备注）
    FriendListItemModel? userItemModel =
    ContactsManager.getFriend(member.userId!);
    var name;
    if(member.nick?.isNotEmpty??false)
      name = member.nick;
    else if(userItemModel?.remark?.isNotEmpty??false)
      name = userItemModel?.remark;
    else
      name = member.nickname;
    var nameText = TextWidget.body2(name ?? '');
    // 群主/管理员 标签
    var role = '';
    var roleColor = Colors.white;
    switch (member.role) {
      case 1:
        role = '群主';
        roleColor = AppColors.error;
        break;
      case 2:
        role = '管理员';
        roleColor = AppColors.primary;
        break;
      default:
        break;
    }
    var ownerText = role.isEmpty
        ? Container()
        : TextWidget.body3(
            role,
            color: Colors.white,
          )
            .marginSymmetric(horizontal: 2.w)
            .backgroundColor(roleColor)
            .clipRRect(all: 3.w);

    return [
      [
        //ImageWidget.url(member.avatar ?? '', fit: BoxFit.cover,).tight(width: 50.w, height: 50.w),
        ImUtil.getAvatarWidget(member.avatar ?? '')
            .tight(width: 50.w, height: 50.w),
        ownerText.positioned(top: 0, right: 0),
      ].toStack().tight(width: 50.w, height: 50.w),
      Gap(AppSpace.listItem),
      nameText
    ].toColumn();
  }

  ///操作 加群成员/删群成员
  Widget operateCell(String operation) {
    // 名字
    var nameText = TextWidget.body2(operation);
    var icon = operation.contains('加入')
        ? IconWidget.icon(
            Icons.add_circle_outline,
            color: AppColors.primary,
            size: 50.w,
          )
        : IconWidget.icon(
            Icons.remove_circle_outline,
            color: AppColors.primary,
            size: 50.w,
          );
    return [icon, Gap(AppSpace.listItem), nameText].toColumn();
  }
}
