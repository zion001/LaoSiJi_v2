import 'dart:ffi';

import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_member_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

class GroupApi {
  /// 创建群聊
  static Future<CreatGroupResultModel?> createGroup(
      String avatar, String groupName, List<int> members) async {
    Resource res = await HttpUtil.post(
      'group/createGroup',
      params: {"title": groupName, 'avatar': avatar, 'member_ids': members},
    );

    if (res.isSuccess()) {
      CreatGroupResultModel model = CreatGroupResultModel.fromJson(res.data);
      return model;
    } else {
      return null;
    }
  }

  /// 解散群聊
  static Future<bool> dissmisGroup(int groupID) async {
    Resource res = await HttpUtil.post(
      'group/dismissGroup',
      params: {'group_id': groupID},
    );

    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 退出群聊
  static Future<bool> quitGroup(int groupID) async {
    Resource res = await HttpUtil.post(
      'group/quitGroup',
      params: {'group_id': groupID},
    );

    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 获取群列表
  static Future<List<GroupListModel>> groupList() async {
    Resource res = await HttpUtil.get(
      'group/getGroupList',
    );

    if (res.isSuccess()) {
      List list = res.data as List;
      List<GroupListModel> groups =
          list.map((e) => GroupListModel.fromJson(e)).toList();
      return groups;
    } else {
      Loading.error(res.message);
      return <GroupListModel>[];
    }
  }

  /// 获取群信息
  static Future<GroupProfile?> groupProfile(int groupId) async {
    Resource res = await HttpUtil.get(
      'group/getGroupProfile',
      params: {"group_id": groupId},
    );

    if (res.isSuccess()) {
      GroupProfile model = GroupProfile.fromJson(res.data);
      return model;
    } else {
      return null;
    }
  }

  /// 获取群成员列表
  static Future<List<GroupMemberModel>> groupMember(int groupID) async {
    Resource res = await HttpUtil.get(
      'group/getGroupMemberList',
      params: {'group_id': groupID},
    );

    if (res.isSuccess()) {
      List list = res.data as List;
      List<GroupMemberModel> members =
          list.map((e) => GroupMemberModel.fromJson(e)).toList();
      return members;
    } else {
      Loading.error(res.message);
      return <GroupMemberModel>[];
    }
  }

  /// 修改群昵称
  static Future<bool> setGroupNick(int groupId, String nick) async {
    Resource res = await HttpUtil.post(
      'group/setGroupMemberNick',
      params: {
        "group_id": groupId,
        "nick": nick,
      },
    );

    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 修改群名称
  static Future<bool> setGroupTitle(int groupId, String title) async {
    var success = await _setGroupProfile({'group_id': groupId, 'title': title});
    return success;
  }

  /// 修改群头像
  static Future<bool> setGroupAvatar(int groupId, String avatar) async {
    var success =
        await _setGroupProfile({'group_id': groupId, 'avatar': avatar});
    return success;
  }

  /// 全员禁言
  static Future<bool> setGroupMuteAll(int groupId, int isMuteAll) async {
    var success = await _setGroupProfile({
      'group_id': groupId,
      'config': {'is_mute_all': isMuteAll}
    });
    return success;
  }

  /// 修改群信息(群名称/群头像/群配置/全员禁言/加群方式/是否开启成员保护)
  static Future<bool> _setGroupProfile(Map<String, dynamic> params) async {
    Resource res = await HttpUtil.post(
      'group/setGroupProfile',
      params: params,
    );
    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 移除群成员
  static Future<GroupRemoveMemberModel?> removeGroupMembers(
      int groupId, List<int> memberIds) async {
    Resource res = await HttpUtil.post(
      'group/deleteGroupMember',
      params: {
        "group_id": groupId,
        "member_ids": memberIds,
      },
    );

    if (res.isSuccess()) {
      GroupRemoveMemberModel model = GroupRemoveMemberModel.fromJson(res.data);
      return model;
    } else {
      return null;
    }
  }

  /// 添加群成员
  static Future<GroupRemoveMemberModel?> addGroupMembers(
      int groupId, List<int> memberIds) async {
    Resource res = await HttpUtil.post(
      'group/addGroupMember',
      params: {
        "group_id": groupId,
        "member_ids": memberIds,
      },
    );

    if (res.isSuccess()) {
      GroupRemoveMemberModel model = GroupRemoveMemberModel.fromJson(res.data);
      return model;
    } else {
      return null;
    }
  }

  /// 设置群成员禁言
  static Future<bool> setMemberMute(
      int groupId, int memberId, bool mute) async {
    Resource res = await HttpUtil.post(
      'group/setGroupMemberMuteTime',
      params: {
        "group_id": groupId,
        "member_id": memberId,
        "mute_until": mute ? 10000000 : 0,
      },
    );
    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 转让群主
  static Future<bool> transferGroup(int groupId, int newOwnerId) async {
    Resource res = await HttpUtil.post(
      'group/changeGroupOwner',
      params: {
        "group_id": groupId,
        "new_owner_id": newOwnerId,
      },
    );
    if (res.isSuccess()) {
      return true;
    } else {
      Loading.error(res.message ?? '');
      return false;
    }
  }

  /// 设置/取消 成员角色
  static Future<bool> setGroupMemberRole(
      int groupId, int memberId, int role) async {
    Resource res = await HttpUtil.post(
      'group/setGroupMemberRole',
      params: {"group_id": groupId, "member_id": memberId, "role": role},
    );
    if (res.isSuccess()) {
      return true;
    } else {
      Loading.error(res.message ?? '');
      return false;
    }
  }

  /// 发布群公告
  static Future<bool> setGroupNotice(int groupId, String notice) async {
    Resource res = await HttpUtil.post(
      'group/setGroupNotice',
      params: {"group_id": groupId, "notice": notice},
    );
    if (res.isSuccess()) {
      return true;
    } else {
      Loading.error(res.message ?? '');
      return false;
    }
  }
}
