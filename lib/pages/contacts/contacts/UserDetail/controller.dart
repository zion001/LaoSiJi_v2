import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class UserDetailController extends GetxController {
  // 用户userId
  final UserInfoBasic? userBasic = Get.arguments['userInfo'];
  // 好友来源 1搜索添加 2二维码 3群聊
  final int source = Get.arguments['source'] ?? 1;
  // 用户username，用户信息接口里没有，需要上搜索页传过来
  final String username = Get.arguments['username'];

  // 好友详情
  // UserInfoDetail? userInfoDetail;

  UserDetailController();

  _initData() {
    update(["userdetail"]);
    //  friendDetail();
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

  /// 添加好友
  Future<void> addFriend() async {
    var uid = userBasic?.targetUid;
    if (uid == null) {
      Loading.error('数据异常');
      return;
    }
    FriendApi.addFriend(uid, source).then((value) {
      switch (value) {
        case -1:
          break;
        case 0: // 添加好友成功
          Loading.success(LocaleKeys.contactAddFriendSuccessHint.tr);
          userBasic!.relation = true;
          // 将当前添加对象加入ContactsManager
          FriendListItemModel friend = FriendListItemModel();
          friend.uid = userBasic?.targetUid;
          friend.remark = userBasic?.remark;
          friend.source = userBasic?.source;
          friend.pinYin = userBasic?.pinYin;
          friend.relation = userBasic?.relation;
          friend.isOnline = false; // 需要另外获取
          friend.user_profile = Profile(
            avatar: userBasic?.userProfile?.avatar,
            nickname: userBasic?.userProfile?.nickname,
            username: username,
            role: userBasic?.userProfile?.role,
            custom_field: userBasic?.userProfile?.customField,
          );
          friend.custom_field = userBasic?.customField;
          ContactsManager.addFriend(friend);

          // 发送刷新事件
          RefreshContactsEvent refreshContactsEvent = RefreshContactsEvent();
          EventBusUtils.shared.fire(refreshContactsEvent);
          break;
        case 30539:
          Loading.success(LocaleKeys.contactAddFriendWaitForConfirmHint.tr);
          break;
      }
      update(["userdetail"]);
    });
  }

  /// 删除好友
  Future<bool> deleteFriend() async {
    var uid = userBasic?.targetUid;
    if (uid == null) {
      Loading.error('数据异常');
      return false;
    }

    return FriendApi.deleteFriend(uid).then((value) {
      if (value) {
        Loading.success('删除好友成功');

        userBasic!.relation = false;
        update(["userdetail"]);

        ContactsManager.deleteFriend(uid);
        // 发送刷新事件
        RefreshContactsEvent refreshContactsEvent = RefreshContactsEvent();
        EventBusUtils.shared.fire(refreshContactsEvent);
      }
      return value;
    });
  }

  /// 修改备注
  void onTapRemark() {
    if (userBasic == null) {
      Loading.error('数据异常');
      return;
    }

    Get.toNamed(
      RouteNames.contactsContactsUpdateRemark,
      arguments: {'userInfoBasic': userBasic!},
    )?.then((remark) {
      if (remark != null) {
        userBasic?.remark = remark;
        update(["userdetail"]);
      }
    });
  }

  /// 发送消息
  void onTapMessage() {
    // userBasic
    FriendListItemModel user = FriendListItemModel();
    user.uid = userBasic?.targetUid;
    user.remark = userBasic?.remark;
    user.source = userBasic?.source;
    user.pinYin = userBasic?.pinYin;
    user.relation = userBasic?.relation;
    user.isOnline = false;

    user.user_profile = Profile();
    user.user_profile?.nickname = userBasic?.userProfile?.nickname;
    user.user_profile?.avatar = userBasic?.userProfile?.avatar;
    user.user_profile?.username = username;
    user.user_profile?.role = userBasic?.userProfile?.role;
    user.user_profile?.custom_field = userBasic?.userProfile?.customField;

    user.custom_field = userBasic?.customField;

    Get.toNamed(RouteNames.chat, arguments: {'chat_person': user});
  }
}
