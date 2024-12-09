import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class FriendApplyListPage extends GetView<FriendApplyListController> {
  const FriendApplyListPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return ListView.separated(
      itemBuilder: (context, index) =>
          applyCell(FriendApplyManager.friendApplyList[index]),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: FriendApplyManager.friendApplyList.length,
    );
  }

  // 一条申请数据
  Widget applyCell(FriendApplyModel model) {
    return [
      ImUtil.getAvatarWidget(model.avatar ?? '')
          .tightSize(40.w)
          .marginSymmetric(horizontal: AppSpace.page),
      [
        TextWidget.body1(model.nickname ?? ''),
        TextWidget.body2('来源:${model.sourceDesc()}')
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
      ButtonWidget.text(
        '拒绝',
        textColor: AppColors.error,
        onTap: () {
          controller.refuseApply(model.applyId!);
        },
      ),
      const Gap(10),
      ButtonWidget.text(
        '同意',
        textColor: AppColors.primary,
        onTap: () {
          controller.acceptApply(model.applyId!);
        },
      ),
      const Gap(10),
    ].toRow();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendApplyListController>(
      init: FriendApplyListController(),
      id: "friend_apply_list",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '新的朋友',
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
