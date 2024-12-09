import 'msg_body_model.dart';
import 'read_userid_model.dart';

enum MessageStatus {
  success,
  sending,
  failure,
}

extension MessageStatusNumber on MessageStatus {
  int get number {
    switch (this) {
      case MessageStatus.success:
        return 0;
      case MessageStatus.sending:
        return 1;
      case MessageStatus.failure:
        return 2;
    }
  }
}

class MessageModel {
  String? message_id;
  int? from_uid;
  int? target_uid;
  int? group_id;
  String? session_id;
  int? session_type;
  MsgBodyModel? msg_body;
  int? status;
  bool? is_revoke;
  bool? is_pinned;
  int? created_at;
  int? updated_at;
  int? expire_at;
  List? hide_user_ids;
  List<ReadUserIdModel>? read_user_ids;


  MessageModel(
      {this.message_id,
      this.from_uid,
      this.target_uid,
      this.group_id,
      this.session_id,
      this.session_type,
      this.msg_body,
      this.status,
      this.is_revoke,
      this.is_pinned,
      this.created_at,
      this.updated_at,
      this.expire_at,
      this.hide_user_ids,
      this.read_user_ids,

      });

  factory MessageModel.from(MessageModel? copy){
    return MessageModel(
      message_id: copy?.message_id,
      from_uid: copy?.from_uid,
      target_uid: copy?.target_uid,
      group_id: copy?.group_id,
      session_id: copy?.session_id,
      session_type: copy?.session_type,
      msg_body: MsgBodyModel.copyFrom(copy?.msg_body),
      status: copy?.status,
      is_revoke: copy?.is_revoke,
      is_pinned: copy?.is_pinned,
      created_at: copy?.created_at,
      updated_at: copy?.updated_at,
      expire_at: copy?.expire_at,
      hide_user_ids: copy?.hide_user_ids,
      read_user_ids: copy?.read_user_ids,

    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        message_id: json['message_id'] ?? json['_id'],
        from_uid: json['from_uid'] as int?,
        target_uid: json['target_uid'] as int?,
        group_id: json['group_id'] as int?,
        session_id: json['session_id'] as String?,
        session_type: json['session_type'] as int?,
        msg_body: json['msg_body'] == null
            ? null
            : MsgBodyModel.fromJson(json['msg_body']),
        status: json['status'] as int?,
        is_revoke: json['is_revoke'] as bool?,
        is_pinned: json['is_pinned'] as bool?,
        created_at: json['created_at'] as int?,
        updated_at: json['updated_at'] as int?,
        expire_at: json['expire_at'] as int?,
        hide_user_ids: json['hide_user_ids'] as List?,
        read_user_ids: json['read_user_ids'] == null
            ? null
            : ([]..addAll((json?['read_user_ids'] as List ?? [])
                .map((o) => ReadUserIdModel.fromJson(o)))),

      );

  Map<String, dynamic> toJson() => {
        'message_id': message_id,
        'from_uid': from_uid,
        'target_uid': target_uid,
        'group_id': group_id,
        'session_id': session_id,
        'session_type': session_type,
        'msg_body': msg_body?.toJson(),
        'status': status,
        'is_revoke': is_revoke,
        'is_pinned': is_pinned,
        'created_at': created_at,
        'updated_at': updated_at,
        'expire_at': expire_at,
        'hide_user_ids': hide_user_ids,
        'read_user_ids': read_user_ids,

      };
}
