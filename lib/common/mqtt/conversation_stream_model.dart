import 'dart:math';

import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/services/group_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:im_flutter/common/models/mqtt_model/conversation_model.dart';
import 'package:im_flutter/common/models/mqtt_model/message_model.dart';

class ConversationStreamModel {
  final BehaviorSubject<List<ConversationModel>> _conversationController =
      BehaviorSubject<List<ConversationModel>>();

  Map<int, ConversationModel> _conversations = {};
  Map<int, ConversationModel> get conversations => _conversations;

  void addConversationList(List<ConversationModel> conversations) {
    _conversations.clear();
    for (ConversationModel conversation in conversations) {
      int conversationId =
          conversation.friend_profile?.uid ?? (conversation.group_id ?? 0);
      _conversations[conversationId] = conversation;
    }
    List<ConversationModel> listConversationModel =
        _conversations.values.toList();
    listConversationModel.sort(sortConversation);
    _conversationController.add(listConversationModel);
  }

  void receiveNewMsg(MessageModel message, bool unread) {
    // 收到消息，通知
    NotificationService().showNotification(message);

    int? conversationId =
        (message.group_id ?? 0) != 0 ? message.group_id : message.from_uid;
    ConversationModel? conversation = _conversations[conversationId];
    if (conversation == null && conversationId != null) {
      /*
      GroupProfile? groupProfile;
      FriendListItemModel? friendListItemModel;
      if((message.group_id ?? 0) != 0)
        groupProfile = GroupManager.groupInfo(conversationId!);
      else
        friendListItemModel = ContactsManager.getFriend(conversationId!);
      print(friendListItemModel?.toJson());
      //手工生成
      conversation = new ConversationModel(
        from_uid:message.target_uid,
        friend_profile: ConversationFriendModel.from(friendListItemModel),
        group_id: message.group_id,
        group_profile: groupProfile,
        session_id: message.session_id,
      );
      _conversations[conversationId!] = conversation;
       */
      //没有session_id不行，从服务器上拉
      ImClient.getInstance().getConversationList();
      return;
    }
    if (conversation != null) {
      int selfUid = UserService.to.profile.user_id!;
      if(message.from_uid!=selfUid && (message.msg_body?.is_at_all??false || (message.msg_body?.at_user_list?.contains(selfUid)??false))){
        conversation.at_message = message;
      }
      conversation.last_message_info = message;
      if (unread)
        conversation.unread_count = (conversation.unread_count ?? 0) + 1;

      List<ConversationModel> listConversationModel =
          _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void sentNewMsg(MessageModel message) {
    int? conversationId =
        (message.group_id ?? 0) != 0 ? message.group_id : message.target_uid;
    ConversationModel? conversation = _conversations[conversationId];
    if (conversation == null && conversationId != null) {
      /*
      GroupProfile? groupProfile;
      FriendListItemModel? friendListItemModel;
      if((message.group_id ?? 0) != 0)
        groupProfile = GroupManager.groupInfo(conversationId!);
      else
        friendListItemModel = ContactsManager.getFriend(conversationId!);
      //手工生成
      conversation = new ConversationModel(
          from_uid:message.target_uid,
          friend_profile: ConversationFriendModel.from(friendListItemModel),
          group_id: message.group_id,
          group_profile: groupProfile,
          session_id: message.session_id,
      );
      _conversations[conversationId!] = conversation;
       */
      //没有session_id不行，从服务器上拉
      ImClient.getInstance().getConversationList();
      return;
    }
    if (conversation != null) {
      conversation.last_message_info = message;

      List<ConversationModel> listConversationModel =
          _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void setLastMessage(int conversationId, MessageModel? lastMessage) {
    ConversationModel? conversation = _conversations[conversationId];

    conversation?.last_message_info = lastMessage;

    List<ConversationModel> listConversationModel =
        _conversations.values.toList();
    listConversationModel.sort(sortConversation);
    _conversationController.add(listConversationModel);
  }

  void replaceLastMessage(int conversationId, MessageModel? lastMessage) {
    ConversationModel? conversation = _conversations[conversationId];

    if(conversation?.last_message_info?.message_id == lastMessage?.message_id) {
      conversation?.last_message_info = lastMessage;

      List<ConversationModel> listConversationModel =
      _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void removeLastMessages(List messageIds){
    bool updated = false;
    for(String messageId in messageIds){
      ConversationModel? conversation = _conversations.values.firstWhere((element) => element.last_message_info?.message_id == messageId);
      if(conversation != null){
        conversation.last_message_info = null;
        updated = true;
      }
    }

    if(updated){
      List<ConversationModel> listConversationModel =
      _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  ConversationModel? getConversation(int conversationId) {
    ConversationModel? conversation = _conversations[conversationId];
    return conversation;
  }

  ConversationModel? getConversationBySession(String sessionId) {
    ConversationModel? conversation = _conversations.values
        .firstWhere((element) => element.session_id == sessionId);
    return conversation;
  }

  void updateUnread(int conversationId, List<String> msgIds,bool isAll) {
    ConversationModel? conversation = _conversations[conversationId];
    if (conversation != null) {
      if(isAll)
        conversation.unread_count = 0;
      else
        conversation.unread_count =
          max(0, conversation.unread_count! - msgIds.length);

      if(isAll || msgIds.contains(conversation.at_message?.message_id))
        conversation.at_message = null;

      List<ConversationModel> listConversationModel =
          _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void updatePinned(int conversationId, bool pinned) {
    ConversationModel? conversation = _conversations[conversationId];
    if (conversation != null) {
      conversation.is_pinned = pinned;

      List<ConversationModel> listConversationModel =
          _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void updateRemind(int conversationId, int remind) {
    ConversationModel? conversation = _conversations[conversationId];
    if (conversation != null) {
      conversation.message_remind_type = remind;

      List<ConversationModel> listConversationModel =
          _conversations.values.toList();
      listConversationModel.sort(sortConversation);
      _conversationController.add(listConversationModel);
    }
  }

  void deleteSession(String sessionId) {
    _conversations.removeWhere((key, value) => value.session_id == sessionId);

    List<ConversationModel> listConversationModel =
        _conversations.values.toList();
    listConversationModel.sort(sortConversation);
    _conversationController.add(listConversationModel);
  }

  void deleteConversation(int conversationId) {
    _conversations.remove(conversationId);

    List<ConversationModel> listConversationModel =
        _conversations.values.toList();
    listConversationModel.sort(sortConversation);
    _conversationController.add(listConversationModel);
  }

  int sortConversation(ConversationModel a, ConversationModel b) {
    if ((a.is_pinned ?? false) != (b.is_pinned ?? false))
      return (b.is_pinned ?? false) ? 1 : -1;
    else
      return (b.last_message_info?.created_at ?? (b.created_at ?? 0))
          .compareTo(a.last_message_info?.created_at ?? (a.created_at ?? 0));
  }

  Stream<List<ConversationModel>> getConversations() {
    return _conversationController.stream;
  }
}
