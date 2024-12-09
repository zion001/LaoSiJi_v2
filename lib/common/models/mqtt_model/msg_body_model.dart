import 'message_model.dart';

class UserCardModel {
  int? uid;
  String? nickname;
  String? avatar;
  String? username;

  UserCardModel(
      {this.uid,
        this.nickname,
        this.avatar,
        this.username});

  factory UserCardModel.fromJson(Map<String, dynamic> json) {
    return UserCardModel(
      uid: json['uid'] as int?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'nickname': nickname,
    'avatar': avatar,
    'username': username,
  };
}

class MsgBodyModel {
  String? msg_type;
  String? text;
  String? url;
  String? attachment;
  String? file_name;
  int? width;
  int? height;
  num? duration;
  String? tmpKey;
  int? create_time;
  List? at_user_list;
  bool? is_at_all;
  UserCardModel? user_info;
  MessageModel? reply_message;

  MsgBodyModel({
    this.msg_type,
    this.text,
    this.url,
    this.attachment,
    this.width,
    this.height,
    this.duration,
    this.file_name,
    this.tmpKey,
    this.create_time,
    this.at_user_list,
    this.is_at_all,
    this.user_info,
    this.reply_message,
  });

  factory MsgBodyModel.copyFrom(MsgBodyModel? copy){
    return MsgBodyModel(
      msg_type: copy?.msg_type,
      text: copy?.text,
      url: copy?.url,
      attachment: copy?.attachment,
      width: copy?.width,
      height: copy?.height,
      duration: copy?.duration,
      file_name: copy?.file_name,
      tmpKey: copy?.tmpKey,
      create_time: copy?.create_time,
      at_user_list: copy?.at_user_list,
      is_at_all: copy?.is_at_all,
      user_info:copy?.user_info,
      reply_message:copy?.reply_message,
    );
  }

  factory MsgBodyModel.fromJson(Map<String, dynamic> json) => MsgBodyModel(
        msg_type: json['msg_type'] as String?,
        text:
            (json['text'] is String) ? json['text'] : json['text']?.toString(),
        url: json['url'] as String?,
        attachment: json['attachment'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
        duration: json['duration'] as num?,
        file_name: json['file_name'] as String?,
        tmpKey: json['tmpKey'] as String?,
        create_time: json['create_time'] as int?,
        at_user_list:json['at_user_list'] as List?,
        is_at_all:json['is_at_all'] as bool?,
        user_info:json['user_info']!=null?UserCardModel.fromJson(json['user_info']):null,
        reply_message:json['reply_message']!=null?MessageModel.fromJson(json['reply_message']):null,
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? replyMessage;
    if(reply_message!=null) {
      replyMessage = reply_message?.toJson();
      replyMessage?["msg_body"]?.removeWhere((key, value) =>
      key != "msg_type" && key != "text");
      replyMessage?.removeWhere((key, value) =>
      key != "message_id" && key != "from_uid" && key != "msg_body");
    }
    return {
      'msg_type': msg_type,
      'text': text,
      'url': url,
      'attachment': attachment,
      'width': width,
      'height': height,
      'duration': duration,
      'file_name': file_name,
      'tmpKey': tmpKey,
      'create_time': create_time,
      'at_user_list': at_user_list,
      'is_at_all': is_at_all,
      'user_info': user_info?.toJson()
        ?..removeWhere((key, value) => value == null),
      'reply_message': replyMessage,
    };
  }
}
