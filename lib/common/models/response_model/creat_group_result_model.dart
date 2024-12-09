class CreatGroupResultModel {
  int? groupId;

  CreatGroupResultModel({this.groupId});

  factory CreatGroupResultModel.fromJson(Map<String, dynamic> json) {
    return CreatGroupResultModel(
      groupId: json['group_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
      };
}
