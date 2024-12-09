import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class UpdateRemarkController extends GetxController {
  // 用户信息
  final UserInfoBasic? userInfo = Get.arguments['userInfoBasic'];

  //备注
  TextEditingController remarkController = TextEditingController();

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  UpdateRemarkController();

  _initData() {
    remarkController.text = userInfo?.remark ?? '';
    update(["updateremark"]);
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
    remarkController.dispose();
    super.onClose();
  }

  void setRemark() {
    if (!(formKey.currentState as FormState).validate()) {
      return;
    }

    var uid = userInfo?.targetUid;
    if (uid == null) {
      Loading.error('数据异常');
      return;
    }
    if (remarkController.text.isEmpty) {
      Loading.error('请输入');
      return;
    }
    Loading.show();
    FriendApi.updateRemark(uid, remarkController.text).then((remark) {
      Loading.success('设置成功');

      ContactsManager.updateFriendRemark(uid, remark ?? '');
      // 发送刷新事件
      RefreshContactsEvent refreshContactsEvent = RefreshContactsEvent();
      EventBusUtils.shared.fire(refreshContactsEvent);

      Get.back(result: remark);
    });
  }
}
