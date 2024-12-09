import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:uuid/uuid.dart';

class ChatSelectContactController extends GetxController {
  ChatSelectContactController();
  TextEditingController searchController = TextEditingController();


  _initData() async {
    update(["chat_select_contact"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void searchChanged(String searchWord) {
    update(["chat_select_contact"]);
  }

  /// 点击联系人
  void onTapContact(FriendListItemModel friend) async{

    Get.back(result:friend);
  }

}
