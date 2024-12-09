import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

class ChatPinnedController extends GetxController {
  ConversationModel? chatConversation;
  MessageStreamModel messageStreamModel = MessageStreamModel();

  ChatPinnedController();



  _initData() {
    chatConversation = Get.arguments['chat_conversation'];
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
        convesationType, conversationId, null);

    update(["chat_pinned"]);
  }


  @override
  void onReady() {
    super.onReady();
    _initData();
  }

}
