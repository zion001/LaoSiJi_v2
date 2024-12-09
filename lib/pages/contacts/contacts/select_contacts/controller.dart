import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class SelectContactsController extends GetxController {
  /// 操作
  int operation = Get.arguments['operation']; // 1 创建群聊 2 添加群成员 3 移除群成员 4 转让群主
  /// 显示标题
  String title = Get.arguments['title'];

  /// 完整数据源(已分组排序)
  List<ContactGroup> allUsers = Get.arguments['allUsersData'];

  /// 不能选择的数据(如拉人入群时已在群内的人员, 踢人出群时自己等)
  List<int> notAllowedUsers = Get.arguments['notAllowedUsers'];

  /// 群ID (拉人,T人时需要)
  int groupID = Get.arguments['groupID'];

  /// 已选中数量
  ///int selectedCount = 0;
  /// 已选中成员的UID
  List<int> selectedMemberUid = <int>[];

  SelectContactsController();

  _initData() {
    // 处理不可选择用户
    for (var group in allUsers) {
      for (var user in group.list) {
        if (notAllowedUsers.contains(user.uid!)) {
          user.selectedStatus = -1;
        }
      }
    }

    update(["select_contacts"]);
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

  void onTapContact(FriendListItemModel friend) {
    // 转让群主，只能选一个人, 先将其它选中的人清空
    if (operation == 4) {
      for (int i = 0; i < allUsers.length; ++i) {
        for (int j = 0; j < allUsers[i].list.length; ++j) {
          if (allUsers[i].list[j].selectedStatus == 1) {
            selectedMemberUid.add(allUsers[i].list[j].uid ?? 0);
          }
        }
      }
    }

    if ((friend.selectedStatus ?? 0) == 0) {
      friend.selectedStatus = 1;
    } else if (friend.selectedStatus == 1) {
      friend.selectedStatus = 0;
    } else {
      return;
    }
    selectedMemberUid.clear(); // 统计选中的UID
    for (int i = 0; i < allUsers.length; ++i) {
      for (int j = 0; j < allUsers[i].list.length; ++j) {
        if (allUsers[i].list[j].uid == friend.uid) {
          allUsers[i].list[j] = friend;
        }
        if (allUsers[i].list[j].selectedStatus == 1) {
          selectedMemberUid.add(allUsers[i].list[j].uid ?? 0);
        }
      }
    }

    update(["select_contacts"]);
  }

  /// 点击确定
  Future<void> onSubmitTapped() async {
    //如果是创建群聊，至少选择2个人（5.23改为一人也可以建群）
    if (operation == 1) {
      if (selectedMemberUid.isEmpty) {
        Loading.error('请先选择联系人');
        return;
      }
      Get.toNamed(RouteNames.groupMyGroupSetGroupName, arguments: {
        'operation': 1,
        'selectedMembers': selectedMemberUid,
        'groupProfile': GroupProfile(), // 无效
      });
    } else if (operation == 2) {
      // 添加群成员
      if (selectedMemberUid.isEmpty) {
        Loading.error('请选反至少1个联系人');
        return;
      }
      GroupRemoveMemberModel? model =
          await GroupApi.addGroupMembers(groupID, selectedMemberUid);
      if (model == null) {
      } else {
        // 将选中的联系人Model转为群成员MODEL
        List<GroupMemberModel> newMembers = <GroupMemberModel>[];
        for (var group in allUsers) {
          for (FriendListItemModel contact in group.list) {
            if (model.successIds!.contains(contact.uid ?? 0)) {
              // GroupMemberModel member = GroupMemberModel(model.user_profile.avatar, muteUntil: 0, nick: model.user_profile.nick)
              GroupMemberModel member = GroupMemberModel();
              member.avatar = contact.user_profile?.avatar;
              member.muteUntil = 0;
              member.nick = contact.user_profile?.nickname;
              member.nickname = contact.user_profile?.nickname;
              member.role = 3;
              member.userId = contact.uid;
              newMembers.add(member);
            }
          }
        }
        GroupManager.addGroupMembers(groupID, newMembers);
        //GroupManager.removeGroupMembers(groupID, model.successIds!);
        Get.back();
        // 发送刷新事件
        RefreshGroupsEvent refreshGroupEvent =
            RefreshGroupsEvent(groupId: groupID);
        EventBusUtils.shared.fire(refreshGroupEvent);
      }
    } else if (operation == 3) {
      //  移除群成员
      if (selectedMemberUid.isEmpty) {
        Loading.error('请选反至少1个联系人');
        return;
      }
      GroupRemoveMemberModel? model =
          await GroupApi.removeGroupMembers(groupID, selectedMemberUid);
      if (model == null) {
      } else {
        GroupManager.removeGroupMembers(groupID, model.successIds!);
        Get.back();
        // 发送刷新事件
        RefreshGroupsEvent refreshGroupEvent =
            RefreshGroupsEvent(groupId: groupID);
        EventBusUtils.shared.fire(refreshGroupEvent);
      }
    } else if (operation == 4) {
      if (selectedMemberUid.length > 1) {
        Loading.error('转让群主只能选一个对象');
        return;
      }
      if (selectedMemberUid.isEmpty) {
        Loading.error('请先选择新群主');
        return;
      }
      Loading.show();
      // 转让群主
      bool success =
          await GroupApi.transferGroup(groupID, selectedMemberUid.first);
      Loading.dismiss();
      if (success) {
        // 修改GROUP成员数据
        //transferGroupOwner
        //GroupManager.transferGroupOwner(groupID, /*UserService.to.profile.user_id ?? 0,*/ selectedMemberUid.first);
        GroupManager.transferGroupOwner(groupID, selectedMemberUid.first);

        // 发送刷新事件
        RefreshGroupsEvent refreshGroupEvent =
            RefreshGroupsEvent(groupId: groupID);
        EventBusUtils.shared.fire(refreshGroupEvent);
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    // 清除选中状态
    for (int i = 0; i < allUsers.length; ++i) {
      for (int j = 0; j < allUsers[i].list.length; ++j) {
        allUsers[i].list[j].selectedStatus = 0;
      }
    }
    selectedMemberUid.clear();
    super.onClose();
  }

  // 全选
  void onTapSelectAll(){
    selectedMemberUid.clear();
    for (int i = 0; i < allUsers.length; ++i) {
      for (int j = 0; j < allUsers[i].list.length; ++j) {
        allUsers[i].list[j].selectedStatus = 1;
        selectedMemberUid.add(allUsers[i].list[j].uid ?? 0);
      }
    }
    update(["select_contacts"]);
  }

  //全消
  void onTapCancelAll(){
    for (int i = 0; i < allUsers.length; ++i) {
      for (int j = 0; j < allUsers[i].list.length; ++j) {
        allUsers[i].list[j].selectedStatus = 0;
      }
    }
    selectedMemberUid.clear();
    update(["select_contacts"]);
  }

}
