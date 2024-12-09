import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'message_widget_mixin.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/models/response_model/user_info_basic/user_profile.dart';

class CardMessageWidget extends StatefulWidget {
  MessageModel messageModel;
  ConversationModel conversationModel;
  MessageStreamModel messageStreamModel;
  CardMessageWidget(this.messageModel,this.conversationModel,this.messageStreamModel);
  @override
  State<CardMessageWidget> createState() => CardMessageState();
}

class CardMessageState extends State<CardMessageWidget>
    with MessageWidgetMixin {

  @override
  Widget build(BuildContext context) {
    int? selfId = UserService.to.profile?.user_id;
    String? attachment = widget.messageModel.msg_body?.attachment;
    if(attachment != null){
      int pos = attachment.indexOf(',');
      attachment = attachment.substring(pos+1);
    }
    Widget cardWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ImUtil.getAvatarWidget(widget.messageModel.msg_body?.user_info?.avatar).tightSize(40.w),
              Gap(10),
              TextWidget.title2(widget.messageModel.msg_body?.user_info?.nickname??''),
            ],
          ).paddingVertical(10),
          Divider(height: 10,thickness: 1),
          TextWidget.body2('个人名片'),
        ],
      ).tight(width: 200),
      onTap: () {
        UserInfoBasic user = UserInfoBasic();
        user.targetUid = widget.messageModel.msg_body?.user_info?.uid;
        FriendListItemModel? friendListItemModel = ContactsManager.getFriend(user.targetUid!);
        if(friendListItemModel!=null)
          user.relation = true;

        user.userProfile = UserProfile();
        user.userProfile?.nickname = widget.messageModel.msg_body?.user_info?.nickname;
        user.userProfile?.avatar = widget.messageModel.msg_body?.user_info?.avatar;

        Get.toNamed(
          RouteNames.contactsContactsUserDetail, //UserInfoBasic
          arguments: {
            'userInfo': user,
            'source': 4, //好友来源 1搜索添加 2二维码 3群聊 4名片
            'username': widget.messageModel.msg_body?.user_info?.username ?? '',
          },
        );
      },
    );
    if (widget.messageModel.from_uid == selfId) {
      UserProfileModel profile = UserService.to.profile;
      Widget avatar = ImUtil.getAvatarWidget(profile.avatar);
      String? nickname = profile.nickname;
      if ((widget.messageModel.group_id ?? 0) != 0) {
        GroupProfile? groupProfile =
        GroupManager.groupInfo(widget.messageModel.group_id!);
        if (groupProfile != null) {
          if (groupProfile?.selfInfo?.nick?.isNotEmpty??false) {
            nickname = groupProfile?.selfInfo?.nick;
          }
        }
      }
      String readStatus;
      if((widget.messageModel.group_id??0) != 0){
        readStatus = (widget.messageModel.read_user_ids?.length??0) > 0 ? '${widget.messageModel.read_user_ids!.length.toString()} 已读':'未读';
      }else{
        readStatus = (widget.messageModel.read_user_ids?.length??0) > 0 ? '已读':'未读';
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget.body2(nickname ?? ''),
              CustomPopupMenu(
                child: Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5, left: 40.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(widget.messageModel.message_id==null)
                          if(widget.messageModel.status == MessageStatus.failure.number)
                            IconWidget.icon(Icons.error,color: Colors.red,)
                          else
                            CircularProgressIndicator(),
                        if(widget.messageModel.message_id==null)
                          Gap(AppSpace.listRow),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: Colors.white,
                          ),
                          child: cardWidget,
                        ),
                      ],
                    )

                ),
                menuBuilder: (){
                  return buildLongPressMenu(widget.messageModel,widget.conversationModel,widget.messageStreamModel);
                },
                barrierColor: Colors.transparent,
                pressType: PressType.longPress,
                controller: menuController,
              ),

              if(widget.messageModel.created_at != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(widget.messageModel.message_id!=null)
                      TextWidget.body2(readStatus),
                    Gap(AppSpace.listRow),
                    TextWidget.body2(DateFormat('M-d HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            widget.messageModel.created_at ?? 0))),
                  ],
                ),
            ],
          ).expanded(),
          Gap(AppSpace.listRow),
          avatar.tightSize(40.w),
        ],
      );
    } else {
      String? avatarUrl;
      String? nickname;
      FriendListItemModel? userItemModel =
      ContactsManager.getFriend(widget.messageModel.from_uid!);
      avatarUrl = userItemModel?.user_profile?.avatar;
      nickname = (userItemModel?.remark == null || userItemModel!.remark!.isEmpty)
          ? userItemModel?.user_profile?.nickname
          : userItemModel?.remark;
      if ((widget.messageModel.group_id ?? 0) != 0) {
        GroupProfile? groupProfile =
        GroupManager.groupInfo(widget.messageModel.group_id!);
        if (groupProfile != null) {
          final foundPeople = groupProfile!.members!
              .where((element) =>
          element.userId == widget.messageModel.from_uid);
          if (foundPeople.isNotEmpty) {
            avatarUrl = foundPeople.first.avatar;
            if (foundPeople.first.nick?.isNotEmpty ?? false) {
              nickname = foundPeople.first.nick;
            } else if (userItemModel?.remark?.isNotEmpty ?? false) {
              nickname = userItemModel?.remark;
            } else {
              nickname = foundPeople.first.nickname;
            }
          }
        }
      }
      Widget avatar = ImUtil.getAvatarWidget(avatarUrl);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar.tightSize(40.w),
          Gap(AppSpace.listRow),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.body2(nickname ?? ''),
              CustomPopupMenu(
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5, right: 40.w),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                  child: cardWidget,
                ),
                menuBuilder: (){
                  return buildLongPressMenu(widget.messageModel,widget.conversationModel,widget.messageStreamModel);
                },
                barrierColor: Colors.transparent,
                pressType: PressType.longPress,
                controller: menuController,
              ),
              if(widget.messageModel.created_at != null)
                TextWidget.body2(DateFormat('M-d HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        widget.messageModel.created_at ?? 0))),
            ],
          ).expanded()
        ],
      );
    }
  }
}
