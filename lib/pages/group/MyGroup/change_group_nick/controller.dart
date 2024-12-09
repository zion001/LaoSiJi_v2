import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class ChangeGroupNickController extends GetxController {
  //群内昵称
  TextEditingController nickController = TextEditingController();

  //群信息
  final GroupProfile? groupProfile = Get.arguments['group'];

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  ChangeGroupNickController();

  _initData() {
    nickController.text = groupProfile?.selfInfo?.nick ?? '';
    update(["change_group_nick"]);
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

  Future<void> onBtnTapped() async {
    if (!(formKey.currentState as FormState).validate()) {
      return;
    }

    bool success = await GroupApi.setGroupNick(
        groupProfile?.groupId ?? 0, nickController.text);
    if (success) {
      Get.back(result: nickController.text);

      GroupManager.changeGroupNick(groupProfile!.groupId!,
          UserService.to.profile.user_id ?? 0, nickController.text);

/*
      groupProfile?.selfInfo?.nick = nickController.text;
      for (var member in groupProfile!.members ) {
        if ( member.userId == UserService.to.profile.user_id ) {
          member.nick = nickController.text;
        }
      }
      GroupManager.updateGroup(groupProfile!);
      */

      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile!.groupId!);
      EventBusUtils.shared.fire(refreshGroupEvent);
    }
  }
}
