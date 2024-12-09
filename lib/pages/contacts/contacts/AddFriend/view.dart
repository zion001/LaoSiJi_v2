import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

/// 搜索好友

class AddFriendPage extends GetView<AddfriendController> {
  const AddFriendPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return <Widget>[
      InputWidget.search(
        controller: controller.searchController,
        hintText: LocaleKeys.commonSearch.tr,
        suffixIcon: TextWidget.body2(
          LocaleKeys.commonConfirm.tr,
        ).onTap(() {
          controller.onTapConfirm();
        }),
        onSubmitted: (p0) => controller.onTapConfirm(),
      ).paddingAll(AppSpace.page),
      _searchResult(),
    ].toColumn();
  }

  // 搜索结果
  Widget _searchResult() {
    switch (controller.curStatus) {
      case SearchStatus.waitForSearch:
        return TextWidget.body1(LocaleKeys.contactSearchHint.tr)
            .backgroundColor(AppColors.primaryContainer);
      case SearchStatus.searchedNull:
        return TextWidget.body1(LocaleKeys.contactSearchResultEmpty.tr)
            .backgroundColor(AppColors.primaryContainer);
      case SearchStatus.searchedSuccess:
        var avtar = ImUtil.getAvatarWidget(
                controller.searchedUserInfo?.userProfile?.avatar ?? "")
            .tightSize(40.w);
        /*
        (controller.searchedUserInfo?.userProfile?.avatar == null ||
                controller.searchedUserInfo!.userProfile!.avatar!.isEmpty)
            ? Image.asset(AssetsImages.avatarDefaultPng).tightSize(40.w)
            : ImageWidget.url(
                    controller.searchedUserInfo?.userProfile?.avatar ?? "")
                .tightSize(40.w);
                */

        return <Widget>[
          avtar,
          Gap(AppSpace.listRow),
          TextWidget.body1(
              controller.searchedUserInfo?.userProfile?.nickname ?? ''),
        ]
            .toRow()
            .paddingAll(AppSpace.page)
            .backgroundColor(AppColors.secondaryContainer)
            .onTap(() {
          controller.onTapUserInfo();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddfriendController>(
      init: AddfriendController(),
      id: "addfriend",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            LocaleKeys.contactAddFriend.tr,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
