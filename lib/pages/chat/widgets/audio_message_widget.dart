import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_plugin_record_plus/const/play_state.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'message_widget_mixin.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

String currentSelectedMsgId = "";

class AudioMessageWidget extends StatefulWidget {
  MessageModel messageModel;
  ConversationModel conversationModel;
  MessageStreamModel messageStreamModel;

  AudioMessageWidget(this.messageModel, this.conversationModel,this.messageStreamModel);

  @override
  State<AudioMessageWidget> createState() => AudioMessageState();
}

class AudioMessageState extends State<AudioMessageWidget>
    with MessageWidgetMixin {
  final int charLen = 8;
  bool isPlaying = false;
  late StreamSubscription<Object> subscription;

  _playSound() async {
    if (!SoundPlayer.isInited) {
      // bool hasMicrophonePermission = await Permissions.checkPermission(
      //     context, Permission.microphone.value);
      // bool hasStoragePermission = Platform.isIOS ||
      //     await Permissions.checkPermission(context, Permission.storage.value);
      // if (!hasMicrophonePermission || !hasStoragePermission) {
      //   return;
      // }
      SoundPlayer.initSoundPlayer();
    }

    if (isPlaying) {
      SoundPlayer.stop();
      currentSelectedMsgId = "";
      setState(() {
        isPlaying = false;
      });
    } else {
      SoundPlayer.play(url: widget.messageModel.msg_body!.url!);
      currentSelectedMsgId = widget.messageModel.message_id!;
      setState(() {
        isPlaying = true;
      });
      // SoundPlayer.setSoundInterruptListener(() {
      //   // setState(() {
      //   isPlaying = false;
      //   // });
      // });
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      isPlaying = currentSelectedMsgId != '' &&
          currentSelectedMsgId == widget.messageModel.message_id;
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = SoundPlayer.playStateListener(listener: (PlayState data) {
      if (data.playState == 'complete') {
        currentSelectedMsgId = "";
        setState(() {
          isPlaying = false;
        });
        // SoundPlayer.removeSoundInterruptListener();
      }
    });
  }

  @override
  void dispose() {
    if (isPlaying) {
      SoundPlayer.stop();
      currentSelectedMsgId = "";
    }
    subscription?.cancel();
    super.dispose();
  }

  double _getSoundLen() {
    double soundLen = 32;
    if (widget.messageModel.msg_body?.duration != null) {
      final realSoundLen = widget.messageModel.msg_body!.duration!;
      int sdLen = 32;
      if (realSoundLen > 10) {
        sdLen = 12 * charLen + ((realSoundLen - 10) * charLen / 0.5).floor();
      } else if (realSoundLen > 2) {
        sdLen = 2 * charLen + (realSoundLen * charLen).floor();
      }
      sdLen = min(sdLen, 20 * charLen);
      soundLen = sdLen.toDouble();
    }

    return soundLen;
  }

  @override
  Widget build(BuildContext context) {
    int? selfId = UserService.to.profile?.user_id;

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
      if ((widget.messageModel.group_id ?? 0) != 0) {
        readStatus = (widget.messageModel.read_user_ids?.length ?? 0) > 0
            ? '${widget.messageModel.read_user_ids!.length.toString()} 已读'
            : '未读';
      } else {
        readStatus =
            (widget.messageModel.read_user_ids?.length ?? 0) > 0 ? '已读' : '未读';
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
                    child: IntrinsicWidth(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.messageModel.message_id == null)
                        if (widget.messageModel.status ==
                            MessageStatus.failure.number)
                          IconWidget.icon(
                            Icons.error,
                            color: Colors.red,
                          )
                        else
                          CircularProgressIndicator(),
                      if (widget.messageModel.message_id == null)
                        Gap(AppSpace.listRow),
                      GestureDetector(
                        onTap: _playSound,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: AppColors.primary,
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: _getSoundLen()),
                            TextWidget.body1(
                              "${widget.messageModel.msg_body?.duration?.toString() ?? ''} ",
                              color: Colors.white,
                            ),
                            isPlaying
                                ? Image.asset(
                                    'assets/images/play_voice_send.gif',
                                    width: 24,
                                    height: 24,
                                  )
                                : Image.asset(
                                    'assets/images/voice_send.png',
                                    width: 24,
                                    height: 24,
                                  ),
                          ]),
                        ),
                      ),
                    ]))),
                menuBuilder: () {
                  return buildLongPressMenu(
                      widget.messageModel, widget.conversationModel,widget.messageStreamModel);
                },
                barrierColor: Colors.transparent,
                pressType: PressType.longPress,
                controller: menuController,
              ),
              if(widget.messageModel.created_at != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.messageModel.message_id != null)
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
                child: GestureDetector(
                  onTap: _playSound,
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
                      color: Colors.grey,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isPlaying
                            ? Image.asset(
                                'assets/images/play_voice_receive.gif',
                                width: 24,
                                height: 24,
                              )
                            : Image.asset(
                                'assets/images/voice_receive.png',
                                width: 24,
                                height: 24,
                              ),
                        TextWidget.body1(
                            " ${widget.messageModel.msg_body?.duration?.toString() ?? ''}"),
                        Container(width: _getSoundLen()),
                      ],
                    ),
                  ),
                ),
                menuBuilder: () {
                  return buildLongPressMenu(
                      widget.messageModel, widget.conversationModel,widget.messageStreamModel);
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
