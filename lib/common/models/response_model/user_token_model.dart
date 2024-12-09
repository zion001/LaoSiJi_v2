class UserTokenModel {
  String? accessToken;
  int? accessExpire;
  int? refreshAfter;
  int? loginId;

  UserTokenModel({
    this.accessToken,
    this.accessExpire,
    this.refreshAfter,
    this.loginId,
  });

  factory UserTokenModel.fromJson(Map<String, dynamic> json) {
    return UserTokenModel(
      accessToken: json['access_token'] as String?,
      accessExpire: json['access_expire'] as int?,
      refreshAfter: json['refresh_after'] as int?,
      loginId: json['login_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'access_expire': accessExpire,
        'refresh_after': refreshAfter,
        'login_id': loginId,
      };
}
