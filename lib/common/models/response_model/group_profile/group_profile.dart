import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_member_model.dart';

import 'self_info.dart';

class GroupProfile {
  String? avatar;
  int? groupId;
  int? isMuteAll;
  int? isProtectMember;
  int? joinOption;
  int? maxMemberCount;
// int? memberCount; 放弃这个参数，直接用members.length
  String? notice;
  int? ownerId;
  SelfInfo? selfInfo;
  int? status;
  String? title;

  //加入群成员列表
  List<GroupMemberModel> members = [];

  GroupProfile({
    this.avatar,
    this.groupId,
    this.isMuteAll,
    this.isProtectMember,
    this.joinOption,
    this.maxMemberCount,
//    this.memberCount,
    this.notice,
    this.ownerId,
    this.selfInfo,
    this.status,
    this.title,
  });

  factory GroupProfile.fromJson(Map<String, dynamic> json) => GroupProfile(
        avatar: json['avatar'] as String?,
        //avatar: 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${(json['avatar'] as String?) ?? ""}',
        groupId: json['group_id'] as int?,
        isMuteAll: json['is_mute_all'] as int?,
        isProtectMember: json['is_protect_member'] as int?,
        joinOption: json['join_option'] as int?,
        maxMemberCount: json['max_member_count'] as int?,
//        memberCount: json['member_count'] as int?,
        notice: json['notice'] as String?,
        ownerId: json['owner_id'] as int?,
        selfInfo: json['self_info'] == null
            ? null
            : SelfInfo.fromJson(json['self_info'] as Map<String, dynamic>),
        status: json['status'] as int?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'group_id': groupId,
        'is_mute_all': isMuteAll,
        'is_protect_member': isProtectMember,
        'join_option': joinOption,
        'max_member_count': maxMemberCount,
//        'member_count': memberCount,
        'notice': notice,
        'owner_id': ownerId,
        'self_info': selfInfo?.toJson(),
        'status': status,
        'title': title,
      };
}

extension GroupProfileExtensions on GroupProfile {
  // 是否是群主
  // 参数： userID 自己传null，群成员则传user_id
  bool isOwner({int? userID}) {
    if (userID == null) {
      return selfInfo?.role == 1;
    }
    for (var member in members) {
      if (member.userId == userID) {
        return member.role == 1;
      }
    }
    return false;
  }

  // 是否是管理员
  // 参数： userID 自己传null，群成员则传user_id
  bool isManager({int? userID}) {
    if (userID == null) {
      return selfInfo?.role == 2;
    }
    for (var member in members) {
      if (member.userId == userID) {
        return member.role == 2;
      }
    }
    return false;
  }
}
