import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'index.dart';

class ForwardConversationPage extends GetView<ForwardConversationController> {
  const ForwardConversationPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    List<ConversationModel> listConversation = controller.getConversationList();
    return [
      InputWidget.search(
        controller: controller.searchController,
        hintText: LocaleKeys.commonSearch.tr,
        suffixIcon: IconWidget.icon(Icons.cancel).onTap(() {
          controller.searchController.text = '';
          controller.searchChanged(controller.searchController.text);
        }),
        onChanged: controller.searchChanged,
      ).paddingAll(AppSpace.page),
      ListTile(
          title: Text('创建新聊天', style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.keyboard_arrow_right_outlined),
          onTap: controller.onTapNewConversation),
      Divider(
        height: 1,
      ),
      Text('最近聊天').padding(left: 10, top: 10, bottom: 10),
      ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          // Why network for web?
          // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
          ConversationModel conversationModel = listConversation![index];

          return _buildConversation(conversationModel);
        },
        itemCount: listConversation?.length ?? 0,
      ).expanded(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }

  // 一个会话
  Widget _buildConversation(ConversationModel? conversationModel) {
    Widget avatar;
    if (conversationModel?.group_profile != null) {
      avatar = ImUtil.getAvatarWidget(conversationModel?.group_profile?.avatar);
    } else {
      avatar =
          ImUtil.getAvatarWidget(conversationModel?.friend_profile?.avatar);
    }
    int unreadNum = conversationModel?.unread_count ?? 0;
    final unreadText = unreadNum < 100 ? unreadNum.toString() : "99+";
    String? msgText;
    if (conversationModel?.last_message_info?.msg_body?.msg_type == 'image')
      msgText = '[图片]';
    else if (conversationModel?.last_message_info?.msg_body?.msg_type ==
        'video')
      msgText = '[视频]';
    else if (conversationModel?.last_message_info?.msg_body?.msg_type == 'file')
      msgText = '[文件]';
    else if (conversationModel?.last_message_info?.msg_body?.msg_type ==
        'audio')
      msgText = '[语音]';
    else
      msgText = conversationModel?.last_message_info?.msg_body?.text;
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
                TextWidget.body1(conversationModel?.friend_profile?.nickname ??
                    (conversationModel?.group_profile?.title ?? '')),
                Gap(AppSpace.listView),
                TextWidget.body2(msgText ?? '',
                    overflow: TextOverflow.ellipsis),
              ]).expanded(),
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if ((conversationModel?.last_message_info?.created_at ??
                        (conversationModel?.created_at ?? 0)) >
                    0)
                  TextWidget.body2(DateFormat('M-d HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          conversationModel?.last_message_info?.created_at ??
                              (conversationModel?.created_at ?? 0)))),
                if (unreadNum > 0) Gap(AppSpace.listView),
                if (unreadNum > 0)
                  UnconstrainedBox(
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: unreadNum != 0
                          ? Text(unreadText,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: unreadText.length * -2 + 14))
                          : null,
                    ),
                  ),
              ]),
        ],
      ).expanded(),
    ].toRow().tight(height: 50.w).marginSymmetric(
          horizontal: AppSpace.page,
          vertical: AppSpace.listItem,
        );

    return Container(
        color: Colors.white,
        child: <Widget>[
          content.onTap(() {
            controller.onTapConversation(conversationModel);
          }),
        ].toColumn());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForwardConversationController>(
      init: ForwardConversationController(),
      id: "forward_conversation",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '选择一个聊天',
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
