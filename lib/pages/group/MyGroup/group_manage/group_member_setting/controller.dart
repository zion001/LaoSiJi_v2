import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class GroupMemberSettingController extends GetxController {
  final GroupProfile? groupProfile = Get.arguments['groupProfile'];

  GroupMemberSettingController();

  _initData() {
    update(["group_member_setting"]);
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

  /// 群管理员配置
  void onManagerSettingTapped() {
    Get.toNamed(
        RouteNames.groupMyGroupGroupManageGroupMemberSettingGroupManagerSetting,
        arguments: {'groupProfile': groupProfile});
  }

  /// 设置禁言
  void onMuteSettingTapped() {
    Get.toNamed(
        RouteNames.groupMyGroupGroupManageGroupMemberSettingGroupMuteSetting,
        arguments: {'groupProfile': groupProfile});
  }
}
