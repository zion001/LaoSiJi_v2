import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';

class GroupMemberSettingPage extends GetView<GroupMemberSettingController> {
  const GroupMemberSettingPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    bool isOwner = controller.groupProfile?.isOwner() ?? false;
    if (isOwner) {
      return [
        OptionListCell(
          title: '群管理员配置',
        ).tight(height: 50).onTap(() {
          controller.onManagerSettingTapped();
        }),
        OptionListCell(
          title: '设置禁言',
        ).tight(height: 50).onTap(() {
          controller.onMuteSettingTapped();
        }),
      ].toColumn();
    } else {
      return [
        OptionListCell(
          title: '设置禁言',
        ).tight(height: 50).onTap(() {
          controller.onMuteSettingTapped();
        }),
      ].toColumn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupMemberSettingController>(
      init: GroupMemberSettingController(),
      id: "group_member_setting",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群成员配置',
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
