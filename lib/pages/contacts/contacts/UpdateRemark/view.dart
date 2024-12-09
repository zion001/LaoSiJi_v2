import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

/// 更新用户备注名

class UpdateRemarkPage extends GetView<UpdateRemarkController> {
  const UpdateRemarkPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return <Widget>[
      const TextWidget.body1('备注名'),
      Gap(10.w),
/*      InputWidget.textBorder(
        controller: controller.remarkController,
      ),
      */
      Form(
        key: controller.formKey,
        child: TextFormField(
          autocorrect: false,
          validator: Validatorless.multiple([
            Validatorless.required('请输入'),
            IMValidators.friendRemark('备注为2-32位英文字母、数字或中文组合'),
          ]),
          controller: controller.remarkController,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, 0),
          ),
        ),
      ),
      Gap(40.w),
      ButtonWidget.textFilled(
        '确定',
        onTap: controller.setRemark,
      ).tight(height: 44.w),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .marginAll(AppSpace.page);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateRemarkController>(
      init: UpdateRemarkController(),
      id: "updateremark",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(context, '设置备注'),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
