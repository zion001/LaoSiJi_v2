import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class GroupDetailController extends GetxController {
  // GroupID
  late GroupProfile? groupProfile = Get.arguments['groupProfile'];

  ConversationModel? conversationModel;

  StreamSubscription? subscription;

  GroupDetailController();

  _initData() {
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      print('收到刷新事件');
      if (event.groupId != (groupProfile?.groupId ?? 0)) {
        return;
      }
      groupProfile = GroupManager.groupInfo(groupProfile?.groupId ?? 0);
      update(["group_detail"]);
    });

    conversationModel =
        ConversationManager.getConversationModel(groupProfile?.groupId ?? 0);

    update(["group_detail"]);
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
    subscription?.cancel();
  }
/*
  /// 请求群信息
  Future<void> getGroupProfile(int groupId) async {
    groupProfile = await GroupApi.groupProfile(groupId);
    update(["group_detail"]);
  }
  */

  /// 群公告
  ///
  /// 群管理
  ///
  /// 置顶聊天
  ///
  /// 我在本群的昵称
  Future<void> onListTapped(String? title) async {
    bool isOwner = groupProfile?.isOwner() ?? false;
    bool isManager = groupProfile?.isManager() ?? false;

    switch (title) {
      case '群名称':
        if (!isOwner && !isManager) {
          Loading.error('群主和管理员才能修改群名称');
          return;
        }
        Get.toNamed(RouteNames.groupMyGroupSetGroupName, arguments: {
          'operation': 2,
          'selectedMembers': <int>[],
          'groupProfile': groupProfile, // 无效
        });
        update(["group_detail"]);
        break;
      case '群公告':
        if ((groupProfile?.isOwner() ?? false) ||
            (groupProfile?.isManager() ?? false)) {
          Get.toNamed(RouteNames.groupMyGroupSetGroupNotice, arguments: {
            'groupProfile': groupProfile,
          });
        } else {
          Get.toNamed(RouteNames.groupMyGroupShowGroupNotice, arguments: {
            'groupProfile': groupProfile,
          });
        }
        break;
      case '我在本群的昵称':
        final result = await Get.toNamed(RouteNames.groupMyGroupChangeGroupNick,
            arguments: {'group': groupProfile});
        groupProfile?.selfInfo?.nick = result;
        update(["group_detail"]);
        break;
      case '群管理':
        int? groupID = groupProfile?.groupId;
        if (groupID != null) {
          Get.toNamed(RouteNames.groupMyGroupGroupManage,
              arguments: {'groupProfile': groupProfile!});
        }
        break;
      default:
        //Loading.toast(title ?? '开发中');
        break;
    }
  }

  /// 置顶聊天
  void onTapPin(bool value) {
    if (conversationModel == null) {
      return;
    }
    var sessionId = conversationModel!.group_id;
    ConversationManager.setSessionPinned(
        conversationModel!.session_type!, sessionId!, value);

    conversationModel?.is_pinned = value;
    update(["group_detail"]);
  }

  /// 清空聊天记录
  ///
  void clearHistoryMessage() {
    ImDialog.confirmDialog('提示', '清空聊天记录?', () async{
      int conversationType = 2;
      int sessionId = conversationModel!.group_id!;
      PayloadModel payloadModel = await ConversationManager.clearHistoryMessage(conversationType, sessionId);
      if(payloadModel.error_code == 0) {
        Loading.success('已清空聊天记录');
      }else{
        Loading.error(payloadModel.error_msg);
      }
    });

  }

  /// 解散群聊
  Future<void> onDissmisGroupTapped() async {
    if (groupProfile?.isOwner() ?? false) {
      ImDialog.confirmDialog('提示', '您确定要解散此群吗?', () {
        dismissGroup();
      });
    } else {
      ImDialog.confirmDialog('提示', '您确定要退出此群吗?', () {
        quitGroup();
      });
    }

    /*
    Loading.show();
    bool success = await GroupApi.dissmisGroup(groupProfile?.groupId ?? 0);
    if (success) {
      Loading.dismiss();
      GroupManager.removeGroup(groupProfile?.groupId ?? 0);
      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);

      Get.back();
    } else {
      Loading.error('操作失败，请重试。');
    }
    */
  }

  /// 退出群组
  void quitGroup() async {
    Loading.show();
    bool success = await GroupApi.quitGroup(groupProfile?.groupId ?? 0);
    if (success) {
      Loading.dismiss();
      GroupManager.removeGroup(groupProfile?.groupId ?? 0);
      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);

      Get.back();
      Get.back();
    } else {
      Loading.error('操作失败，请重试。');
    }
  }

  /// 解散群群
  void dismissGroup() async {
    Loading.show();
    bool success = await GroupApi.dissmisGroup(groupProfile?.groupId ?? 0);
    if (success) {
      Loading.dismiss();
      GroupManager.removeGroup(groupProfile?.groupId ?? 0);
      // 发送刷新事件
      RefreshGroupsEvent refreshGroupEvent =
          RefreshGroupsEvent(groupId: groupProfile?.groupId ?? 0);
      EventBusUtils.shared.fire(refreshGroupEvent);

      Get.back();
      Get.back();
    } else {
      Loading.error('操作失败，请重试。');
    }
  }

  /// 添加成员
  void onTapAddMembers() {
    // 已在群内人员
    var notAllowedUsers =
        groupProfile?.members.map((e) => e.userId ?? 0).toList() ?? <int>[];

    Get.toNamed(
      RouteNames.contactsContactsSelectContacts,
      arguments: {
        'operation': 2,
        'title': '添加群成员',
        'allUsersData': ContactsManager.friendGroupList, //当前群内成员
        'notAllowedUsers': notAllowedUsers, //移出群成员时，不可移出自己，或者不可移出群主，
        'groupID': groupProfile?.groupId ?? 0, // 创建群时无效
      },
    );
  }

  /// 移除成员
  Future<void> onTapRemoveMembers() async {
    // 将群成员转为联系人模型
    var members = groupProfile!.members
        .map((e) => FriendListItemModel(
            uid: e.userId,
            remark: e.nick,
            source: -1,
            pinYin: '请选择',
            relation: false,
            isOnline: false,
            user_profile: Profile(
                avatar: e.avatar,
                nickname: e.nickname,
                username: '',
                role: e.role,
                custom_field: ''),
            custom_field: ''))
        .toList();

    ContactGroup group = ContactGroup(groupTitle: '请选择', list: members);

    // 自己和群主
    var notAllowedUsers = [UserService.to.profile.user_id!]; //自己
    for (var member in (groupProfile?.members ?? <GroupMemberModel>[])) {
      if (member.role == 1) {
        if (!notAllowedUsers.contains(member.userId!)) {
          notAllowedUsers.add(member.userId!);
        }
      }
    }

    Get.toNamed(
      RouteNames.contactsContactsSelectContacts,
      arguments: {
        'operation': 3,
        'title': '移出群成员',
        'allUsersData': [group], //ContactsManager.friendGroupList, //当前群内成员
        'notAllowedUsers': notAllowedUsers, //移出群成员时，不可移出自己，或者不可移出群主，
        'groupID': groupProfile?.groupId ?? 0, // 创建群时无效
      },
    );
  }
}
