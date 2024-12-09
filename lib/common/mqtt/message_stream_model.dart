import 'dart:async';
import 'package:im_flutter/common/index.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:im_flutter/common/models/mqtt_model/message_model.dart';
import 'package:im_flutter/common/models/mqtt_model/read_userid_model.dart';

class MessageStreamModel {
  final BehaviorSubject<List<MessageModel>> _messageController =
      BehaviorSubject<List<MessageModel>>();
  final BehaviorSubject<List<MessageModel>> _pinnedMessageController =
  BehaviorSubject<List<MessageModel>>();
  final StreamController<MessageModel?> _editMessageController = StreamController<MessageModel?>.broadcast();
  List<MessageModel> _messages = [];
  List<MessageModel> _pinnedMessages = [];
  String? last_msg_id;
  bool hasMore = true;

  void insertMessage(MessageModel message) {
    //_messages.add(message);

    int index = _messages.indexWhere((element) =>
        (message.msg_body?.tmpKey != null &&
            element.msg_body?.tmpKey == message.msg_body?.tmpKey));
    if (index >= 0) {
      _messages[index] = message;
    } else
      _messages.insert(0, message);

    _messageController.add(_messages);
  }

  void replaceMessage(MessageModel message) {
    int index = _messages.indexWhere((element) =>
    (element.message_id == message.message_id));
    if (index >= 0) {
      _messages[index] = message;
      _messageController.add(_messages);
    }

    index = _pinnedMessages.indexWhere((element) =>
    (element.message_id == message.message_id));
    if (index >= 0) {
      _pinnedMessages[index] = message;
      _pinnedMessageController.add(_pinnedMessages);
    }
  }

  void clearMessage(){
    _messages.clear();

    _messageController.add(_messages);
  }

  void deleteMessage(String messageId) {
    int beforeCount = _messages.length;
    _messages.removeWhere((element) => element.message_id == messageId);
    if (last_msg_id == messageId)
      last_msg_id = _messages.isNotEmpty ? _messages.last.message_id : null;

    if(_messages.length != beforeCount)
      _messageController.add(_messages);

    beforeCount = _pinnedMessages.length;
    _pinnedMessages.removeWhere((element) => element.message_id == messageId);
    if(_pinnedMessages.length != beforeCount)
      _pinnedMessageController.add(_pinnedMessages);
  }

  MessageModel? firstMessage() {
    return _messages.isNotEmpty ? _messages.first : null;
  }

  void addMessageList(List<MessageModel> messages) {
    if (messages.length > 0) last_msg_id = messages.last.message_id;

    if (messages.length < Constants.pageSize) hasMore = false;
    //for(MessageModel messageModel in messages){
    //  _messages.insert(0,messageModel);
    //}

    _messages.addAll(messages);

    _messageController.add(_messages);
  }

  //isEvent:是否服务端发送的通知。服务端发送的为别人读我发的消息。不是服务端的表示我读别人的消息
  //isAll:是否更新会话中的全部。用于我读别人的消息
  void updateReadUser(List<String> msgIds, int uid, bool isEvent,bool isAll) {
    for (MessageModel message in _messages) {
      if(isAll){
        if(message.from_uid != uid && message.read_user_ids!=null && !(message.read_user_ids!.contains(uid))){
          message.read_user_ids!.add(ReadUserIdModel(
              user_id: uid, read_time: DateTime
              .now()
              .millisecondsSinceEpoch));
        }
      }else {
        if (msgIds.contains(message.message_id!)) {
          message.read_user_ids!.add(ReadUserIdModel(
              user_id: uid, read_time: DateTime
              .now()
              .millisecondsSinceEpoch));
        }
      }
    }

    if (isEvent) _messageController.add(_messages);
  }

  bool hasSendingMessage() {
    var result =
        _messages.where((element) => element.message_id == null).toList();

    return result.length != 0;
  }

  Stream<List<MessageModel>> getMessages() {
    return _messageController.stream;
  }

  void addPinnedMessageList(List<MessageModel> messages) {
    _pinnedMessages.clear();
    _pinnedMessages.addAll(messages);

    _pinnedMessageController.add(_pinnedMessages);
  }

  void modifyPinnedMessage(MessageModel message) {

    int index = _pinnedMessages.indexWhere((element) =>
    (message.msg_body?.tmpKey != null &&
        element.msg_body?.tmpKey == message.msg_body?.tmpKey));
    if(message.is_pinned??false) {
      if (index >= 0) {
        _pinnedMessages[index] = message;
      } else
        _pinnedMessages.insert(0, message);
    }else{
      if (index >= 0) {
        _pinnedMessages.removeAt(index);
      }
    }

    _pinnedMessageController.add(_pinnedMessages);
  }

  ValueStream<List<MessageModel>> getPinnedMessages() {
    return _pinnedMessageController.stream;
  }

  void editMessage(MessageModel? message){
    _editMessageController.add(message);
  }

  void replyMessage(MessageModel? message){
    MessageModel? replyMessageModel;
    if(message!=null) {
      replyMessageModel = message;
      //表示回复消息。用于区分消息编辑
      replyMessageModel.msg_body?.reply_message = MessageModel();
    }
    _editMessageController.add(replyMessageModel);
  }

  Stream<MessageModel?> getEditMessage() {
    return _editMessageController.stream;
  }
}
