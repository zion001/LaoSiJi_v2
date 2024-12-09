import 'package:im_flutter/common/index.dart';

class UserProfileModel {
  int? user_id;
  String? nickname;
  String? avatar;
  String? username;
  int? role;
  String? customField;
  int? created_at;

  UserProfileModel({
    this.user_id,
    this.nickname,
    this.avatar,
    this.username,
    this.role,
    this.customField,
    this.created_at,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user_id: json['user_id'] as int?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      // avatar: 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${(json['avatar'] as String?) ?? ''}',
      username: json['username'] as String?,
      role: json['role'] as int?,
      customField: json['custom_field'] as String?,
      created_at: json['created_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'nickname': nickname,
        'avatar': avatar,
        'username': username,
        'role': role,
        'custom_field': customField,
        'created_at': created_at,
      };


  /// 是否是系统用户 1 //普通用户 2 //系统用户
  bool isSystemUser() {
    return role == 2;
  }
  
  
}
