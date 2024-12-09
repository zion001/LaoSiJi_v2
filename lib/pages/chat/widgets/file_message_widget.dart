import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'message_widget_mixin.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

class FileMessageWidget extends StatefulWidget {
  MessageModel messageModel;
  ConversationModel conversationModel;
  MessageStreamModel messageStreamModel;
  FileMessageWidget(this.messageModel, this.conversationModel,this.messageStreamModel);

  @override
  State<FileMessageWidget> createState() => FileMessageState();
}

class FileMessageState extends State<FileMessageWidget>
    with MessageWidgetMixin {

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
                        if (widget.messageModel.status == MessageStatus.failure.number)
                          IconWidget.icon(
                            Icons.error,
                            color: Colors.red,
                          )
                        else
                          CircularProgressIndicator(),
                      if (widget.messageModel.message_id == null)
                        Gap(AppSpace.listRow),
                      GestureDetector(
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
                          child: Row(
                            //mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconWidget.icon(
                                Icons.attach_file,
                                color: Colors.white,
                              ),
                              TextWidget.body1(
                                  widget.messageModel.msg_body?.file_name ?? '',
                                  color: Colors.white,
                                  maxLines: null,
                                  softWrap: true).expanded(),
                            ],
                          ),
                        ),
                        onTap: () async {
                          List pathSplit =
                              widget.messageModel.msg_body!.url!.split('/') ?? [];
                          String fileName = pathSplit.last;
                          String filepath =
                              (await getTemporaryDirectory()).path +
                                  '/' +
                                  fileName;

                          if (!(await File(filepath).exists())) {
                            var dio = Dio();
                            try {
                              Loading.show();
                              Response response = await dio.download(
                                  widget.messageModel.msg_body!.url!, filepath,
                                  onReceiveProgress: (int count, int total) {
                                print(
                                    count.toString() + ":" + total.toString());
                              });

                              // Response response = await dio.get(messageModel.msg_body!.url!);
                              // File file = File(filepath);
                              // file.writeAsBytesSync(response.data);

                              Loading.dismiss();
                              if (response == null) {
                                return;
                              }
                            } catch (err) {
                              Loading.dismiss();
                              print(widget.messageModel.msg_body!.url!);
                              print(err);
                              return;
                            }
                          }

                          OpenResult openResult =
                              await OpenFilex.open(filepath);
                          if (openResult.type != ResultType.done) {
                            Loading.toast(openResult.message);
                          }

                          //launchUrl(Uri.parse(messageModel.msg_body!.url!));
                        },
                      ).expanded(),
                    ]),
                  ),
                ),
                menuBuilder: () {
                  return buildLongPressMenu(widget.messageModel, widget.conversationModel,widget.messageStreamModel);
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
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconWidget.icon(
                            Icons.attach_file,
                            color: Colors.black,
                          ),
                          TextWidget.body1(
                              widget.messageModel.msg_body?.file_name ?? '',
                              color: Colors.black,
                              maxLines: null,
                              softWrap: true).expanded(),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    String filepath = (await getTemporaryDirectory()).path +
                        '/' +
                        widget.messageModel.msg_body!.file_name!;

                    if (!(await File(filepath).exists())) {
                      var dio = Dio();
                      try {
                        Loading.show();
                        Response response = await dio
                            .download(widget.messageModel.msg_body!.url!, filepath,
                                onReceiveProgress: (int count, int total) {
                          print(count.toString() + ":" + total.toString());
                        });

                        // Response response = await dio.get(messageModel.msg_body!.url!);
                        // File file = File(filepath);
                        // file.writeAsBytesSync(response.data);

                        Loading.dismiss();
                        if (response == null) {
                          return;
                        }
                      } catch (err) {
                        Loading.dismiss();
                        print(widget.messageModel.msg_body!.url!);
                        print(err);
                        return;
                      }
                    }

                    OpenResult openResult = await OpenFilex.open(filepath);
                    if (openResult.type != ResultType.done) {
                      Loading.toast(openResult.message);
                    }
                    //launchUrl(Uri.parse(messageModel.msg_body!.url!));
                  },
                ),
                menuBuilder: () {
                  return buildLongPressMenu(widget.messageModel, widget.conversationModel,widget.messageStreamModel);
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
