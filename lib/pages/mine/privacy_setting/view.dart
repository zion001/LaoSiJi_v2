import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class PrivacySettingPage extends GetView<PrivacySettingController> {
  const PrivacySettingPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return SwitchListTile(
        title: const TextWidget.body1('添加我是否需要验证'),
        value: controller.profile?.addFriendConfirm == 1,
        activeColor: AppColors.primary,
        onChanged: controller.onChangeAddSetting);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrivacySettingController>(
      init: PrivacySettingController(),
      id: "privacy_setting",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '隐私设置',
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
