import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class FriendApplyListController extends GetxController {
  // List<FriendApplyModel> list = <FriendApplyModel>[];

  FriendApplyListController();

  _initData() async {
    //list = await FriendApi.friendApplyList();

    update(["friend_apply_list"]);
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

  /// 同意
  void acceptApply(int applyId) async {
    bool b = await FriendApi.acceptAppy(applyId);
    if (b) {
      //list.removeWhere((element) => element.applyId == applyId);
      //update(["friend_apply_list"]);
      //FriendApplyManager.refreshFriendApplyLis();
      await FriendApplyManager.refreshFriendApplyLis();
      update(["friend_apply_list"]);
    }
  }

  /// 拒绝
  void refuseApply(int applyId) async {
    bool b = await FriendApi.refuseAppy(applyId);
    if (b) {
      //list.removeWhere((element) => element.applyId == applyId);
      await FriendApplyManager.refreshFriendApplyLis();
      update(["friend_apply_list"]);
      //FriendApplyManager.refreshFriendApplyLis();
    }
  }
}
