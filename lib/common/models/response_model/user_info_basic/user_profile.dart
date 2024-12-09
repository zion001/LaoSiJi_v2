import 'package:im_flutter/common/index.dart';

class UserProfile {
  String? nickname;
  String? avatar;
  int? role;
  String? customField;

  UserProfile({this.nickname, this.avatar, this.role, this.customField});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        //avatar: 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${(json['avatar'] as String?) ?? ""}',
        role: json['role'] as int?,
        customField: json['custom_field'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'avatar': avatar,
        'role': role,
        'custom_field': customField,
      };
}
