import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/im_client.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class ChatController extends GetxController {
  // 聊天对象
  ConversationModel? chatConversation;
  MessageStreamModel messageStreamModel = MessageStreamModel();
  StreamSubscription? subscription;

  ScrollController scrollController = ScrollController();

  int convesationType = 0; //1 单聊 2 群聊
  int conversationId = 0; // 单聊时为聊天对象ID， 群聊时为群ID

  ChatController();

  _initData() {
    chatConversation = Get.arguments['chat_conversation'];
    if (chatConversation == null) {
      GroupProfile? chatGroup = Get.arguments['chat_group'];
      if (chatGroup != null) {
        chatConversation = ConversationModel(group_profile: chatGroup);
      } else {
        FriendListItemModel? chatPerson = Get.arguments['chat_person'];
        ConversationFriendModel friendModel =
            ConversationFriendModel.from(chatPerson);

        chatConversation = ConversationModel(friend_profile: friendModel);
      }
    }

//    int convesationType;
//    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      chatConversation!.group_profile = GroupManager.groupInfo(chatConversation!.group_profile!.groupId!);
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    loadMoreMessage();
    ImClient.getInstance().getPinnedMessageList(convesationType, conversationId);

    //groupNotice();

    update(["chat"]);

    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      if (event.groupId != (chatConversation?.group_profile?.groupId ?? 0)) {
        return;
      }
      update(["chat"]);
    });
  }

  /// 获取公告内容
  String groupNotice() {
    if (convesationType != 2) {
      return '';
    }
    GroupProfile? group =
        GroupManager.groupInfo(chatConversation?.group_id ?? 0);
    return group?.notice ?? '';
  }

  /// 导航右上角点击
  void onNaviRightTapped() {
    if (convesationType == 1) {
      //单聊
      Get.toNamed(
        RouteNames.chatChatDetail,
        arguments: {
          //'conversavtionModel': chatConversation,
          'conversationID': conversationId,
        },
      );
    } else if (convesationType == 2) {
      //群聊,从GroupManager中取一下，直接使用CONVERSATION中的，会缺少群成员数据
      int? groupID = chatConversation?.group_profile?.groupId;
      if (groupID == null) {
        return;
      }

      GroupProfile? chatGroup = GroupManager.groupInfo(groupID);
      if (chatGroup != null) {
        Get.toNamed(
          RouteNames.groupMyGroupDetail,
          arguments: {
            'groupProfile': chatGroup,
          },
        );
      }
    }
  }

  void messageReaded(List<MessageModel> messages) {
    List<String> messageIds = [];
    int selfId = UserService.to.profile.user_id!;
    for (MessageModel messageModel in messages) {
      if (messageModel.message_id != null && messageModel.from_uid != selfId) {
        int index = messageModel.read_user_ids!
            .indexWhere((element) => element.user_id == selfId);
        if (index < 0) {
          messageIds.add(messageModel.message_id!);
        }
      }
    }
    if (messageIds.length > 0) {
      int conversationId = chatConversation?.friend_profile?.uid ??
          (chatConversation?.group_profile?.groupId ?? 0);
      ImClient.getInstance().setMessageRead(conversationId, messageIds,true);
    }
  }

  void loadMoreMessage() {
    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }

    messageStreamModel = ImClient.getInstance().getChatMessage(
        convesationType, conversationId, messageStreamModel?.last_msg_id);
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
    super.onClose();

    if (!messageStreamModel.hasSendingMessage())
      ImClient.getInstance().removeChatMessage(messageStreamModel);

    subscription?.cancel();
  }

  void onTapNotice() {
    GroupProfile? group =
        GroupManager.groupInfo(chatConversation?.group_id ?? 0);
    if (group != null) {
      Get.toNamed(RouteNames.groupMyGroupShowGroupNotice, arguments: {
        'groupProfile': group!,
      });
    }
  }

  void onTapPinned() {
    Get.toNamed(RouteNames.chatPinned, arguments: {
      'chat_conversation': chatConversation,
    });
  }
}
