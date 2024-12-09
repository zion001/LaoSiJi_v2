import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

class ChangenicknamePage extends GetView<ChangenicknameController> {
  const ChangenicknamePage({Key? key}) : super(key: key);
/*
  // 主视图
  Widget _buildView() {
    return [
      OptionListCell(
        title: '我的昵称',
        suffix: Container(),
      ).height(50),
      const Divider(
        height: 1,
      ),
      InputWidget.text(
        controller: controller.nicknameController,
      )
          .center()
          .backgroundColor(Colors.white)
          .height(50)
          .marginSymmetric(horizontal: AppSpace.listItem),
      Gap(AppSpace.card * 2),
      ButtonWidget.textFilled(
        "确定",
        onTap: () => controller.onSubmitBtnTapped(),
      ).tight(height: 50).marginSymmetric(horizontal: AppSpace.page),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }
  */

  // 主视图
  Widget _buildView() {
    return [
      OptionListCell(
        title: '我的昵称',
        suffix: Container(),
      ).height(50),
      const Divider(
        height: 1,
      ),
      Form(
        key: controller.formKey,
        child: TextFormField(
          controller: controller.nicknameController,
          autocorrect: false,
          validator: Validatorless.multiple([
            Validatorless.required('请输入昵称'),
            IMValidators.nickname("昵称为2-32位英文字母、数字或中文组合"),
          ]),
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, 0),
            hintText: '请输入',
          ),
        ).backgroundColor(Colors.white),
      ),
      Gap(AppSpace.card * 2),
      ButtonWidget.textFilled(
        "确定",
        onTap: () => controller.onSubmitBtnTapped(),
      ).tight(height: 50).marginSymmetric(horizontal: AppSpace.page),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangenicknameController>(
      init: ChangenicknameController(),
      id: "changenickname",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '修改昵称',
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
