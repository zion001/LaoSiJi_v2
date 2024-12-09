import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/common/api/group_api.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class MyGroupController extends GetxController {
  /// 我的群列表
  //List<GroupListModel> groupList = [];
  //List<GroupProfile> groupList = [];

  StreamSubscription? subscription;
  MyGroupController();

  _initData() {
    //groupList = GroupManager.groupList;
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      update(["mygroup"]);
    });
    update(["mygroup"]);
//    refreshGroupList();
  }

/*
  Future<void> refreshGroupList() async {
    groupList = GroupManager.groupList;
   // groupList = await GroupApi.groupList();
    update(["mygroup"]);
  }
  */

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
  /// 点击群列表
  /*void onTabGroupListItem(GroupListModel group) {
    Get.toNamed(
      RouteNames.groupMyGroupDetail,
      arguments: {
        'groupId': group.groupId,
      },
    );
  }
  */
  void onTabGroupListItem(GroupProfile group) {
    Get.toNamed(RouteNames.chat, arguments: {'chat_group': group});
  }

  void refreshGroupList() {
    GroupManager.refreshAllGroup();
    update(["mygroup"]);
  }
}
