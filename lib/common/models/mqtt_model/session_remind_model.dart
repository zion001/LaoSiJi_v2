class SessionRemindModel {
  int? remind_type;
  int? session_type;
  int? target_id;

  SessionRemindModel({
    this.remind_type,
    this.session_type,
    this.target_id,
  });

  factory SessionRemindModel.fromJson(Map<String, dynamic> json) =>
      SessionRemindModel(
        remind_type: json['remind_type'] as int?,
        session_type: json['session_type'] as int?,
        target_id: json['target_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'remind_type': remind_type,
        'session_type': session_type,
        'target_id': target_id,
      };
}
