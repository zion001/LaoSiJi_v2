import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:get/get.dart';

import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/im_client.dart';
import 'package:im_flutter/common/mqtt/connection_state_model.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ConversationsController extends GetxController {
  Stream<List<ConversationModel>> conversationStream =
      ImClient.getInstance().conversationStreamModel.getConversations();

  // 弹出菜单
  CustomPopupMenuController menuController = CustomPopupMenuController();

  ConversationsController();

  _initData() {
    update(["conversations"]);
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

  void onRefresh() {

    if (ImClient.getInstance().getCurrentConnectionState().connectionState ==
        MqttConnectionState.connected)
      ImClient.getInstance().getConversationList();
    else if(ImClient.getInstance().getCurrentConnectionState().connectionState ==
        MqttConnectionState.faulted || ImClient.getInstance().getCurrentConnectionState().connectionState ==
        MqttConnectionState.disconnected) {
      ImClient.getInstance().connect(
          UserService.to.profile?.user_id?.toString() ?? '',
          UserService.to.token,
          UserService.to.loginId).then((value) {
        ImClient.getInstance().getConversationList();
        //获取群数据（断线重连后，可能还需要）
        GroupManager.refreshAllGroup();
        //获取联系人数据（断线重连后，可能还需要）
        ContactsManager.refreshFriendList();
        //获取好友申请列表数据（断线重连后，可能还需要）
        FriendApplyManager.refreshFriendApplyLis();
      });
    }
  }

  /// 点击会话
  void onTapConversation(ConversationModel? conversationModel) {
    Get.toNamed(RouteNames.chat,
        arguments: {'chat_conversation': conversationModel});
  }

  /// 发起群聊
  void onTapCreatGroup() {
    menuController.hideMenu();
    Get.toNamed(
      RouteNames.contactsContactsSelectContacts,
      arguments: {
        'operation': 1,
        'title': '创建群聊',
        'allUsersData': ContactsManager.friendGroupList,
        'notAllowedUsers': <int>[], //发起群聊时，无不可用人员
        'groupID': 0, // 拉人T人时需要
      },
    );
  }

  /// 添加好友
  void onTapAddFriend() {
    menuController.hideMenu();
    Get.toNamed(RouteNames.contactsContactsAddFriend);
  }

  /// 扫一扫
  void onTapScan() {
    menuController.hideMenu();
    //Loading.toast('扫一扫');
    Get.toNamed(RouteNames.systemQrcodeScanner);
  }
}
