import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/routers/names.dart';
import 'package:im_flutter/common/services/contacts_manager.dart';
import 'package:im_flutter/common/services/group_manager.dart';
import 'package:im_flutter/common/services/user_service.dart';
import 'package:im_flutter/common/index.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MainController extends GetxController {
  Stream<List<ConversationModel>> conversationStream =
      ImClient.getInstance().conversationStreamModel.getConversations();
  StreamSubscription? subscriptionGroupsEvent;
  StreamSubscription? subscriptionLoginSuccessEvent;
  // 分页管理
  final PageController pageController = PageController();
  // 当前的 tab index
  int currentIndex = 0;

  MainController();

  _initData() {
    update(["main"]);

    subscriptionGroupsEvent =
        EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      //获取群数据（断线重连后，可能还需要）
      GroupManager.refreshAllGroup();
    });
    subscriptionLoginSuccessEvent =
        EventBusUtils.shared.on<LoginSuccessEvent>().listen((event) {
      myInit();
    });
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() async {
    super.onReady();
    _initData();

    if (!UserService.to.isLogin) {
      await Get.toNamed(RouteNames.systemLogin);
    } else {
      myInit();
    }
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
    subscriptionGroupsEvent?.cancel();
    subscriptionLoginSuccessEvent?.cancel();
  }

  void myInit() async {
    if (UserService.to.isLogin) {
      //获取系统设置
      await SystemConfigManager.getConfig();
      OBSClient.init(ObsConfig.key, ObsConfig.secret,
      'https://${ObsConfig.bucket}.${ObsConfig.endPoint}', ObsConfig.bucket, ObsConfig.host);
      //获取群数据（断线重连后，可能还需要）
      GroupManager.refreshAllGroup();

      //获取好友申请列表数据（断线重连后，可能还需要）
      FriendApplyManager.refreshFriendApplyLis();

      //连接im server
      if (ImClient.getInstance().getCurrentConnectionState().connectionState
          != MqttConnectionState.disconnected)
        ImClient.getInstance().disconnect();

      await ImClient.getInstance().connect(
          UserService.to.profile?.user_id?.toString() ?? '',
          UserService.to.token,
          UserService.to.loginId);
      ImClient.getInstance().getConversationList();

      //获取联系人数据（断线重连后，可能还需要）
      ContactsManager.refreshFriendList();
    }
  }

  // 切换页面
  void onJumpToPage(int page) {
    pageController.jumpToPage(page);
  }

  // Tab导航栏切换
  void onIndexChanged(int index) {
    currentIndex = index;
    update(['navigation']);
  }
}
