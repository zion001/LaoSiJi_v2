import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

/// 好友申请列表管理
class FriendApplyManager {
  /// 好友申请列表
  //static List<FriendApplyModel> friendApplyList = [];
  static List<FriendApplyModel> friendApplyList = <FriendApplyModel>[];
  static RxInt applyCount = 0.obs;

  /// 刷新数据
  static Future<void> refreshFriendApplyLis() async {
    friendApplyList = await FriendApi.friendApplyList();
    applyCount.value = friendApplyList.length;
    // 发送刷新事件
    // RefreshFriendListEvent refreshFriendListEvent = RefreshFriendListEvent();
    // EventBusUtils.shared.fire(refreshFriendListEvent);
  }
}
