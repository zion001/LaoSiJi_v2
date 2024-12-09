class ReadUserIdModel {
  int? read_time;
  int? user_id;

  ReadUserIdModel({
    this.read_time,
    this.user_id,
  });

  factory ReadUserIdModel.fromJson(Map<String, dynamic> json) =>
      ReadUserIdModel(
        read_time: json['read_time'] as int?,
        user_id: json['user_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'read_time': read_time,
        'user_id': user_id,
      };
}
