class FriendApplyModel {
  int? applyId;
  int? userId;
  String? nickname;
  String? avatar;
  String? remark;
  int? source;
  String? customField;
  int? createdAt;

  FriendApplyModel({
    this.applyId,
    this.userId,
    this.nickname,
    this.avatar,
    this.remark,
    this.source,
    this.customField,
    this.createdAt,
  });

  factory FriendApplyModel.fromJson(Map<String, dynamic> json) {
    return FriendApplyModel(
      applyId: json['apply_id'] as int?,
      userId: json['user_id'] as int?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      remark: json['remark'] as String?,
      source: json['source'] as int?,
      customField: json['custom_field'] as String?,
      createdAt: json['created_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'apply_id': applyId,
        'user_id': userId,
        'nickname': nickname,
        'avatar': avatar,
        'remark': remark,
        'source': source,
        'custom_field': customField,
        'created_at': createdAt,
      };
}

extension FriendApplyModelExtension on FriendApplyModel {
  String sourceDesc() {
    switch (source) {
      case 1:
        return '搜索用户名';
      case 2:
        return '扫二维码';
      case 3:
        return '群聊';
      default:
        return '未知渠道: $source';
    }
  }
}
