import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:uuid/uuid.dart';

class ForwardConversationController extends GetxController {
  ForwardConversationController();

  TextEditingController searchController = TextEditingController();
  MessageModel? messageModel;

  _initData() {
    messageModel = Get.arguments['message_model'];
    update(["forward_conversation"]);
  }

  List<ConversationModel> getConversationList() {
    List<ConversationModel> listConversation =
        ConversationManager.getConversationList();
    if (searchController.text.isNotEmpty) {
      listConversation = listConversation
          .where((element) =>
              (element.friend_profile?.nickname
                      ?.contains(searchController.text) ??
                  false) ||
              (element.group_profile?.title?.contains(searchController.text) ??
                  false))
          .toList();
    }
    return listConversation;
  }

  void searchChanged(String searchWord) {
    update(["forward_conversation"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void onTapConversation(ConversationModel? conversationModel) async{
    int convesationType;
    int conversationId;
    if (conversationModel?.friend_profile != null) {
      convesationType = 1;
      conversationId = conversationModel!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = conversationModel!.group_profile!.groupId!;
    }

    MsgBodyModel msgBodyModel = MsgBodyModel.copyFrom(messageModel?.msg_body);
    msgBodyModel.tmpKey = Uuid().v1();
    msgBodyModel.create_time = DateTime.now().millisecondsSinceEpoch;
    msgBodyModel.reply_message = null;
    PayloadModel payloadModel = await ImClient.getInstance().sendMessage(convesationType, conversationId,
        msgBodyModel: msgBodyModel);
    if((payloadModel.error_code??0) == 0)
      Loading.success('转发成功');
    else
      Loading.error(payloadModel.error_msg);

    Get.back();
  }

  void onTapNewConversation() {
    Get.toNamed(RouteNames.forwardContact,
        arguments: {'message_model': messageModel});
  }
}
