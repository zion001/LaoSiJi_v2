import 'package:get/get.dart';

import 'profile.dart';

class FriendListItemModel {
  int? uid = 0;
  String? remark;
  int? source;
  String? pinYin;
  bool? relation;
  bool? isOnline;
  Profile? user_profile;
  String? custom_field;

  // 增加一个选中状态
  int? selectedStatus = 0; // 0 未选中， 1 已选中， -1 禁止选择（如拉人入群时，已在群内的成员）

  FriendListItemModel({
    this.uid,
    this.remark,
    this.source,
    this.pinYin,
    this.relation,
    this.isOnline,
    this.user_profile,
    this.custom_field,
    this.selectedStatus,
  });

  factory FriendListItemModel.fromJson(Map<String, dynamic> json) {
    return FriendListItemModel(
      uid: json['target_uid'] as int?,
      remark: json['remark'] as String?,
      source: json['source'] as int?,
      pinYin: json['pin_yin'] as String?,
      relation: json['relation'] as bool?,
      isOnline: json['isOnline'] as bool?,
      user_profile: json['user_profile'] == null
          ? null
          : Profile.fromJson(json['user_profile'] as Map<String, dynamic>),
      custom_field: json['custom_field'] as String?,
      selectedStatus: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'target_uid': uid,
        'remark': remark,
        'source': source,
        'pin_yin': pinYin,
        'relation': relation,
        'isOnline': isOnline,
        'user_profile': user_profile?.toJson(),
        'custom_field': custom_field,
      };
}
