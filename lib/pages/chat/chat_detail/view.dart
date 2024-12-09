import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class ChatDetailPage extends GetView<ChatDetailController> {
  const ChatDetailPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    String avatarUrl =
        controller.conversationModel?.friend_profile?.avatar ?? '';
    String nameStr =
        controller.conversationModel?.friend_profile?.nickname ?? '';
    return [
      [
        [
          ImUtil.getAvatarWidget(avatarUrl).tight(width: 50.w, height: 50.w),
          //ImageWidget.url(avatarUrl).tight(width: 50.w, height: 50.w),
          TextWidget.body2(
            nameStr,
            textAlign: TextAlign.center,
          ),
        ].toColumn()
      ]
          .toRow()
          .paddingAll(AppSpace.page)
          .backgroundColor(Colors.white)
          .onTap(() {
        controller.onTapAvatar();
      }),
      Gap(AppSpace.listRow),
      [
        const TextWidget.body1('置顶聊天').expanded(),
        Switch(
          value: controller.conversationModel?.is_pinned ?? false,
          activeColor: AppColors.primary,
          onChanged: (value) => controller.onTapPin(value),
        ),
      ]
          .toRow()
          .tight(height: 60.w)
          .paddingHorizontal(AppSpace.page)
          .backgroundColor(Colors.white),
      Gap(AppSpace.listRow),
      [
        const TextWidget.body1('清空聊天记录').expanded(),
        const Icon(Icons.arrow_right_sharp),
      ]
          .toRow()
          .tight(height: 60.w)
          .onTap(() {
              controller.clearHistoryMessage();
          })
          .paddingHorizontal(AppSpace.page)
          .backgroundColor(Colors.white),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatDetailController>(
      init: ChatDetailController(),
      id: "chat_detail",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '聊天详情',
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
