import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';

import 'message_model.dart';

class ConversationFriendModel {
  int? uid;
  String? remark;
  int? role;
  String? nickname;
  String? avatar;
  String? username;

  ConversationFriendModel(
      {this.uid,
      this.remark,
      this.role,
      this.nickname,
      this.avatar,
      this.username});

  factory ConversationFriendModel.from(
      FriendListItemModel? friendListItemModel) {
    return ConversationFriendModel(
      uid: friendListItemModel?.uid,
      remark: friendListItemModel?.remark,
      role: friendListItemModel?.user_profile?.role,
      nickname: friendListItemModel?.user_profile?.nickname,
      avatar: friendListItemModel?.user_profile?.avatar,
      username: friendListItemModel?.user_profile?.username,
    );
  }

  factory ConversationFriendModel.fromJson(Map<String, dynamic> json) {
    return ConversationFriendModel(
      uid: json['target_uid'] as int?,
      remark: json['remark'] as String?,
      role: json['role'] as int?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'target_uid': uid,
        'remark': remark,
        'role': role,
        'nickname': nickname,
        'avatar': avatar,
        'username': username,
      };
}

class ConversationModel {
  int? clear_msg_time;
  int? created_at;
  ConversationFriendModel? friend_profile;
  GroupProfile? group_profile;
  int? from_uid;
  int? group_id;
  bool? is_pinned;
  MessageModel? last_message_info;
  MessageModel? at_message;
  int? seq_msg_time;
  int? message_remind_type;
  String? session_id;
  int? session_type;
  int? target_uid;
  int? unread_count;

  ConversationModel(
      {this.clear_msg_time,
      this.created_at,
      this.friend_profile,
      this.from_uid,
      this.group_id,
      this.group_profile,
      this.is_pinned,
      this.last_message_info,
      this.seq_msg_time,
      this.message_remind_type,
      this.session_id,
      this.session_type,
      this.target_uid,
      this.unread_count});

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        clear_msg_time: json['clear_msg_time'] as int?,
        created_at: json['created_at'] as int?,
        friend_profile: json['friend_profile'] == null
            ? null
            : ConversationFriendModel.fromJson(json['friend_profile']),
        group_profile: json['group_profile'] == null
            ? null
            : GroupProfile.fromJson(json['group_profile']),
        from_uid: json['from_uid'] as int?,
        is_pinned: json['is_pinned'] as bool?,
        group_id: json['group_id'] as int?,
        last_message_info: json['last_message_info'] == null
            ? null
            : MessageModel.fromJson(json['last_message_info']),
        seq_msg_time: json['seq_msg_time'] as int?,
        message_remind_type: json['message_remind_type'] as int?,
        session_id: json['session_id'] as String?,
        session_type: json['session_type'] as int?,
        target_uid: json['target_uid'] as int?,
        unread_count: json['unread_count'] as int?,
      );
}
