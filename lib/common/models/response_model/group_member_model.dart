import 'package:im_flutter/common/index.dart';

/// 群成员
class GroupMemberModel {
  String? avatar;
  int? muteUntil;
  String? nick;
  String? nickname;
  int? role;
  int? user_role;
  int? userId;

  GroupMemberModel({
    this.avatar,
    this.muteUntil,
    this.nick,
    this.nickname,
    this.role,
    this.user_role,
    this.userId,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      avatar: json['avatar'] as String?,
      //avatar: 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${(json['avatar'] as String?) ?? ''}',
      muteUntil: json['mute_until'] as int?,
      nick: json['nick'] as String?,
      nickname: json['nickname'] as String?,
      role: json['role'] as int?,
      user_role: json['user_role'] as int?,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'mute_until': muteUntil,
        'nick': nick,
        'nickname': nickname,
        'role': role,
        'user_role': user_role,
        'user_id': userId,
      };
}
