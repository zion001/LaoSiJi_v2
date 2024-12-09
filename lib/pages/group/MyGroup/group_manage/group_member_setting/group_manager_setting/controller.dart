import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class GroupManagerSettingController extends GetxController {
  late GroupProfile? groupProfile = Get.arguments['groupProfile'];
  StreamSubscription? subscription;

  GroupManagerSettingController();

  _initData() {
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      if (event.groupId != (groupProfile?.groupId ?? 0)) {
        return;
      }
      groupProfile = GroupManager.groupInfo(groupProfile?.groupId ?? 0);
      update(["group_manager_setting"]);
    });

    update(["group_manager_setting"]);
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

  Future<void> onSetRoleTapped(int memberId, int curRole) async {
    if (curRole != 2 && curRole != 3) {
      return;
    }

    if (groupProfile?.groupId == null) {
      return;
    }

    int role = curRole == 2 ? 3 : 2;

    Loading.show();

    bool success = await GroupApi.setGroupMemberRole(
        groupProfile!.groupId!, memberId, role);
    Loading.dismiss();
    if (success) {
      // 更新指定成员数据
      /*  for ( int i = 0 ; i < groupProfile!.members.length ; ++i ) {
        if ( groupProfile!.members[i].userId == memberId ) {
          groupProfile!.members[i].role = role;
          break;
        }
      }
      */
      GroupManager.setRole(groupProfile!.groupId!, memberId, role);

      // 更新群数据
      //  GroupManager.updateGroup(groupProfile!);
      //  update(["group_manager_setting"]);

      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);
    }
  }
}
