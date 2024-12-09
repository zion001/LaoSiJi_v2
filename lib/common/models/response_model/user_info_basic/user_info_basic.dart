import 'user_profile.dart';

class UserInfoBasic {
  int? targetUid;
  String? remark;
  int? source;
  String? customField;
  String? pinYin;
  bool? relation;
  UserProfile? userProfile;

  UserInfoBasic({
    this.targetUid,
    this.remark,
    this.source,
    this.customField,
    this.pinYin,
    this.relation,
    this.userProfile,
  });

  factory UserInfoBasic.fromJson(Map<String, dynamic> json) => UserInfoBasic(
        targetUid: json['target_uid'] as int?,
        remark: json['remark'] as String?,
        source: json['source'] as int?,
        customField: json['custom_field'] as String?,
        pinYin: json['pin_yin'] as String?,
        relation: json['relation'] as bool?,
        userProfile: json['user_profile'] == null
            ? null
            : UserProfile.fromJson(
                json['user_profile'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'target_uid': targetUid,
        'remark': remark,
        'source': source,
        'custom_field': customField,
        'pin_yin': pinYin,
        'relation': relation,
        'user_profile': userProfile?.toJson(),
      };
}

extension UserInfoBasicExtension on UserInfoBasic {
  bool get isFriend {
    return relation == true;
  }
}
