class UserStateModel{
  int? user_id;
  String? device;
  int? login_id;
  int? last_login_at;
  String? last_ip;
  int? offline_at;
  int? status;

  UserStateModel({
    this.user_id,
    this.device,
    this.login_id,
    this.last_login_at,
    this.last_ip,
    this.offline_at,
    this.status,
  });

  factory UserStateModel.fromJson(Map<String, dynamic> json) =>
      UserStateModel(
        user_id: json['user_id'] as int?,
        device: json['device'] as String?,
        login_id: json['login_id'] as int?,
        last_login_at: json['last_login_at'] as int?,
        last_ip: json['last_ip'] as String?,
        offline_at: json['offline_at'] as int?,
        status: json['status'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'user_id': user_id,
    'device': device,
    'login_id': login_id,
    'last_login_at': last_login_at,
    'last_ip': last_ip,
    'offline_at': offline_at,
    'status': status,
  };
}

class MemberStateModel {
  UserStateModel? recent;
  List<UserStateModel>? states;

  MemberStateModel({
    this.recent,
    this.states,

  });

  factory MemberStateModel.fromJson(Map<String, dynamic> json) =>
      MemberStateModel(
        recent: json['recent'] == null
            ? null
            : UserStateModel.fromJson(json['recent']),
        states: json['states'] == null
            ? null
            : ([]..addAll((json?['states'] as List ?? [])
            .map((o) => UserStateModel.fromJson(o)))),

      );

  Map<String, dynamic> toJson() => {
    'recent': recent?.toJson(),
    'states': states?.map((e) => e.toJson()).toList(),

  };
}