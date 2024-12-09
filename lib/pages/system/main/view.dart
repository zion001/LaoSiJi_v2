import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/pages/index.dart';
import 'package:badges/badges.dart' as badges;
import 'package:im_flutter/common/mqtt/im_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver  {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("当前的应用生命周期状态 : ${state}");

    if(state == AppLifecycleState.paused){
      print("应用进入后台 paused");

    }else if(state == AppLifecycleState.resumed){
      print("应用进入前台 resumed");

      print(ImClient.getInstance().getCurrentConnectionState().connectionState);
      if(ImClient.getInstance().getCurrentConnectionState().connectionState
          == MqttConnectionState.connected) { //不重连的话，在此处刷新
        Future.delayed(const Duration(milliseconds: 1000), () {
          //获取群数据（断线重连后，可能还需要）
          GroupManager.refreshAllGroup();
          //获取联系人数据（断线重连后，可能还需要）
          ContactsManager.refreshFriendList();
          //获取好友申请列表数据（断线重连后，可能还需要）
          FriendApplyManager.refreshFriendApplyLis();

          //刷新会话
          ImClient.getInstance().getConversationList();
        });
      }
    }else if(state == AppLifecycleState.inactive){
      // 应用进入非活动状态 , 如来了个电话 , 电话应用进入前台
      // 本应用进入该状态
      print("应用进入非活动状态 inactive");

    }else if(state == AppLifecycleState.detached){
      // 应用程序仍然在 Flutter 引擎上运行 , 但是与宿主 View 组件分离
      print("应用进入 detached 状态 detached");

    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _MainViewGetX();
  }
}

class _MainViewGetX extends GetView<MainController> {
  _MainViewGetX({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    final List<BottomNavigationBarItem> bottomButtons =
        <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        //icon: const ImageWidget.asset(AssetsImages.tabMessageUnselectedPng),
        //activeIcon: const ImageWidget.asset(AssetsImages.tabMessageSelectedPng),
        icon: StreamBuilder<List<ConversationModel>>(
            stream: controller.conversationStream,
            builder: (c, snapshot) {
              List listConversation = [];
              int unread = 0;
              if (snapshot.hasData) {
                listConversation = snapshot.data!;
                for (ConversationModel conversationModel in listConversation) {
                  unread += (conversationModel.unread_count ?? 0);
                }
              }
              final unreadText = unread < 100 ? unread.toString() : "99+";
              return badges.Badge(
                badgeContent: Text(unreadText,
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                showBadge: unread > 0,
                child: Image.asset(AssetsImages.tabMessageUnselectedPng),
              );
            }),
        activeIcon: StreamBuilder<List<ConversationModel>>(
            stream: controller.conversationStream,
            builder: (c, snapshot) {
              List listConversation = [];
              int unread = 0;
              if (snapshot.hasData) {
                listConversation = snapshot.data!;
                for (ConversationModel conversationModel in listConversation) {
                  unread += (conversationModel.unread_count ?? 0);
                }
              }
              final unreadText = toBadgeNum(unread);
              return badges.Badge(
                badgeContent: Text(unreadText,
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                showBadge: unread > 0,
                child: Image.asset(AssetsImages.tabMessageSelectedPng),
              );
            }),
        label: LocaleKeys.tabMessages.tr,
      ),
      BottomNavigationBarItem(
        icon: Obx(() => badges.Badge(
              badgeContent: Text(
                  toBadgeNum(FriendApplyManager.applyCount.value),
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              showBadge: FriendApplyManager.applyCount > 0,
              child: Image.asset(AssetsImages.tabContactsUnselectedPng),
            )),
        activeIcon: Obx(() => badges.Badge(
              badgeContent: Text(
                  toBadgeNum(FriendApplyManager.applyCount.value),
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              showBadge: FriendApplyManager.applyCount > 0,
              child: Image.asset(AssetsImages.tabContactsSelectedPng),
            )),
        label: LocaleKeys.tabContacts.tr,
      ),
      BottomNavigationBarItem(
        icon: Image.asset(AssetsImages.tabMyUnselectedPng),
        activeIcon: Image.asset(AssetsImages.tabMySelectedPng),
        label: LocaleKeys.tabMine.tr,
      ),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      //底部TAB
      bottomNavigationBar: GetBuilder<MainController>(
        id: 'navigation',
        builder: (controller) {
          return BottomNavigationBar(
            currentIndex: controller.currentIndex,
            elevation: 5,
            items: bottomButtons,
            onTap: controller.onJumpToPage,
          );
        },
      ),
      //内容
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        onPageChanged: controller.onIndexChanged,
        children: const [
          ConversationsPage(), //消息列表
          ContactsPage(), //好友列表
          MinePage(), //我的
        ],
      ),
    );
  }

  String toBadgeNum(int count) {
    return count < 100 ? count.toString() : "99+";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: MainController(),
      id: "main",
      builder: (_) {
        return _buildView();
      },
    );
  }
}
