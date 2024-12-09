import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:badges/badges.dart' as badges;
import 'package:gap/gap.dart';
import 'package:im_flutter/common/index.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'index.dart';

import 'package:provider/provider.dart';
import 'package:im_flutter/common/mqtt/im_client.dart';
import 'package:im_flutter/common/mqtt/connection_state_model.dart';

class ConversationsPage extends GetView<ConversationsController> {
  const ConversationsPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return StreamBuilder<List<ConversationModel>>(
        stream: controller.conversationStream,
        builder: (c, snapshot) {
          List listConversation = [];
          if (snapshot.hasData) listConversation = snapshot.data!;

          return SlidableAutoCloseBehavior(
            child: EasyRefresh(
                onRefresh: () async {
                  controller.onRefresh();
                },
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    // Why network for web?
                    // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
                    ConversationModel conversationModel =
                        listConversation![index];
                    int conversationType;
                    int conversationId;
                    if (conversationModel?.friend_profile != null) {
                      conversationType = 1;
                      conversationId = conversationModel!.friend_profile!.uid!;
                    } else {
                      conversationType = 2;
                      conversationId =
                          conversationModel!.group_profile!.groupId!;
                    }
                    bool pinned = conversationModel?.is_pinned ?? false;
                    return Slidable(
                      key: ValueKey("$index"),
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Slidable.of(context)!.close();
                              ConversationManager.setSessionPinned(
                                  conversationType, conversationId, !pinned);
                            },
                            flex: pinned ? 3 : 2,
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.arrow_circle_up_sharp,
                            label: pinned ? '取消置顶' : '置顶',
                          ),
                          SlidableAction(
                            flex: 2,
                            onPressed: (context) {
                              Slidable.of(context)!.close();

                              ConversationManager.deleteSession(
                                  conversationModel.session_id!);
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '删除',
                          ),
                        ],
                      ),
                      child: _buildConversation(conversationModel),
                    );
                  },
                  itemCount: listConversation?.length ?? 0,
                )),
          );
        });
  }

  // 一个会话
  Widget _buildConversation(ConversationModel conversationModel) {
    Widget avatar;
    if (conversationModel.group_profile != null) {
      avatar = ImUtil.getAvatarWidget(conversationModel.group_profile?.avatar);
    } else {
      avatar =
          ImUtil.getAvatarWidget(conversationModel.friend_profile?.avatar);
    }
    int unreadNum = conversationModel.unread_count ?? 0;
    String unreadText;
    if (unreadNum == 0)
      unreadText = '';
    else if (unreadNum < 10)
      unreadText = ' ' + unreadNum.toString() + ' ';
    else if (unreadNum < 100)
      unreadText = unreadNum.toString();
    else
      unreadText = "99+";

    String msgText = ImUtil.getMessageText(conversationModel.last_message_info);
    var showName;
    if(conversationModel.friend_profile!=null) {
      FriendListItemModel? friendListItemModel = ContactsManager.getFriend(
          conversationModel.friend_profile!.uid!);
      showName = (friendListItemModel?.remark == null ||
          friendListItemModel!.remark!.isEmpty)
          ? conversationModel.friend_profile?.nickname
          : friendListItemModel.remark;
    }else{
      showName = conversationModel.group_profile?.title;
    }

    var content = <Widget>[
      avatar.tightSize(40.w),
      Gap(AppSpace.listRow),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*
                TextWidget.body1(conversationModel?.friend_profile?.nickname ??
                    (conversationModel?.group_profile?.title ?? '')),
                    */
                conversationModel.friend_profile != null
                  ? TextWidget.body1(showName ?? '')
                  : [
                    Image.asset('assets/images/group.png'),
                    Gap(4.w),
                    TextWidget.body1(showName ?? ''),
                  ].toRow(),
                Gap(AppSpace.listView),
                Row(
                  children: [
                    if(conversationModel.at_message!=null)
                      TextWidget.body2("[有人@我]",color:Colors.red),
                    TextWidget.body2(msgText ?? '',
                        overflow: TextOverflow.ellipsis).expanded(),
                  ],
                ),

              ]).expanded(),
          if(conversationModel.is_pinned == true)
            Image.asset('assets/images/pinned.png').paddingOnly(right: 5),
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if ((conversationModel.last_message_info?.created_at ??
                        (conversationModel.created_at ?? 0)) >
                    0)
                  TextWidget.body2(DateFormat('M-d HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          conversationModel.last_message_info?.created_at ??
                              (conversationModel.created_at ?? 0)))),
                if (unreadNum > 0) Gap(AppSpace.listView),
                if (unreadNum > 0)
                  badges.Badge(
                    badgeContent: Text(unreadText,
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                    showBadge: unreadNum > 0,
                    badgeAnimation:
                        badges.BadgeAnimation.slide(toAnimate: false), //暂时去掉动画
                  ),
                // UnconstrainedBox(
                //   child: Container(
                //     width: 16,
                //     height: 16,
                //     alignment: Alignment.center,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.red,
                //     ),
                //     child: unreadNum != 0
                //         ? Text(unreadText,
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: unreadText.length * -2 + 14))
                //         : null,
                //   ),
                // ),
              ]),
        ],
      ).expanded(),
    ].toRow().tight(height: 50.w).marginSymmetric(
          horizontal: AppSpace.page,
          vertical: AppSpace.listItem,
        );

    return <Widget>[
      content.onTap(() {
        controller.onTapConversation(conversationModel);
      }),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {


    return GetBuilder<ConversationsController>(
      init: ConversationsController(),
      id: "conversations",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: ChangeNotifierProvider<ConnectionStateModel>.value(
                value: ImClient.getInstance().getCurrentConnectionState(),
                child: Consumer<ConnectionStateModel>(
                    builder: (context, model, child) {
                  return Text(
                      model.connectionState == MqttConnectionState.connected
                          ? LocaleKeys.tabMessages.tr
                          : model.getConnectionString());
                })),
            centerTitle: true,
            actions: [
              CustomPopupMenu(
                arrowSize: 20,
                arrowColor: Color(0xFFFCFCFC),
                menuBuilder: () {
                  var menuItems = [
                    [ Gap(4.w),
                      const Icon(
                        Icons.chat_rounded,
                        color: Colors.black,
                      ),
                      Gap(8.w),
                      const TextWidget.body1('发起群聊', color: Colors.black),
                    ]
                        .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                        .tight(height: 60.w, width: 120.w)
                        .onTap(() {
                      controller.onTapCreatGroup();
                    }),
                    [
                      Gap(4.w),
                      const Icon(
                        Icons.add_box_outlined,
                        color: Colors.black,
                      ),
                      Gap(8.w),
                      const TextWidget.body1('添加好友', color: Colors.black),
                    ]
                        .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                        .tight(height: 60.w, width: 120.w)
                        .onTap(() {
                      controller.onTapAddFriend();
                    }),
                    [
                      Gap(4.w),
                      IconWidget.image(
                        AssetsImages.scanPng,
                        size: 25.w,
                      ),
                      Gap(8.w),
                      const TextWidget.body1('扫一扫', color: Colors.black),
                    ]
                        .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                        .tight(height: 60.w, width: 120.w)
                        .onTap(() {
                      controller.onTapScan();
                    })];

                  if( !UserService.to.profile.isSystemUser() ) {
                    menuItems.removeAt(0);
                  }
                  return IntrinsicWidth(
                    child: menuItems.toColumn().marginAll(AppSpace.listRow),
                  )
                      .backgroundColor(const Color(0xFFFCFCFC))
                      .clipRRect(all: AppRadius.card);
                },
                pressType: PressType.singleClick,
                verticalMargin: -10,
                controller: controller.menuController,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
