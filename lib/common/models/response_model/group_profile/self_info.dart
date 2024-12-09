class SelfInfo {
  String? avatar;
  int? muteUntil;
  String? nick;
  String? nickname;
  int? role;
  int? userId;

  SelfInfo({
    this.avatar,
    this.muteUntil,
    this.nick,
    this.nickname,
    this.role,
    this.userId,
  });

  factory SelfInfo.fromJson(Map<String, dynamic> json) => SelfInfo(
        avatar: json['avatar'] as String?,
        muteUntil: json['mute_until'] as int?,
        nick: json['nick'] as String?,
        nickname: json['nickname'] as String?,
        role: json['role'] as int?,
        userId: json['user_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'mute_until': muteUntil,
        'nick': nick,
        'nickname': nickname,
        'role': role,
        'user_id': userId,
      };
}
