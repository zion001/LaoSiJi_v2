import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/user_info_basic/user_profile.dart';

class ContactsController extends GetxController {
  /// 好友列表(已分组排序)
//  List<ContactGroup> friendGroupList = [];

  // EVENT_BUS
  EventBus eventBus = EventBus();
  StreamSubscription? subscription;

  ContactsController();

  _initData() async {
    subscription = EventBusUtils.shared.on<RefreshContactsEvent>().listen((event) {
      print('收到刷新事件');
      update(["contacts"]);
    });

    update(["contacts"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  void refreshFriendList() async{
    await ContactsManager.refreshFriendList();
    update(["contacts"]);
  }

  /// 点击添加好友
  void onTapAddFriend() {
    Get.toNamed(RouteNames.contactsContactsAddFriend);
  }

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

  /// 点击联系人
  void onTapContact(FriendListItemModel userModel) {
    //Get.toNamed(RouteNames.chat, arguments: {'chat_person': userModel});

    UserInfoBasic user = UserInfoBasic();
    user.targetUid = userModel.uid;
    user.source = userModel.source;
    user.remark = userModel.remark;
    user.customField = userModel.custom_field;
    user.pinYin = userModel.pinYin;
    user.relation = userModel.relation;

    user.userProfile = UserProfile();
    user.userProfile?.nickname = userModel.user_profile?.nickname;
    user.userProfile?.avatar = userModel.user_profile?.avatar;
    user.userProfile?.role = userModel.user_profile?.role;
    user.userProfile?.customField = userModel.user_profile?.custom_field;

    Get.toNamed(
      RouteNames.contactsContactsUserDetail, //UserInfoBasic
      arguments: {
        'userInfo': user,
        'source': 1, //好友来源 1搜索添加 2二维码 3群聊
        'username': userModel.user_profile?.username ?? '',
      },
    );
  }

  /// 点击新朋友
  void onTapNewFriends() {
    Get.toNamed(RouteNames.contactsContactsFriendApplyList);
  }

  /// 点击我的群组
  void onTapMyGroup() {
    Get.toNamed(RouteNames.groupMyGroup);
  }
}
