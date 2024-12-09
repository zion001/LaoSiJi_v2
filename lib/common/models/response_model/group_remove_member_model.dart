class GroupRemoveMemberModel {
  List<int>? failureIds;
  List<int>? successIds;

  GroupRemoveMemberModel({this.failureIds, this.successIds});

  factory GroupRemoveMemberModel.fromJson(Map<String, dynamic> json) {
    var model = GroupRemoveMemberModel();
    model.successIds = List<int>.from(json['success_ids']);
    model.failureIds = List<int>.from(json['failure_ids']);
    return model;
  }

  Map<String, dynamic> toJson() => {
        'failure_ids': failureIds,
        'success_ids': successIds,
      };
}
