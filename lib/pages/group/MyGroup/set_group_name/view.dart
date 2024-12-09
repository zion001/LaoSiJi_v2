import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class SetGroupNamePage extends GetView<SetGroupNameController> {
  const SetGroupNamePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      Gap(AppSpace.page),
      InputWidget.text(
        hintText: '请输入群名称',
        suffixIcon: IconWidget.icon(
          Icons.close_rounded,
          color: Colors.grey,
          size: 20,
        ).marginAll(8).onTap(() {
          controller.onClearTapped();
        }),
        controller: controller.groupNameController,
      ).center().backgroundColor(Colors.white).tight(height: 50),
      Gap(40.w),
      ButtonWidget.textFilled(
        '确定',
        onTap: controller.onSubmitTapped,
      ).tight(height: 50).marginSymmetric(horizontal: AppSpace.page),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetGroupNameController>(
      init: SetGroupNameController(),
      id: "set_group_name",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群名称',
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
