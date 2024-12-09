import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class GroupMuteSettingController extends GetxController {
  final GroupProfile? groupProfile = Get.arguments['groupProfile'];
  StreamSubscription? subscription;

  GroupMuteSettingController();

  _initData() {
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      print('收到刷新事件');
      update(["group_mute_setting"]);
    });
    update(["group_mute_setting"]);
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

  @override
  void onClose() {
    super.onClose();
    subscription?.cancel();
  }

  /// 全员禁言
  Future<void> onAllMuteChanged(bool bMute) async {
    if (groupProfile == null) {
      return;
    }

    bool success = await GroupApi.setGroupMuteAll(
        groupProfile!.groupId ?? 0, bMute ? 1 : 0);
    if (success) {
      groupProfile!.isMuteAll = bMute ? 1 : 0;
      GroupManager.updateGroup(groupProfile!);
      update(["group_mute_setting"]);
    }
  }

  /// 取消禁言群成员
  Future<void> onMuteTapped(int memberId) async {
    if (groupProfile?.groupId == null) {
      return;
    }
    Loading.show();

    // 查找指定成员数据
    int mute = 0;
    for (int i = 0; i < groupProfile!.members.length; ++i) {
      if (groupProfile!.members[i].userId == memberId) {
        //groupProfile!.members[i].muteUntil = 0;
        mute = (groupProfile!.members[i].muteUntil ?? 0) == 0
            ? 60 * 60 * 24 * 3650
            : 0;
        //groupProfile!.members[i].muteUntil = mute;
        break;
      }
    }

    bool success = await GroupApi.setMemberMute(
        groupProfile!.groupId!, memberId, mute > 0);
    Loading.dismiss();
    if (success) {
      //groupProfile
      // 更新指定成员数据
      for (int i = 0; i < groupProfile!.members.length; ++i) {
        if (groupProfile!.members[i].userId == memberId) {
          groupProfile!.members[i].muteUntil = mute;
          break;
        }
      }

      // 更新群数据
      GroupManager.updateGroup(groupProfile!);
      update(["group_mute_setting"]);
    }
  }
}
