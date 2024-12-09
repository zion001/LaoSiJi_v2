import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/common/events/event_bus_utils.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:im_flutter/common/routers/index.dart';

class GroupManageController extends GetxController {
  final GroupProfile? groupProfile = Get.arguments['groupProfile'];
  StreamSubscription? subscription;

  GroupManageController();

  _initData() {
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      print('收到刷新事件');
      update(["group_manage"]);
    });

    update(["group_manage"]);
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
  /// 头像
  Future<void> onGroupAvatarTapped() async {
    await Get.toNamed(RouteNames.groupMyGroupSetGroupAvatar, arguments: {
      'operation': 2,
      'selectedMembers': <int>[],
      'groupName': groupProfile?.title ?? '',
      'groupProfile': groupProfile
    });
    update(["group_manage"]);
  }

  /// 群主转让
  void onGroupOwnerTransferTapped() {
    if (groupProfile == null) {
      return;
    }

    // 将群成员转为联系人模型
    var members = groupProfile!.members
        .map((e) => FriendListItemModel(
            uid: e.userId,
            remark: e.nick,
            source: -1,
            pinYin: '请选择新群主',
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
    var notAllowedUsers = <int>[]; //群主
    for (var member in (groupProfile?.members ?? <GroupMemberModel>[])) {
      if (member.user_role != 2) { // 1普通用户 2系统用户
        notAllowedUsers.add(member.userId!);
        continue;
      }
      if (member.role == 1) {
        if (!notAllowedUsers.contains(member.userId!)) {
          notAllowedUsers.add(member.userId!);
        }
      }
    }

    Get.toNamed(
      RouteNames.contactsContactsSelectContacts,
      arguments: {
        'operation': 4,
        'title': '群主转让',
        'allUsersData': [group], //ContactsManager.friendGroupList, //当前群内成员
        'notAllowedUsers': notAllowedUsers, //移出群成员时，不可移出自己，或者不可移出群主，
        'groupID': groupProfile?.groupId ?? 0, // 创建群时无效
      },
    );
  }

  /// 群成员配置
  void onGroupMemberManageTapped() {
    if (groupProfile == null) {
      return;
    }
    Get.toNamed(RouteNames.groupMyGroupGroupManageGroupMemberSetting,
        arguments: {'groupProfile': groupProfile});
  }
}
