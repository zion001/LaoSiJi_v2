class Profile {
  String? nickname;
  String? avatar;
  String? username;
  int? role;
  String? custom_field;

  Profile(
      {this.nickname,
      this.avatar,
      this.username,
      this.role,
      this.custom_field});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        username: json['username'] as String?,
        role: json['role'] as int?,
        custom_field: json['custom_field'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'avatar': avatar,
        'username': username,
        'role': role,
        'custom_field': custom_field,
      };
}
