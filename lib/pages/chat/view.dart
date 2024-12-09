import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:im_flutter/common/models/mqtt_model/msg_body_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/pages/chat/widgets/chat_input_widget/view.dart';
import 'package:marquee/marquee.dart';
import 'index.dart';

import 'widgets/text_message_widget.dart';
import 'widgets/image_message_widget.dart';
import 'widgets/file_message_widget.dart';
import 'widgets/video_message_widget.dart';
import 'widgets/audio_message_widget.dart';
import 'widgets/card_message_widget.dart';
import 'widgets/date_message_widget.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);


  // 主视图
  Widget _buildView() {
    final pinnedMsg = StreamBuilder<List<MessageModel>>(
        stream: controller.messageStreamModel.getPinnedMessages(),
        builder: (c, snapshot) {
          List<MessageModel> pinnedMessage = [];
          if (snapshot.hasData) {
            pinnedMessage = snapshot.data as List<MessageModel>;
          }
          if(pinnedMessage.length > 0) {
            MessageModel messageModel = pinnedMessage.first;
            return Container(
              height: 45.w,
              color: Colors.black12,
              padding: EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ImUtil.getMessageText(messageModel),
                    overflow: TextOverflow.ellipsis,).expanded(),
                  Image.asset('assets/images/pinned.png')
                ],
              ),

            ).onTap(() {
              controller.onTapPinned();
            });
          }else
            return Container();
        });


    final list = StreamBuilder<List<MessageModel>>(
        stream: controller.messageStreamModel.getMessages(),
        builder: (c, snapshot) {
          List<MessageModel> dataList = [];
          if (snapshot.hasData) {
            dataList = snapshot.data as List<MessageModel>;
            controller.messageReaded(dataList);
            dataList = addDateItem(dataList);
          }

          return EasyRefresh(
              onLoad: controller.messageStreamModel.hasMore
                  ? () async {
                      controller.loadMoreMessage();
                    }
                  : null,
              child: ListView.separated(
                  itemCount: dataList.length ?? 0,
                  controller: controller.scrollController,
                  reverse: true,
                  separatorBuilder: (context, index) {
                    return Gap(AppSpace.listRow);
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
                  })).padding(left: 10, right: 10);
        });

    // Future.delayed(Duration(milliseconds: 500), () {
    //   controller.scrollController.jumpTo(controller.scrollController.position.maxScrollExtent);
    // });
    return <Widget>[
      // controller.groupNotice() == ''
      //     ? Container()
      //     : Marquee(
      //         text: controller.groupNotice(),
      //         blankSpace: 20.w,
      //       ).tight(height: 45.w).backgroundColor(Colors.black12).onTap(() {
      //         controller.onTapNotice();
      //       }),
      pinnedMsg,
      list.expanded(),
      ChatInputWidgetPage(
          controller.chatConversation, controller.scrollController,controller.messageStreamModel),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  List<MessageModel> addDateItem(List<MessageModel> messages) {
    List<MessageModel> newMessages = [];
    String? prevDay;
    for (MessageModel messageModel in messages) {
      DateTime createAt =
          DateTime.fromMillisecondsSinceEpoch(messageModel.created_at ?? 0);
      String createDay = DateFormat('yyyy.M.d').format(createAt);
      if (prevDay != null && createDay != prevDay) {
        MessageModel dateModel = MessageModel(
          msg_body: MsgBodyModel(msg_type: "date", text: prevDay),
        );
        newMessages.add(dateModel);
      }
      prevDay = createDay;

      newMessages.add(messageModel);
    }
    if (prevDay != null) {
      MessageModel dateModel = MessageModel(
        msg_body: MsgBodyModel(msg_type: "date", text: prevDay),
      );
      newMessages.add(dateModel);
    }

    return newMessages;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: ChatController(),
      id: "chat",
      builder: (_) {
        String notice = controller.groupNotice();
        if(notice.isNotEmpty){
          String groupId = controller.chatConversation!.group_id!.toString();
          String savedNotice = groupId +':'+notice;
          List<String> showedList = Storage().getList(Constants.storageShowNotice);
          if(!showedList.contains(savedNotice)) {
            for(int i=0;i<showedList.length;i++){
              String showedNotice = showedList[i];
              List splited = showedNotice.split(':');
              if(splited.length>0 && splited.first == groupId){
                showedList[i] = savedNotice;
                savedNotice = '';
                break;
              }
            }
            if(savedNotice!='')
              showedList.add(savedNotice);
            Storage().setList(Constants.storageShowNotice,showedList);
            Future.delayed(Duration(milliseconds: 100), () {
              showDialog(
                  context: context, //MyComponent
                  builder: (BuildContext context) {
                    return SimpleDialog(
                        title: Text('群公告'),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(notice),
                          ),
                          SimpleDialogOption(
                              child: TextButton(

                                child: Text("确定"),
                                onPressed: () =>
                                {

                                  Navigator.of(context).pop('YES') //关闭弹框
                                },
                              )
                          )
                        ]
                    );
                  }
              );
            });
          }
        }
        int groupMemberCount = controller.chatConversation?.group_profile?.members.length ?? 0;
        return Scaffold(
          appBar: MyAppBar(
            context,
            controller.chatConversation?.friend_profile?.nickname ??
                "${(controller.chatConversation?.group_profile?.title ?? '')}($groupMemberCount)",
            actions: IconWidget.icon(
              Icons.info_outline,
              color: AppColors.onPrimary,
            ),
            rightCallback: controller.onNaviRightTapped,
          ),
          body: SafeArea(
            child: _buildView().gestures(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            ),
          ),
        );
      },
    );
  }
}
