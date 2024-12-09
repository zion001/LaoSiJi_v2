class Profile {
  int? uid;
  String? nickname;
  String? avatar;
  String? username;

  Profile({this.uid, this.nickname, this.avatar, this.username});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        uid: json['uid'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        username: json['username'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nickname': nickname,
        'avatar': avatar,
        'username': username,
      };
}
