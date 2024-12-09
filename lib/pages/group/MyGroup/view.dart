import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';

class MyGroupPage extends GetView<MyGroupController> {
  const MyGroupPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    print(GroupManager.groupList.length);

    return EasyRefresh(
      onRefresh: () async {
        controller.refreshGroupList();
      },
      child: CustomScrollView(
        //slivers: controller.groupList.map((e) => groupListItem(e)).toList(),

        slivers: GroupManager.groupList.map((e) => groupListItem(e)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyGroupController>(
      init: MyGroupController(),
      id: "mygroup",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '我的群聊',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  /// 群列表项
  Widget groupListItem(GroupProfile group) {
    return [
      [
        //ImageWidget.url(group.avatar ?? "", fit: BoxFit.cover,).tight(width: 50.w, height: 50.w),
        ImUtil.getAvatarWidget(group.avatar ?? "")
            .tight(width: 50.w, height: 50.w),
        Gap(AppSpace.listRow),
        TextWidget.body1('${group.title ?? ""}(${group.members.length ?? 0})'),
      ]
          .toRow(crossAxisAlignment: CrossAxisAlignment.center)
          .paddingAll(AppSpace.page),
      const Divider(
        height: 1,
      ),
    ].toColumn().onTap(() {
      controller.onTabGroupListItem(group);
    }).sliverBox;
  }

  ///
  /*
  Widget groupListItem(GroupListModel group) {
    return [
      [
        ImageWidget.url(group.avatar ?? "").tight(width: 50.w, height: 50.w),
        Gap(AppSpace.listRow),
        TextWidget.body1('${group.title ?? ""}(${group.memberCount ?? 0})'),
      ]
          .toRow(crossAxisAlignment: CrossAxisAlignment.center)
          .paddingAll(AppSpace.page),
      const Divider(
        height: 1,
      ),
    ].toColumn().onTap(() {
      controller.onTabGroupListItem(group);
    }).sliverBox;
  }
  */
}
