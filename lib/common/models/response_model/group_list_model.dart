/// 群列表
///
class GroupListModel {
  int? groupId;
  int? ownerUid;
  String? title;
  String? avatar;
  int? memberCount;
  bool? isOwner;

  GroupListModel({
    this.groupId,
    this.ownerUid,
    this.title,
    this.avatar,
    this.memberCount,
    this.isOwner,
  });

  factory GroupListModel.fromJson(Map<String, dynamic> json) {
    return GroupListModel(
      groupId: json['group_id'] as int?,
      ownerUid: json['owner_uid'] as int?,
      title: json['title'] as String?,
      avatar: json['avatar'] as String?,
      memberCount: json['member_count'] as int?,
      isOwner: json['is_owner'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'owner_uid': ownerUid,
        'title': title,
        'avatar': avatar,
        'member_count': memberCount,
        'is_owner': isOwner,
      };
}
