class SessionPinnedModel {
  bool? is_pinned;
  int? session_type;
  int? target_id;

  SessionPinnedModel({
    this.is_pinned,
    this.session_type,
    this.target_id,
  });

  factory SessionPinnedModel.fromJson(Map<String, dynamic> json) =>
      SessionPinnedModel(
        is_pinned: json['is_pinned'] as bool?,
        session_type: json['session_type'] as int?,
        target_id: json['target_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'is_pinned': is_pinned,
        'session_type': session_type,
        'target_id': target_id,
      };
}
