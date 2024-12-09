import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:im_flutter/common/index.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}

mixin MessageWidgetMixin {
  CustomPopupMenuController menuController = CustomPopupMenuController();
  List<ItemModel> menuItems = [
    //ItemModel('复制', Icons.content_copy),
    ItemModel('回复', Icons.question_answer),
    ItemModel('转发', Icons.send),
    //ItemModel('收藏', Icons.collections),
    ItemModel('删除', Icons.delete),
    //ItemModel('多选', Icons.playlist_add_check),
    //ItemModel('置顶', Icons.vertical_align_top),
  ];

  Widget buildLongPressMenu(
      MessageModel messageModel, ConversationModel conversationModel,MessageStreamModel messageStreamModel) {
    List<ItemModel> addedMenuItems = []..addAll(menuItems);
    List<MessageModel>? pinnedMessage = messageStreamModel.getPinnedMessages().valueOrNull;
    if( UserService.to.profile.isSystemUser() ) {
      int index = -1;
      if (pinnedMessage != null)
        index = pinnedMessage.indexWhere((element) => element.message_id ==
            messageModel.message_id);
      if (index >= 0) {
        addedMenuItems.add(ItemModel('不置顶', Icons.vertical_align_bottom));
      } else {
        addedMenuItems.add(ItemModel('置顶', Icons.vertical_align_top));
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        //width: 220,
        width: addedMenuItems.length * 40 + 20,
        color: const Color(0xFF4C4C4C),
        child: GridView.count(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          //crossAxisCount: 5,
          crossAxisCount: addedMenuItems.length,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: addedMenuItems
              .map((item) => GestureDetector(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          item.icon,
                          size: 20,
                          color: Colors.white,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Text(
                            item.title,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      menuController.hideMenu();

                      if (item.title == '复制') {
                        Clipboard.setData(ClipboardData(
                            text: messageModel.msg_body?.text ?? ''));
                      }else if(item.title == '编辑'){
                        messageStreamModel.editMessage(messageModel);
                      }else if(item.title == '回复'){
                        messageStreamModel.replyMessage(messageModel);
                      } else if (item.title == '转发') {
                        Get.toNamed(RouteNames.forwardConversation,
                            arguments: {'message_model': messageModel});
                      } else if (item.title == '删除') {
                        if( UserService.to.profile.isSystemUser() )
                          ImDialog.confirmDialog('双向删除', '为所有人删除此消息？', () {
                            ImClient.getInstance().deleteMessage(
                                conversationModel.session_id!,
                                messageModel.message_id!,true);
                          });
                        else
                          ImDialog.confirmDialog('提示', '删除此消息？', () {
                            ImClient.getInstance().deleteMessage(
                                conversationModel.session_id!,
                                messageModel.message_id!,false);
                          });
                      }else if (item.title == '置顶') {
                        ImClient.getInstance().setMessagePinned(
                            messageModel.message_id!,true);
                      }else if (item.title == '不置顶') {
                        ImClient.getInstance().setMessagePinned(
                            messageModel.message_id!,false);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
