import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class SetGroupNameController extends GetxController {
  SetGroupNameController();

  int operation = Get.arguments['operation']; // 1 创建群聊 2 修改群名称
  List<int> selectedMembers =
      Get.arguments['selectedMembers']; // 创建群聊时，选中群成员（修改群信息时无效）
  GroupProfile groupProfile = Get.arguments['groupProfile']; // 群信息（创建群聊时无效）

  //群名称
  TextEditingController groupNameController = TextEditingController();

  _initData() {
    update(["set_group_name"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  /// 点击确定
  void onSubmitTapped() {
    if (groupNameController.text.isEmpty) {
      Loading.error('请输入群名称');
      return;
    }
    if (operation == 1) {
      // 创建群聊
      // 进入设置群头像
      Get.toNamed(RouteNames.groupMyGroupSetGroupAvatar, arguments: {
        'operation': 1,
        'selectedMembers': selectedMembers,
        'groupName': groupNameController.text,
        'groupProfile': groupProfile,
      });
    } else if (operation == 2) {
      // 修改群名称
      _setGroupName();
    } else {
      Loading.toast('未定义：${operation}');
    }
  }

  /// 修改群名称
  Future<void> _setGroupName() async {
    if (groupNameController.text.isEmpty) {
      Loading.error('请先输入');
      return;
    }
    bool success = await GroupApi.setGroupTitle(
        groupProfile.groupId ?? 0, groupNameController.text);
    if (success) {
      var group = groupProfile;
      group.title = groupNameController.text;
      GroupManager.updateGroup(group);

      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: group?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);

      Get.back();
    }
  }

  /// 点击清空输入
  void onClearTapped() {
    groupNameController.clear();
  }
}
