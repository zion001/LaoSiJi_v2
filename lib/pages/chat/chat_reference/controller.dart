import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

class ChatReferenceController extends GetxController {
  ConversationModel? chatConversation;
  MessageModel? messageModel;
  MessageStreamModel messageStreamModel = MessageStreamModel();

  ChatReferenceController();



  _initData() {
    chatConversation = Get.arguments['chat_conversation'];
    messageModel = Get.arguments['chat_message'];
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


      ImClient.getInstance().getMessageById(messageModel!.message_id!).then((value) {
        messageModel = value.content;
        update(["chat_reference"]);
      });

  }


  @override
  void onReady() {
    super.onReady();
    _initData();
  }

}
