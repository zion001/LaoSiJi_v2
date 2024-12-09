import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

enum SearchStatus {
  waitForSearch, // 初始状态，等待输入搜索
  searchedNull, //搜索结果为空
  searchedSuccess, //搜索到结果
}

class AddfriendController extends GetxController {
  //用户名
  TextEditingController searchController = TextEditingController();

  /// 当前状态
  SearchStatus curStatus = SearchStatus.waitForSearch;

  /// 保存搜索结果
  UserInfoBasic? searchedUserInfo;

  /// 搜索用户名, 需要暂时保存一下，传到下一页，以免搜索后又改变输入框，再点击进入下一页，此时直接用输入框的值不对。
  String searchedUserName = '';

  AddfriendController();

  _initData() {
//    searchController.text = 'zion002';
    update(["addfriend"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
  }

  void onTapConfirm() {
    if (searchController.text.isEmpty) {
      return;
    }
    searchFriend(searchController.text);
    // 保存一下搜索的值
    searchedUserName = searchController.text;
  }

  /// 搜索好友
  void searchFriend(String username) async {
    searchedUserInfo = await FriendApi.searchFriend(username);
    curStatus = searchedUserInfo == null
        ? SearchStatus.searchedNull
        : SearchStatus.searchedSuccess;
    update(["addfriend"]);
  }

  /// 点击搜索到的用户
  void onTapUserInfo() {
    var userId = searchedUserInfo?.targetUid;
    if (userId == null) {
      return;
    }

    Get.toNamed(
      RouteNames.contactsContactsUserDetail,
      arguments: {
        'userInfo': searchedUserInfo,
        'source': 1, //好友来源 1搜索添加 2二维码 3群聊
        'username': searchedUserName,
      },
    );
  }
}
