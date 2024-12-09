import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_member_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

/// 群数据管理

class GroupManager {
  /// 群列表基础数据
  static List<GroupListModel> _groupBasicList = [];

  /// 群详细数据
  static Map<int, GroupProfile> _groupMap = {};

  /// 群列表
  ///static get groupList => _groupMap.values.toList();
  static List<GroupProfile> get groupList {
    List<GroupProfile> list = _groupMap.values.toList();
    return list;
  }

  /// 刷新所有群数据
  static refreshAllGroup() async {
    // 请求群列表
    _groupBasicList = await GroupApi.groupList();
    for (var group in _groupBasicList) {
      if (group.groupId == null) {
        continue;
      }
      // 请求群数据
      GroupProfile? groupProfile = await GroupApi.groupProfile(group.groupId!);
      if (groupProfile == null) {
        continue;
      }
      // 请求群成员
      List<GroupMemberModel> members =
          await GroupApi.groupMember(group.groupId!);
      if (members.isEmpty) {
        continue;
      }
      groupProfile.members = members;
      _groupMap[group.groupId!] = groupProfile;
    }

    // 订阅群事件
    ImClient.getInstance().subscribeGroupEvent();
  }

  /// 获取指定群数据
  static GroupProfile? groupInfo(int groupID) {
    if (_groupMap.containsKey(groupID)) {
      return _groupMap[groupID];
    } else {
      return null;
    }
  }

  /// 刷新指定群数据
  static Future<GroupProfile?> refreshGroupInfomation(int groupID) async {
    // 请求群数据
    GroupProfile? groupProfile = await GroupApi.groupProfile(groupID);
    if (groupProfile == null) {
      return null;
    }
    // 请求群成员
    List<GroupMemberModel> members = await GroupApi.groupMember(groupID);
    if (members.isEmpty) {
      return null;
    }
    groupProfile.members = members;
    _groupMap[groupID] = groupProfile;

    // 发送刷新事件
    RefreshGroupsEvent refreshGroupEvent = RefreshGroupsEvent(groupId: groupID);
    EventBusUtils.shared.fire(refreshGroupEvent);

    return groupProfile;
  }

  /// 更新群数据,如果原来有这个群，则更新为新数据，如果原来没有，则增加这个新数据
  static bool updateGroup(GroupProfile newGroupInfo) {
    var groupID = newGroupInfo.groupId;
    if (groupID == null) {
      return false;
    }
    // 更新新数据
    _groupMap[groupID] = newGroupInfo;
    // 删除群列表数组中对应项
    for (var model in _groupBasicList) {
      if (model.groupId == groupID) {
        _groupBasicList.remove(model);
        break;
      }
    }
    // 存入新数据
    GroupListModel groupListModel = GroupListModel();
    groupListModel.avatar = newGroupInfo.avatar;
    groupListModel.groupId = newGroupInfo.groupId;
    groupListModel.ownerUid = newGroupInfo.ownerId;
    groupListModel.title = newGroupInfo.title;
    //  groupListModel.memberCount = newGroupInfo.memberCount;
    groupListModel.isOwner = newGroupInfo.isOwner();
    _groupBasicList.add(groupListModel);
    return true;
  }

  /// 删除群数据
  static void removeGroup(int groupId) {
    _groupMap.remove(groupId);
    for (var model in _groupBasicList) {
      if (model.groupId == groupId) {
        _groupBasicList.remove(model);
        return;
      }
    }
  }

  /// 删除多个群成员
  static void removeGroupMembers(int groupId, List<int> memberIds) {
    for (var group in groupList) {
      if (group.groupId == groupId) {
        group.members.removeWhere((e) => memberIds.contains(e.userId));
        break;
      }
    }
  }

  /// 添加多个群成员
  static void addGroupMembers(int groupId, List<GroupMemberModel> members) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        group.members.addAll(members);
        //group.members.removeWhere( (e) => memberIds.contains( e.userId ) );
        break;
      }
    }
  }

  /// 退出群聊
  static void quitGroup(int groupId, int memberId) {
    for (var group in groupList) {
      if (group.groupId == groupId) {
        // 退出的人是自己
        if (memberId == UserService.to.profile.user_id) {
          removeGroup(groupId);
        } else {
          // 不是自己
          group.members.removeWhere((e) => memberId == e.userId);
        }
        break;
      }
    }
  }

  /// 群主转让
  static void transferGroupOwner(int groupId, int newOwnerID) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        for (int i = 0; i < group.members.length; ++i) {
          //if ( group.members[i].userId == souceUserID ) {
          if (group.members[i].role == 1 &&
              group.members[i].userId != newOwnerID) {
            // 旧群主
            group.members[i].role = 3; // 普通成员
          } else if (group.members[i].userId == newOwnerID) {
            //新群主
            group.members[i].role = 1; // 群主
          }
        }
        break;
      }
    }
  }

  /// 更新群内昵称
  static void changeGroupNick(int groupId, int userID, String newNick) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        for (int i = 0; i < group.members.length; ++i) {
          if (group.members[i].userId == userID) {
            group.members[i].nick = newNick;
            break;
          }
        }
        // 如果是自己修改，还要更新self_profile
        if (userID == UserService.to.profile.user_id) {
          group.selfInfo?.nick = newNick;
        }
        break;
      }
    }
  }

  /// 设置群成员角色（1群主，2管理员，3普通成员）
  static void setRole(int groupId, int userID, int role) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        for (int i = 0; i < group.members.length; ++i) {
          if (group.members[i].userId == userID) {
            group.members[i].role = role;
            break;
          }
        }
        break;
      }
    }
  }

  /// 设置群成员单独禁言
  static void setMemberMute(int groupId, int userID, int muteTime) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        for (int i = 0; i < group.members.length; ++i) {
          if (group.members[i].userId == userID) {
            group.members[i].muteUntil = muteTime;
            break;
          }
        }
        break;
      }
    }
  }

  /// 判断自己是否被禁言
  static bool isMuted(int groupId) {
    for (GroupProfile group in groupList) {
      if (group.groupId == groupId) {
        if (group.isMuteAll == 1) {
          return true;
        }
        for (int i = 0; i < group.members.length; ++i) {
          if (group.members[i].userId == UserService.to.profile.user_id) {
            return (group.members[i].muteUntil ?? 0) > 0;
          }
        }
        break;
      }
    }
    return false;
  }
}
