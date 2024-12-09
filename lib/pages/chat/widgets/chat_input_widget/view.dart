import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'index.dart';
import 'voice_input_widget.dart';

class ChatInputWidgetPage extends GetView<ChatInputWidgetController> {
  // 聊天对象
  final ConversationModel? chatConversation;
  final ScrollController scrollController;
  final MessageStreamModel messageStreamModel;

  const ChatInputWidgetPage(this.chatConversation, this.scrollController,this.messageStreamModel, {Key? key})
      : super(key: key);

  // 主视图
  Widget _buildView(BuildContext context) {
    var refMessage = StreamBuilder<MessageModel?>(
        stream: messageStreamModel.getEditMessage(),
        builder: (c, snapshot) {
          if (snapshot.hasData) {
            MessageModel? refMessage = snapshot.data as MessageModel;
            int? selfId = UserService.to.profile?.user_id;

            String? nickname;
            if (refMessage.from_uid == selfId) {
              UserProfileModel profile = UserService.to.profile;
              nickname = profile.nickname;
            }else {
              if ((refMessage.group_id ?? 0) == 0) {
                FriendListItemModel? userItemModel =
                ContactsManager.getFriend(refMessage.from_uid!);
                nickname = userItemModel?.user_profile?.nickname;
              } else {
                GroupProfile? groupProfile =
                GroupManager.groupInfo(refMessage.group_id!);
                if (groupProfile != null) {
                  final foundPeople = groupProfile!.members!
                      .where((element) =>
                  element.userId == refMessage.from_uid);
                  if (foundPeople.isNotEmpty) {
                    nickname = foundPeople.first.nickname;
                  }
                }
              }
            }
            return Container(
              height: 45.w,
              color: Colors.black12,
              padding: EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconWidget.icon(Icons.edit),
                  Gap(AppSpace.button),
                  Text((nickname??'') + ':'),
                  Text(ImUtil.getMessageText(refMessage),
                    overflow: TextOverflow.ellipsis,).expanded(),
                  IconButton(
                      onPressed: (){
                        messageStreamModel.editMessage(null);
                      },
                      icon: Icon(Icons.close),
                  ),
                ],
              ),

            );

          }
          return Container();
        }
    );
    String buttonString = ((1==null)?"发送":"编辑");
    var topWidgets = !controller.isMuted ? <Widget>[
        // 语音图标
        Obx(()=>
            GestureDetector(
              onTap: controller.onTapMic,
              child: Icon(controller.isVoiceInput.value?Icons.keyboard_alt_outlined:Icons.mic_rounded).paddingOnly(left:10,right:10),
            )
        ),
        Obx((){
          if(controller.isVoiceInput.value)
            return VoiceInputWidget(
                startRecord: controller.startRecord,
                stopRecord: controller.stopRecord,
              ).expanded();
          else
            // 文本输入框
            return inputTf(context).marginSymmetric(vertical: 5.w).expanded();
        }),
        // 表情图标
        ButtonWidget.icon(
            IconWidget.icon(
              Icons.emoji_emotions_outlined,
              size: 40.w,
            ), onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          controller.onTapEmoji();
        }),
        // 更多功能
        if (controller.inputTextFieldController.text.isEmpty)
          ButtonWidget.icon(
              IconWidget.icon(
                Icons.add_box_outlined,
                size: 40.w,
              ), onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            controller.onTapMore();
          })
        else
          TextButton(
              onPressed: () {
                controller.onTapSend();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              child: TextWidget.title2(
                (controller.isEdit)?"编辑":"发送",
                color: Colors.white,
              )).paddingRight(10),
      ].toRow().alignCenter().backgroundColor(AppColors.onSecondary)
      : TextWidget.body1('禁言').center().tight(height: 50.w).backgroundColor(Colors.black12);

    return <Widget>[
      refMessage,
      topWidgets,
      // 下方其它类型输入面板
      if (controller.showMore)
        Container(
          // 此处可以考虑添加动画，减轻抖动。
          child: GridView.count(
            padding: EdgeInsets.all(10),
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 60/80,//
            /// 指定显示的 List<Widget>
            children:  [
              TextButton(
                  onPressed: () {
                    controller.choosePhoto(ImageSource.gallery);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.photo,color: AppColors.secondary,),
                      ),
                      SizedBox(height: 10,),
                      Text('相册',style: TextStyle(color: AppColors.secondary),)
                    ],
                  )

              ),
              TextButton(
                  onPressed: () {
                    controller.choosePhoto(ImageSource.camera);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.camera_alt,color: AppColors.secondary,),
                      ),
                      SizedBox(height: 10,),
                      Text('拍照',style: TextStyle(color: AppColors.secondary),)
                    ],
                  )
              ),
              TextButton(
                  onPressed: () {
                    controller.chooseVideo(ImageSource.gallery);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.video_collection,color: AppColors.secondary,),
                      ),
                      SizedBox(height: 10,),
                      Text('视频',style: TextStyle(color: AppColors.secondary),)
                    ],
                  )
              ),
              TextButton(
                  onPressed: () {
                    controller.chooseVideo(ImageSource.camera);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.video_camera_front_outlined,color: AppColors.secondary,),
                      ),
                      SizedBox(height: 10,),
                      Text('录像',style: TextStyle(color: AppColors.secondary),)
                    ],
                  )
              ),
              TextButton(
                  onPressed: () {
                    controller.chooseFile();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.file_copy,color: AppColors.secondary,),
                      ),
                      SizedBox(height: 10,),
                      Text('文件',style: TextStyle(color: AppColors.secondary),)
                    ],
                  )
              ),
              if(UserService.to.profile.isSystemUser())
                TextButton(
                    onPressed: () {
                      controller.choosePerson();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(10)
                          ),
                          child: Icon(Icons.person,color: AppColors.secondary,),
                        ),
                        SizedBox(height: 10,),
                        Text('名片',style: TextStyle(color: AppColors.secondary),)
                      ],
                    )
                ),
            ],
          ),
        ).height(controller.bottomContainerH)
      else if (controller.showEmojiPanel)
        Container(
          child: EmojiPicker(
            textEditingController: controller.inputTextFieldController,
            onEmojiSelected: (Category? category, Emoji emoji) {
              controller.update(["chat_input_widget"]);
            },
            onBackspacePressed: () {
              // Do something when the user taps the backspace button (optional)
              // Set it to null to hide the Backspace-Button
              controller.update(["chat_input_widget"]);
            },
            config: Config(
              columns: 7,
              // Issue: https://github.com/flutter/flutter/issues/28894
              // emojiSizeMax: 32 *
              //     (foundation.defaultTargetPlatform ==
              //         TargetPlatform.iOS
              //         ? 1.30
              //         : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: const Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              recentTabBehavior: RecentTabBehavior.NONE,
              recentsLimit: 28,
              replaceEmojiOnLimitExceed: false,
              noRecents: const Text(
                'No Recents',
                style: TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
              loadingIndicator: const SizedBox.shrink(),
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
              checkPlatformCompatibility: true,
            ),
          ),
        ).height(controller.bottomContainerH),
    ].toColumn();
  }

  // 输入框
  Widget inputTf(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left:10,right:10),
      decoration: BoxDecoration(
        color: Color(0XFFEEEEEE),
          borderRadius:BorderRadius.circular(10)
      ),
      child:TextField(
        controller: controller.inputTextFieldController,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        minLines: 1,
        focusNode: controller.focusNode,
        decoration: const InputDecoration(
          //filled: true,
          hintText: "输入消息内容",
          // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: InputBorder.none,
          //isDense: true,
          /*border: OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: Colors.black12),
        )
        */
        ),
        onChanged: (value) {
          if(chatConversation?.friend_profile == null) {
            if (value == controller.lastInput + '@') {
              controller.searchController.text = '';
              showModalBottomSheet(
                  context: context, builder: (context) {
                return StatefulBuilder(
                    builder: (context,
                        StateSetter setState) {
                      List<GroupMemberModel> groupMember = [controller.allMemberModel];
                      if ((chatConversation?.group_profile?.members?.length ??
                          0) > 0)
                        groupMember.addAll(
                            chatConversation!.group_profile!.members);
                      if (controller.searchController.text.length > 0) {
                        groupMember?.removeWhere((element) =>
                            element.userId!=0 && !(element.nickname?.contains(
                            controller.searchController.text) ?? false));
                      }
                      return Container(
                        //constraints: BoxConstraints(maxHeight: 480),

                          child: Column(
                            children: [
                              TextWidget.title2('选择提醒的人').paddingSymmetric(
                                  horizontal: 10, vertical: 10),

                              InputWidget.search(
                                controller: controller.searchController,
                                hintText: LocaleKeys.commonSearch.tr,
                                suffixIcon: IconWidget.icon(Icons.cancel)
                                    .onTap(() {
                                  controller.searchController.text = '';
                                  setState(() {});
                                }),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ).paddingAll(AppSpace.page),
                              Divider(height: 1, thickness: 1,),
                              ListView.separated(
                                itemBuilder: (context, index) {
                                  return _buildMember(groupMember![index]);
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 1,
                                  ).padding(top: 5, bottom: 5);
                                },
                                itemCount: groupMember?.length ?? 0,
                              ).expanded(),


                            ],
                          )


                      );
                    });
              });
            }
            controller.onTextChange(value);
          }
          controller.update(["chat_input_widget"]);
        },
      ),
    );
  }

  // 一个群成员
  Widget _buildMember(GroupMemberModel member) {
    Widget avatar;
    if(member.userId==0) {
      avatar = Image.asset(AssetsImages.contactMyGroupPng);

    }else{
      avatar = ImUtil.getAvatarWidget(member?.avatar);
    }

    // 显示昵称或备注
    var showName = member?.nickname;

    var content = <Widget>[

      avatar.tightSize(40.w),
      Gap(AppSpace.listRow),
      TextWidget.body1(showName ?? ''),

    ].toRow().marginSymmetric(
      horizontal: AppSpace.page,
      vertical: AppSpace.listView,
    );

    return content.onTap(() {
      controller.onTapMember(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatInputWidgetController>(
      init: ChatInputWidgetController(),
      id: "chat_input_widget",
      builder: (_) {
        controller.chatConversation = chatConversation;
        controller.scrollController = scrollController;
        controller.messageStreamModel = messageStreamModel;
        return _buildView(context);
      },
    );
  }
}
