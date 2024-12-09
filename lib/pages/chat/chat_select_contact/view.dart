import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'index.dart';

class ChatSelectContactPage extends GetView<ChatSelectContactController> {
  const ChatSelectContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatSelectContactController>(
      init: ChatSelectContactController(),
      id: "chat_select_contact",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '选择联系人',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }

  // 主视图
  Widget _buildView() {
    var showItems = <Widget>[
      // InputWidget.search(
      //   controller: controller.searchController,
      //   hintText: LocaleKeys.commonSearch.tr,
      //   suffixIcon: IconWidget.icon(
      //       Icons.cancel
      //   ).onTap(() {
      //     controller.searchController.text = '';
      //     controller.searchChanged(controller.searchController.text);
      //   }),
      //   onChanged: controller.searchChanged,
      // ).paddingAll(AppSpace.page),

    ];
    showItems.add(CustomScrollView(
      slivers: _buildContactList(),
    ).expanded());

    return showItems.toColumn();
  }

  // 头部项
  Widget _buildHeaderItem(
      String image, String title, VoidCallback onTapCallBack,
      {bool redDot = false}) {
    return <Widget>[
      ImageWidget.asset(image).tightSize(40.w),
      Gap(AppSpace.listRow),
      TextWidget.title3(title),
      Expanded(child: Container()),

      !redDot
          ? Container()
          : Obx(() => TextWidget.body1(
                '${FriendApplyManager.applyCount}',
                color: Colors.white,
              )
                  .center()
                  .tightSize(FriendApplyManager.applyCount == 0 ? 0 : 20.w)
                  .backgroundColor(AppColors.error)
                  .clipOval()),
      //  TextWidget.body1('1', color: Colors.white,).center().tightSize(20.w).backgroundColor(AppColors.error).clipOval(),
    ]
        .toRow()
        .onTap(() {
          onTapCallBack();
        })
        .marginSymmetric(horizontal: AppSpace.page, vertical: AppSpace.listView)
        .sliverBox;
  }

  // 好友列表项
  List<Widget> _buildContactList() {
    var cells =
        ContactsManager.friendGroupList.map((group) => _buildGroup(group));
    return cells.map((e) => e.sliverBox).toList();
  }

  // 一个分组
  Widget _buildGroup(ContactGroup group) {
    var items = group.list.map((friend) => _buildConact(friend)).toList();
    items.insert(
      0,
      TextWidget.title3(
        group.groupTitle,
        color: AppColors.primary,
      )
          .marginSymmetric(horizontal: AppSpace.page)
          .backgroundColor(AppColors.primaryContainer),
    );

    return items.toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  // 一个联系人
  Widget _buildConact(FriendListItemModel friend) {
    var avatar = ImUtil.getAvatarWidget(friend.user_profile?.avatar);
    /*
    friend.user_profile?.avatar == null
        ? const ImageWidget.asset(AssetsImages.avatarDefaultPng)
        : ImageWidget.url(
            'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${friend.user_profile?.avatar ?? ''}');
            */
    var online = friend.isOnline ?? false
        ? LocaleKeys.commonOnline.tr
        : LocaleKeys.commonOffline.tr;
    var onlineColor = friend.isOnline ?? false
        ? AppColors.primary
        : AppColors.onSecondaryContainer;
    // 显示昵称或备注
    var showName = (friend.remark == null || friend.remark!.isEmpty)
        ? friend.user_profile?.nickname
        : friend.remark;

    var content = <Widget>[
      avatar.tightSize(40.w),
      Gap(AppSpace.listRow),
      TextWidget.body1(showName ?? ''),
      TextWidget.body2(
        '($online)',
        color: onlineColor,
      ),
    ].toRow().marginSymmetric(
          horizontal: AppSpace.page,
          vertical: AppSpace.listView,
        );

    return <Widget>[
      content.onTap(() {
        controller.onTapContact(friend);
      }),
      Container(
        height: 1,
        color: Colors.black12,
      ).paddingOnly(left: AppSpace.page + 40.w, right: AppSpace.page),
    ].toColumn();
  }
}
