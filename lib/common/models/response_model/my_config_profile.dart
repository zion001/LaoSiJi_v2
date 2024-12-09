class MyConfigProfile {
  int? addFriendConfirm;
  int? allowGroupAddFriend;
  int? findByUsername;
  int? isQrAddFriend;

  MyConfigProfile({
    this.addFriendConfirm,
    this.allowGroupAddFriend,
    this.findByUsername,
    this.isQrAddFriend,
  });

  factory MyConfigProfile.fromJson(Map<String, dynamic> json) {
    return MyConfigProfile(
      addFriendConfirm: json['add_friend_confirm'] as int?,
      allowGroupAddFriend: json['allow_group_add_friend'] as int?,
      findByUsername: json['find_by_username'] as int?,
      isQrAddFriend: json['is_qr_add_friend'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'add_friend_confirm': addFriendConfirm,
        'allow_group_add_friend': allowGroupAddFriend,
        'find_by_username': findByUsername,
        'is_qr_add_friend': isQrAddFriend,
      };
}
