import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:uuid/uuid.dart';

class ForwardContactController extends GetxController {
  ForwardContactController();
  TextEditingController searchController = TextEditingController();
  MessageModel? messageModel;

  _initData() async {
    messageModel = Get.arguments['message_model'];
    update(["forward_contact"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void searchChanged(String searchWord) {
    update(["forward_contact"]);
  }

  /// 点击联系人
  void onTapContact(FriendListItemModel friend) async{
    int convesationType = 1;
    int conversationId = friend.uid!;

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
    Get.back();
  }

  void onTapGroup() {
    Get.toNamed(RouteNames.forwardGroup,
        arguments: {'message_model': messageModel});
  }
}
