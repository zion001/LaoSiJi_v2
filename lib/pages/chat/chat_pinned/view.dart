import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';
import '../widgets/text_message_widget.dart';
import '../widgets/image_message_widget.dart';
import '../widgets/file_message_widget.dart';
import '../widgets/video_message_widget.dart';
import '../widgets/audio_message_widget.dart';
import '../widgets/card_message_widget.dart';
import '../widgets/date_message_widget.dart';

class ChatPinnedPage extends GetView<ChatPinnedController> {
  const ChatPinnedPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    final list = StreamBuilder<List<MessageModel>>(
        stream: controller.messageStreamModel.getPinnedMessages(),
        builder: (c, snapshot) {
          List<MessageModel> dataList = [];
          if (snapshot.hasData) {
            dataList = snapshot.data as List<MessageModel>;

          }

          return  ListView.separated(
                  itemCount: dataList.length ?? 0,
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                    ).padding(top:5,bottom: 5);
                  },
                  itemBuilder: (context, index) {
                    if (dataList[index].msg_body?.msg_type == 'image')
                      return ImageMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                    else if (dataList[index].msg_body?.msg_type == 'video')
                      return VideoMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                    else if (dataList[index].msg_body?.msg_type == 'audio')
                      return AudioMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                    else if (dataList[index].msg_body?.msg_type == 'file')
                      return FileMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                    else if (dataList[index].msg_body?.msg_type == 'card')
                      return CardMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                    else if (dataList[index].msg_body?.msg_type == 'date')
                      return DateMessageWidget(dataList[index]);
                    else
                      return TextMessageWidget(
                          dataList[index], controller.chatConversation!,controller.messageStreamModel);
                  }
             );
        });

    return list.padding(left: 10, top:10, right: 10,bottom: 10);
  }



  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatPinnedController>(
      init: ChatPinnedController(),
      id: "chat_pinned",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '置顶消息',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
