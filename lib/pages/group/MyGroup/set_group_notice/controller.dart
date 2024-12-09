import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class SetGroupNoticeController extends GetxController {
  GroupProfile? groupProfile = Get.arguments['groupProfile'];

  TextEditingController noticeController = TextEditingController();

  SetGroupNoticeController();

  _initData() {
    noticeController.text = groupProfile?.notice ?? '';
    update(["set_group_notice"]);
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
    if (noticeController.text.isEmpty) {
      Loading.toast("请输入");
      return;
    }

    if (noticeController.text.length > 5000 ||
        noticeController.text.length < 2) {
      Loading.toast("公告内容不能少于2字符，也不能多于5000字符");
      return;
    }

    // 新公告和旧公告相同，直接返回。
    if (noticeController.text == groupProfile?.notice) {
      Get.back();
      return;
    }

    Loading.show();
    var success = await GroupApi.setGroupNotice(
        groupProfile?.groupId ?? 0, noticeController.text);
    if (success) {
      Loading.dismiss();
      groupProfile?.notice = noticeController.text;
      GroupManager.updateGroup(groupProfile!);
      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);

      Get.back();
    }
  }

  /// 清空输入
  void onClearTapped() {
    noticeController.clear();
  }
}
