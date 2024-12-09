import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/user_info_basic/user_profile.dart';

class ChatDetailController extends GetxController {
  ConversationModel?
      conversationModel; // = Get.arguments['conversavtionModel'];
  int conversationID = Get.arguments['conversationID'];

  _initData() {
    conversationModel =
        ConversationManager.getConversationModel(conversationID);
    update(["chat_detail"]);
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

  /// 置顶聊天
  void onTapPin(bool value) {
    if (conversationModel == null) {
      return;
    }
    var sessionId =
        conversationModel!.target_uid ?? conversationModel!.group_id;
    ConversationManager.setSessionPinned(
        conversationModel!.session_type!, sessionId!, value);

    conversationModel?.is_pinned = value;
    update(["chat_detail"]);
  }

  /// 清空聊天记录
  ///
  void clearHistoryMessage() {
    ImDialog.confirmDialog('提示', '清空聊天记录?', () async{
      int conversationType = 1;
      int sessionId = conversationModel!.target_uid!;
      PayloadModel payloadModel = await ConversationManager.clearHistoryMessage(conversationType, sessionId);
      if(payloadModel.error_code == 0) {
        Loading.success('已清空聊天记录');
      }else{
        Loading.error(payloadModel.error_msg);
      }
    });
  }

  /// 点击头像-》进入用户信息页
  void onTapAvatar() {
    FriendListItemModel? userModel =
        ContactsManager.getFriend(conversationModel?.friend_profile?.uid ?? 0);
    if (userModel == null) {
      return;
    }

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
}
