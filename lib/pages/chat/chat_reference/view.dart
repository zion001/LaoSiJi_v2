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

class ChatReferencePage extends GetView<ChatReferenceController> {
  const ChatReferencePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    Widget messageWidget;
    if (controller.messageModel?.msg_body?.msg_type == 'image')
      messageWidget = ImageMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else if (controller.messageModel?.msg_body?.msg_type == 'video')
      messageWidget = VideoMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else if (controller.messageModel?.msg_body?.msg_type == 'audio')
      messageWidget = AudioMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else if (controller.messageModel?.msg_body?.msg_type == 'file')
      messageWidget = FileMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else if (controller.messageModel?.msg_body?.msg_type == 'card')
      messageWidget = CardMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else if (controller.messageModel?.msg_body?.msg_type == 'date')
      messageWidget = DateMessageWidget(controller.messageModel!);
    else if(controller.messageModel!=null)
      messageWidget = TextMessageWidget(
          controller.messageModel!, controller.chatConversation!,controller.messageStreamModel);
    else
      messageWidget = Container();


    return messageWidget.padding(left: 10, top:10, right: 10,bottom: 10);
  }



  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatReferenceController>(
      init: ChatReferenceController(),
      id: "chat_reference",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '消息',
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
