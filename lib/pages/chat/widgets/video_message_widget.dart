import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'message_widget_mixin.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

class VideoMessageWidget extends StatefulWidget{
  MessageModel messageModel;
  ConversationModel conversationModel;
  MessageStreamModel messageStreamModel;
  VideoMessageWidget(this.messageModel,this.conversationModel,this.messageStreamModel);

  @override
  State<VideoMessageWidget> createState() => VideoMessageState();
}

class VideoMessageState extends State<VideoMessageWidget>
    with MessageWidgetMixin {

  @override
  Widget build(BuildContext context) {
    int? selfId = UserService.to.profile?.user_id;
    String? attachment = widget.messageModel.msg_body?.attachment;
    ImageProvider thumbImage;
    if(attachment != null){
      int pos = attachment.indexOf(',');
      attachment = attachment.substring(pos+1);
      thumbImage = MemoryImage(base64Decode(attachment!));

    }else{
      thumbImage = AssetImage("assets/images/default_video.png");
    }
    double aspectRatio = 4/3.0;
    if(widget.messageModel.msg_body?.width !=null && widget.messageModel.msg_body?.height != null)
      aspectRatio = widget.messageModel.msg_body!.width!/(widget.messageModel.msg_body!.height!) ;

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
                    margin: EdgeInsets.only(
                        top: 5, bottom: 5, left: 40.w),
                    child:Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(widget.messageModel.message_id==null)
                            if(widget.messageModel.status == MessageStatus.failure.number)
                              IconWidget.icon(Icons.error,color: Colors.red,)
                            else
                              CircularProgressIndicator(),
                          if(widget.messageModel.message_id==null)
                            Gap(AppSpace.listRow),
                          // VideoBox(
                          //   videoPath: messageModel.msg_body!.url!,
                          //   backgroundColor: AppColors.primary,
                          //   autoPlaying: false,
                          //   aspectRatio: aspectRatio,
                          // ).expanded(),
                          GestureDetector(
                            child:Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.image),
                                ),
                                image: DecorationImage(
                                    image: thumbImage,
                                    fit: BoxFit.fill
                                ),
                                color:Colors.black12,
                              ),
                              width : 200,
                              height: 200/aspectRatio,
                              child: Icon(Icons.play_circle_outline,color: Colors.white,),
                            ),
                            onTap: (){
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  enableDrag: false,
                                  context: context,
                                  builder: (ctx) => FullScreenPlayVideoBox(
                                      videoPath: widget.messageModel.msg_body!.url!,
                                      aspectRatio:aspectRatio,
                                      ));
                            },
                          ),


                        ]
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
                  //borderRadius不起作用
                  //decoration: BoxDecoration(
                  //  borderRadius: BorderRadius.circular(10.0),
                  //),
                  // child: VideoBox(
                  //   videoPath: messageModel.msg_body!.url!,
                  //   backgroundColor: Colors.grey,
                  //   autoPlaying: false,
                  //   aspectRatio: aspectRatio,
                  // ),
                  child: GestureDetector(
                    child:Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.image),
                        ),
                        image: DecorationImage(
                            image: thumbImage,
                            fit: BoxFit.fill
                        ),
                        color:Colors.black12,
                      ),
                      width : 200,
                      height: 200/aspectRatio,
                      child: Icon(Icons.play_circle_outline,color: Colors.white,),
                    ),
                    onTap: (){
                      showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: false,
                          context: context,
                          builder: (ctx) => FullScreenPlayVideoBox(
                            videoPath: widget.messageModel.msg_body!.url!,
                            aspectRatio:aspectRatio,
                          ));
                    },
                  ),
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