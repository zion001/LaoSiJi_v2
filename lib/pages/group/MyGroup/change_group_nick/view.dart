import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

class ChangeGroupNickPage extends GetView<ChangeGroupNickController> {
  const ChangeGroupNickPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      Gap(AppRadius.card),
      const TextWidget.body3('昵称修改后，只会在此群聊内显示，群成员都可以看见。')
          .marginSymmetric(horizontal: AppSpace.page),
      Gap(AppRadius.card),
      const [TextWidget.body1('我的群昵称')]
          .toRow(crossAxisAlignment: CrossAxisAlignment.center)
          .height(55.w)
          .marginSymmetric(horizontal: AppSpace.page)
          .backgroundColor(Colors.white),
      const Divider(
        height: 1,
      ).marginSymmetric(horizontal: AppSpace.page),

/*      InputWidget.text(
        hintText: '请输入内容',
        controller: controller.nickController,
      )
      */
      Form(
        key: controller.formKey,
        child: TextFormField(
          autocorrect: false,
          validator: Validatorless.multiple([
            Validatorless.required('请输入'),
            IMValidators.nickname('昵称为2-32位英文字母、数字或中文组合'),
          ]),
          controller: controller.nickController,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, 0),
          ),
        ),
      )
          .center()
          // .height(55.w)
          .backgroundColor(Colors.white)
          .marginSymmetric(horizontal: 6.w),
      Gap(AppSpace.page * 2),
      ButtonWidget.textFilled(
        '确定',
        onTap: () {
          controller.onBtnTapped();
        },
      ).tight(height: 55.w),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangeGroupNickController>(
      init: ChangeGroupNickController(),
      id: "change_group_nick",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '我的群昵称',
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
