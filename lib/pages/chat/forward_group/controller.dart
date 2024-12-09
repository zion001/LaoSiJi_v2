import 'package:get/get.dart';
import 'package:im_flutter/common/api/group_api.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:uuid/uuid.dart';

class ForwardGroupController extends GetxController {
  ForwardGroupController();
  MessageModel? messageModel;
  _initData() {
    messageModel = Get.arguments['message_model'];
    update(["forward_group"]);
  }

/*
  Future<void> refreshGroupList() async {
    groupList = GroupManager.groupList;
   // groupList = await GroupApi.groupList();
    update(["mygroup"]);
  }
  */

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

  void onTabGroupListItem(GroupProfile group) async{
    int convesationType = 2;
    int conversationId = group.groupId!;

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
    Get.back();
  }
}
