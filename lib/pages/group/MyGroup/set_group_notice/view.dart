import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class SetGroupNoticePage extends GetView<SetGroupNoticeController> {
  const SetGroupNoticePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          hintText: '添加群公告',
          border: InputBorder.none,
          suffixIcon: ButtonWidget.icon(
            const Icon(
              Icons.clear_rounded,
              color: Colors.white,
              size: 20,
            ).backgroundColor(Colors.grey).clipRRect(all: 10),
            onTap: () => controller.onClearTapped(),
          ).tight(width: 20, height: 20),
        ),
        controller: controller.noticeController,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: (text) {
          // Do something when the text changes.
        },
      ),
    ).marginAll(AppSpace.page);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetGroupNoticeController>(
      init: SetGroupNoticeController(),
      id: "set_group_notice",
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: MyAppBar(
            context,
            '群公告',
            showBackIcon: true,
            actions: ButtonWidget.textRoundFilled(
              '发布',
              textColor: AppColors.primary,
              bgColor: AppColors.background,
              borderRadius: 12,
              onTap: controller.onBtnTapped,
            ).tight(height: 24, width: 44),
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
