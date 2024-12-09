import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class MessagenotificationPage extends GetView<MessagenotificationController> {
  const MessagenotificationPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      [
        Gap(AppSpace.page),
        const TextWidget.body1('声音').expanded(),
        Switch(
          value: true,
          activeColor: AppColors.primary,
          onChanged: (value) => controller.onSoundSwitchValueChanged(value),
        ),
      ].toRow().backgroundColor(Colors.white),
      const Divider(
        height: 1,
      ),
      [
        Gap(AppSpace.page),
        const TextWidget.body1('震动').expanded(),
        Switch(
          value: true,
          activeColor: AppColors.primary,
          onChanged: (value) => controller.onSoundSwitchValueChanged(value),
        )
      ].toRow().backgroundColor(Colors.white),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessagenotificationController>(
      init: MessagenotificationController(),
      id: "messagenotification",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '消息通知',
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
