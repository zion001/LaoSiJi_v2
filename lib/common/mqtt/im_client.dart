import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/mqtt_model/msg_body_model.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:im_flutter/common/services/user_service.dart';
import 'package:im_flutter/global.dart';
import 'package:im_flutter/common/models/mqtt_model/conversation_model.dart';
import 'package:im_flutter/common/mqtt/conversation_stream_model.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';
import 'package:im_flutter/common/mqtt/connection_state_model.dart';
import 'package:im_flutter/common/models/mqtt_model/message_model.dart';
import 'package:im_flutter/common/models/mqtt_model/payload_model.dart';
import 'package:im_flutter/common/models/mqtt_model/session_pinned_model.dart';
import 'package:im_flutter/common/models/mqtt_model/session_remind_model.dart';

typedef ConnectedCallback = void Function();

class ImClient {
  MqttQos qos = MqttQos.atLeastOnce;
  late MqttServerClient mqttClient;
  static ImClient? _instance;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      receiveSubscription;
  StreamSubscription<MqttPublishMessage>? publishSubscription;
  //异步命令
  Map<String, Completer> receivedMap = {};
  Map<int, Completer> pubbackMap = {};
  //聊天消息
  Map<int, MessageStreamModel> chatMap = {};
  //连接状态
  ConnectionStateModel currentState =
      ConnectionStateModel(MqttConnectionState.disconnected);
  //会话列表
  ConversationStreamModel conversationStreamModel = ConversationStreamModel();

  Uuid uuid = Uuid();
  int selfUid = 0;
  int seq = 0;

  static ImClient getInstance() {
    if (_instance == null) {
      _instance = ImClient();
    }
    return _instance!;
  }

  Future connect(String username, String password, String loginId) async {

    mqttClient = MqttServerClient(Global.SOCKET_HOST, 'im_flutter');
    mqttClient.useWebSocket = true;
    mqttClient.port = 3883;

    mqttClient.onConnected = onConnected;
    mqttClient.onDisconnected = _onDisconnected();
    mqttClient.onAutoReconnect = onAutoReconnect;
    mqttClient.onAutoReconnected = onAutoReconnected;

    mqttClient.onSubscribed = _onSubscribed;

    mqttClient.onSubscribeFail = _onSubscribeFail;

    mqttClient.onUnsubscribed = _onUnSubscribed;

    mqttClient.setProtocolV311();
    mqttClient.logging(on: true);
    //mqttClient.keepAlivePeriod = 30;
    mqttClient.autoReconnect = true;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.
    // final connMess = MqttConnectMessage()
    //     .withClientIdentifier(loginId)
    //     .withWillTopic(
    //         'willtopic') // If you set this you must set a will message
    //     .withWillMessage('My Will message')
    //     .startClean() // Non persistent session for testing
    //     .withWillQos(MqttQos.atLeastOnce);
    // print('im_flutter client connecting....');
    // mqttClient.connectionMessage = connMess;
    mqttClient.clientIdentifier = loginId;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await mqttClient.connect(username, password);
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      //mqttClient.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');

      //mqttClient.disconnect();
    }
    currentState.connectionState = mqttClient!.connectionStatus!.state;

    /// Check we are connected
    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${mqttClient.connectionStatus}');
      mqttClient.disconnect();
      return;
    }

    selfUid = UserService.to.profile.user_id!;
    String uid = selfUid.toString();
    mqttClient!.subscribe("ims/${uid}/publish", MqttQos.exactlyOnce);
    mqttClient!.subscribe("ims/${uid}/single", MqttQos.exactlyOnce);
    mqttClient!.subscribe("ims/${uid}/event", MqttQos.exactlyOnce);

    receiveSubscription = mqttClient!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final topic = c![0].topic as String;
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${topic}>, payload is <-- $pt -->');
      print('');
      Map<String, dynamic> response = jsonDecode(pt);
      PayloadModel payloadModel = PayloadModel.fromJson(response);
      String? activate = payloadModel.head?.cmd;
      String? payloadSeq = payloadModel.head?.seq;
      if (payloadModel.error_code == 0) {
        if (activate == "get.roam.msg.resp") {
          List<MessageModel> listMessage = []
            ..addAll(
                (payloadModel.content as List ?? [])
                    .map((o) => MessageModel.fromJson(o)));
          int? conversationId;
          if (listMessage.length > 0) {
            MessageModel message = listMessage.first;
            if ((message.group_id ?? 0) != 0)
              conversationId = message.group_id;
            else if (message.from_uid == selfUid)
              conversationId = message.target_uid;
            else
              conversationId = message.from_uid;
          }
          MessageStreamModel? chatMessageModel = chatMap[conversationId];
          if (chatMessageModel != null) {
            chatMessageModel.addMessageList(listMessage);
          }
        }else if (activate == "get.pinned.message.list.resp") {
            List<MessageModel> listMessage = []..addAll(
                (payloadModel.content as List ?? [])
                    .map((o) => MessageModel.fromJson(o)));
            int? conversationId;
            if (listMessage.length > 0) {
              MessageModel message = listMessage.first;
              if ((message.group_id ?? 0) != 0)
                conversationId = message.group_id;
              else if (message.from_uid == selfUid)
                conversationId = message.target_uid;
              else
                conversationId = message.from_uid;
            }
            MessageStreamModel? chatMessageModel = chatMap[conversationId];
            if (chatMessageModel != null) {
              chatMessageModel.addPinnedMessageList(listMessage);
            }
        } else if (activate == "send.single.message.resp") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.target_uid];
          if (chatMessageModel != null) {
            chatMessageModel.insertMessage(message);
          }
          conversationStreamModel.sentNewMsg(message);
        } else if (activate == "send.group.message.resp") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.group_id];
          if (chatMessageModel != null) {
            chatMessageModel.insertMessage(message);
          }

          conversationStreamModel.sentNewMsg(message);
        } else if (activate == "get.session.list.resp") {
          List<ConversationModel> listConversation = []..addAll(
              (payloadModel.content as List ?? [])
                  .map((o) => ConversationModel.fromJson(o)));

          conversationStreamModel.addConversationList(listConversation);
        } else if (activate == "new.single.msg") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.from_uid];
          if (chatMessageModel != null) {
            chatMessageModel.insertMessage(message);
          }

          conversationStreamModel.receiveNewMsg(
              message, chatMessageModel == null);
        } else if (activate == "new.group.msg") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.group_id];
          if (chatMessageModel != null) {
            chatMessageModel.insertMessage(message);
          }

          //用chatMessageModel != null 表示当前正在聊天，不设置未读（有正在发送消息的话不正确）
          conversationStreamModel.receiveNewMsg(
              message, chatMessageModel == null && message.from_uid != selfUid);
        } else if (activate == "delete.message.resp") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          ConversationModel? conversationModel = conversationStreamModel.getConversationBySession(message.session_id!);
          int conversationId;
          if (conversationModel?.friend_profile != null) {
            conversationId = conversationModel!.friend_profile!.uid!;
          } else {
            conversationId = conversationModel!.group_profile!.groupId!;
          }

          MessageStreamModel? chatMessageModel = chatMap[conversationId];
          if (chatMessageModel != null) {
            chatMessageModel.deleteMessage(message.message_id!);

            if(conversationModel.last_message_info?.message_id == message.message_id!){
              MessageModel? lastMessage = chatMessageModel.firstMessage();
              conversationStreamModel.setLastMessage(conversationId, lastMessage);

            }
          }


        } else if (activate == "set.session.pinned.resp") {
          SessionPinnedModel sessionPinnedModel =
              SessionPinnedModel.fromJson(payloadModel.content);

          payloadModel.content = sessionPinnedModel;
          conversationStreamModel.updatePinned(
              sessionPinnedModel.target_id!, sessionPinnedModel.is_pinned!);
        } else if (activate == "set.session.remind.resp") {
          SessionRemindModel sessionRemindModel = SessionRemindModel.fromJson(
              payloadModel.content);

          payloadModel.content = sessionRemindModel;
          conversationStreamModel.updateRemind(
              sessionRemindModel.target_id!, sessionRemindModel.remind_type!);
        } else if (activate == "delete.session.resp") {
          conversationStreamModel.deleteSession(payloadModel.content["session_id"]!);
        } else if (activate == "set.message.read.event") {
          List splitTopic = topic.split('/');
          int? conversationId;
          if(splitTopic.length >= 3) {
            if (splitTopic[2] == 'group') {
              try {
                conversationId = int.parse(splitTopic[1]);
              } catch (e) {

              }
            } else if (splitTopic[2] == 'single') {
              conversationId = payloadModel.content['from_uid']!;
            }
          }
          MessageStreamModel? chatMessageModel = chatMap[conversationId!];
          if (chatMessageModel != null) {
            List<String> msgIds = List<String>.from(payloadModel.content['msg_body']!['message_ids']!);
            chatMessageModel.updateReadUser(msgIds
                ,payloadModel.content['from_uid']!,true,false);
          }
        } else if (activate == "clear.message.resp") {
          MessageStreamModel? chatMessageModel = chatMap[payloadModel.content['target_id']!];
          if (chatMessageModel != null) {
            chatMessageModel.clearMessage();
          }
          conversationStreamModel.setLastMessage(payloadModel.content['target_id']!, null);
        } else if (activate == "delete.message.event") {
          List messageIds = payloadModel.content['msg_body']!['message_ids']!;
          for(String messageId in messageIds){
             for(MessageStreamModel messageStreamModel in chatMap.values){
               messageStreamModel.deleteMessage(messageId);
             }
          }
          conversationStreamModel.removeLastMessages(messageIds);
        } else if (activate == "modify.message.event") {
          MessageModel message = MessageModel.fromJson(payloadModel.content["msg_body"]["message"]);
          int? conversationId;
          if ((message.group_id ?? 0) != 0)
            conversationId = message.group_id;
          else if (message.from_uid == selfUid)
            conversationId = message.target_uid;
          else
            conversationId = message.from_uid;

          MessageStreamModel? chatMessageModel = chatMap[conversationId];
          if (chatMessageModel != null) {
            chatMessageModel.replaceMessage(message);
          }
          conversationStreamModel.replaceLastMessage(conversationId!, message);
        } else if (activate == "set.message.pinned.resp") {
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          int? conversationId;
          if ((message.group_id ?? 0) != 0)
            conversationId = message.group_id;
          else if (message.from_uid == selfUid)
            conversationId = message.target_uid;
          else
            conversationId = message.from_uid;

          MessageStreamModel? chatMessageModel = chatMap[conversationId];
          if (chatMessageModel != null) {
            chatMessageModel.modifyPinnedMessage(message);
          }
        } else if (activate == "set.message.pinned.event") {
          MessageModel message = MessageModel.fromJson(payloadModel.content["msg_body"]["message"]);
          int? conversationId;
          if ((message.group_id ?? 0) != 0)
            conversationId = message.group_id;
          else if (message.from_uid == selfUid)
            conversationId = message.target_uid;
          else
            conversationId = message.from_uid;

          MessageStreamModel? chatMessageModel = chatMap[conversationId];
          if (chatMessageModel != null) {
            chatMessageModel.modifyPinnedMessage(message);
          }
        } else if (activate == "get.member.online.state.resp") {
          if(payloadModel.content is Map){
            Map onlineStateMap = {};
            payloadModel.content.forEach((key, value) {
              onlineStateMap[key] = MemberStateModel.fromJson(value);
            });
            payloadModel.content = onlineStateMap;
          }
        } else if (activate == "get.message.info.resp") {
          if(payloadModel.content is Map){
            MessageModel messageModel = MessageModel.fromJson(payloadModel.content);
            payloadModel.content = messageModel;
          }
        } else if (activate == 'set.group.profile.event') {
          // 设置群信息（修改群名称,群头像,全体禁言）
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          Map<String, dynamic> mapProfile = mapBody['group_profile'];
          int groupID = mapProfile['group_id'];
          GroupProfile? oldGroup = GroupManager.groupInfo(groupID);
          if (oldGroup == null) {
            return;
          }

          oldGroup.avatar = mapProfile['avatar'];
          oldGroup.isMuteAll = mapProfile['is_mute_all'];
          oldGroup.joinOption = mapProfile['join_option'];
          oldGroup.maxMemberCount = mapProfile['max_member_count'];
          oldGroup.notice = mapProfile['notice'];
          oldGroup.ownerId = mapProfile['owner_uid'];
          oldGroup.status = mapProfile['status'];
          oldGroup.title = mapProfile['title'];
          print(mapProfile);
          GroupManager.updateGroup(oldGroup);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupID);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'set.group.notice.event') {
          // 设置群公告
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          Map<String, dynamic> mapProfile = mapBody['group_profile'];
          int groupID = mapProfile['group_id'];
          GroupProfile? oldGroup = GroupManager.groupInfo(groupID);
          if (oldGroup == null) {
            return;
          }
          oldGroup.notice = mapProfile['notice'];
          GroupManager.updateGroup(oldGroup);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupID);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'change.group.owner.event') {
          // 转让群主
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          int newOwner = mapBody['new_owner_id'];
          GroupProfile? groupProfile = GroupManager.groupInfo(groupId);
          if (groupProfile == null) {
            return;
          }
          GroupManager.transferGroupOwner(groupId, newOwner);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'set.group.member.nick.event') {
          // 设置群内昵称
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          int memberId = mapBody['member_id'];
          String nick = mapBody['nick'];
          GroupManager.changeGroupNick(groupId, memberId, nick);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'delete.group.member.event' ||
            activate == 'add.group.member.event') {
          // 删除群成员/添加群成员
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          List members = mapBody['member_ids'];
          List<int> memberIds =
              members.map((e) => int.parse(e.toString())).toList();
          if (activate == 'delete.group.member.event') {
            if (members.contains(UserService.to.profile.user_id)) {
              // 自己被T出群
              GroupManager.removeGroup(groupId);

              //删除会话
              conversationStreamModel.deleteConversation(groupId);
            } else {
              GroupManager.removeGroupMembers(groupId, memberIds); // 其它人被T出群
            }
          } else {
            // 添加群成员，没办法了，只能从服务端刷新群数据
            GroupManager.refreshGroupInfomation(groupId);
            // 如果是自己被加入群，则需要增加订阅
            if (members.contains(UserService.to.profile.user_id)) {
              subscribeGroupEvent(groupID: groupId);
            }
          }
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'quit.group.event') { // 退出群聊
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          int memberId = mapContent['from_uid'];
          GroupManager.quitGroup(groupId, memberId);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'set.group.member.role.event') {
          // 设置/取消群管理员
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          int memberId = mapBody['member_id'];
          int role = mapBody['role'];
          GroupManager.setRole(groupId, memberId, role);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'set.group.member.mute_time.event') {
          // 设置群成员单个禁言
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          int memberId = mapBody['member_id'];
          int mute_time = mapBody['mute_time'];
          GroupManager.setMemberMute(groupId, memberId, mute_time);
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == 'create.group.event' ||
            activate == 'dismiss.group.event') {
          // 创建群聊 / 解散群聊
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int groupId = mapBody['group_id'];
          if (activate == 'create.group.event') {
            GroupManager.refreshGroupInfomation(groupId);

            //刷新会话
            getConversationList();
          } else {
            GroupManager.removeGroup(groupId);

            //删除会话
            conversationStreamModel.deleteConversation(groupId);
          }
          // 发送刷新事件
          RefreshGroupsEvent refreshGroupEvent =
              RefreshGroupsEvent(groupId: groupId);
          EventBusUtils.shared.fire(refreshGroupEvent);
        } else if (activate == "update.friend.list.event" ||
            activate == "delete.friend.event" ||
            activate == "add.friend.event") {
          // 添加好友，删除好友后，会收到此事件，用以刷新好友更表
          await ContactsManager.refreshFriendList(); // 刷新联系人
          // 发送刷新事件
          RefreshContactsEvent refreshContactsEvent = RefreshContactsEvent();
          EventBusUtils.shared.fire(refreshContactsEvent);

          if(activate == "add.friend.event" || activate == "update.friend.list.event")
            //刷新会话
            getConversationList();
          else if(activate == "delete.friend.event" && payloadModel.content["from_uid"]!=null){
            //删除会话
            conversationStreamModel.deleteConversation(payloadModel.content["from_uid"]);
          }
        } else if (activate == 'set.friend.remark.event') {
          // 设置好友备注
          Map<String, dynamic> mapContent = payloadModel.content;
          Map<String, dynamic> mapBody = mapContent['msg_body'];
          int target_uid = mapBody['target_uid'];
          String remark = mapBody['remark'];
          ContactsManager.updateFriendRemark(target_uid, remark);
          // 发送刷新事件
          RefreshContactsEvent refreshContactsEvent = RefreshContactsEvent();
          EventBusUtils.shared.fire(refreshContactsEvent);
        } else if (activate == "user.profile.update.event") {
          // 自己个人信息修改，如修改昵称会收到此事件
          bool success = await UserService.to.getMyProfile();
          if (success) {
            // 发送刷新事件
            RefreshProfileEvent refreshProfileEvent = RefreshProfileEvent();
            EventBusUtils.shared.fire(refreshProfileEvent);
          }
        } else if (activate == 'new.friend.apply.event') { //好友申请事件
          FriendApplyManager.refreshFriendApplyLis();
        }
      }else{
        print(activate);
        //发送失败
        if(activate == "send.single.message.resp"){
          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.target_uid];
          if (chatMessageModel != null) {
            message.status = MessageStatus.failure.number;
            message.from_uid = UserService.to.profile.user_id!;
            message.created_at = message.msg_body?.create_time;
            chatMessageModel.insertMessage(message);
          }

        }else if(activate == "send.group.message.resp"){

          MessageModel message = MessageModel.fromJson(payloadModel.content);
          MessageStreamModel? chatMessageModel = chatMap[message.group_id];
          if (chatMessageModel != null) {
            message.status = MessageStatus.failure.number;
            message.from_uid = UserService.to.profile.user_id!;
            message.created_at = message.msg_body?.create_time;
            chatMessageModel.insertMessage(message);
          }

        }
      }

      Completer? completer = receivedMap[payloadSeq];
      if (completer != null) {
        completer!.complete(payloadModel);

        receivedMap.remove(payloadSeq);
      }
    });
    publishSubscription =
        mqttClient!.published!.listen((MqttPublishMessage message) {
      final pt = bytesToStringAsString(message.payload.message);
      print(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, payload is <-- $pt -->, with Qos ${message.header!.qos}');

      Map<String, dynamic> response = jsonDecode(pt);
      PayloadModel payloadModel = PayloadModel.fromJson(response);
      Completer? completer =
          pubbackMap[message.variableHeader!.messageIdentifier];
      if (completer != null) {
        completer!.complete(payloadModel);
        pubbackMap.remove(message.variableHeader!.messageIdentifier);
      }
    });

  }

  disconnect() {
    mqttClient.disconnect();
    _log("_disconnect");

    conversationStreamModel.addConversationList([]);
    chatMap.clear();
    currentState.connectionState = mqttClient!.connectionStatus!.state;
  }

  onDisConnected(ConnectedCallback callback) {
    mqttClient.onDisconnected = callback;
  }

  onConnected() {
//    mqttClient.onConnected = callback;
    _log("_onConnected");
    //_startListen();
    currentState.connectionState = mqttClient!.connectionStatus!.state;
  }

  _onDisconnected() {
    _log("_onDisconnected");
    currentState.connectionState = mqttClient!.connectionStatus!.state;
  }

  //auto reconnect
  void onAutoReconnect() {
    _log('Auto Reconnect');
    currentState.connectionState = mqttClient!.connectionStatus!.state;

    //可能更换了 newLoginId和token
    mqttClient.clientIdentifier = UserService.to.loginId;
    final connectMessage = mqttClient!.getConnectMessage(UserService.to.profile?.user_id?.toString() ?? '',
        UserService.to.token);

    // Set keep alive period.
    //connectMessage.variableHeader?.keepAlive = mqttClient!.keepAlivePeriod;

    mqttClient!.connectionMessage = connectMessage;

  }

  //重连成功
  void onAutoReconnected() {
    _log('Auto Reconnected: ${mqttClient!.connectionStatus!.state}');
    currentState.connectionState = mqttClient!.connectionStatus!.state;
    if(currentState.connectionState == MqttConnectionState.connected) {
      //重新获取数据
      getConversationList();

      GroupManager.refreshAllGroup();
      ContactsManager.refreshFriendList();
      FriendApplyManager.refreshFriendApplyLis();
    }
  }

  _onSubscribed(String topic) {
    _log("_订阅主题成功---topic:$topic");
  }

  _onUnSubscribed(String? topic) {
    _log("_取消订阅主题成功---topic:$topic");
  }

  _onSubscribeFail(String topic) {
    _log("_onSubscribeFail");
  }

  _log(String msg) {
    print("MQTT-->$msg");
  }


  MessageModel addSendingMessage(int conversionType, int targetUid,
      {MsgBodyModel? msgBody,
        String? msgText,
        String? msgImage,
        String? msgVideo,
        String? msgFile,
        UserCardModel? msgUser,
        String? fileName,
        String? attachment,
        int? width,
        int? height,
        String? msgAudio,
        double? duration,
        List<int>? atMembers,
        bool? isAtAll,
        MessageModel? replyMessage,
      })
  {
    int uid = UserService.to.profile.user_id!;
    MsgBodyModel msgBodyModel = MsgBodyModel(
        create_time:DateTime.now().millisecondsSinceEpoch,
        tmpKey:Uuid().v1()
    );
    if(replyMessage!=null)
      msgBodyModel.reply_message = replyMessage;
    if(msgBody!=null) {
      msgBodyModel = msgBody;
    }else if (msgImage != null) {
      msgBodyModel.msg_type = "image";
      msgBodyModel.url = msgImage;
      msgBodyModel.width = width;
      msgBodyModel.height = height;
      if(attachment != null)
        msgBodyModel.attachment = attachment;
    } else if (msgVideo != null) {
      msgBodyModel.msg_type = "video";
      msgBodyModel.url = msgVideo;
      msgBodyModel.width = width;
      msgBodyModel.height = height;
      if(attachment != null)
        msgBodyModel.attachment = attachment;
    } else if (msgFile != null) {
      msgBodyModel.msg_type = "file";
      msgBodyModel.url = msgFile;
      msgBodyModel.file_name = fileName;
    } else if (msgAudio != null) {
      msgBodyModel.msg_type = "audio";
      msgBodyModel.url = msgAudio;
      msgBodyModel.duration = duration;
    }else if (msgUser != null) {
      msgBodyModel.msg_type = "card";
      msgBodyModel.user_info = msgUser;
    } else if (msgText != null) {
      msgBodyModel.msg_type = "text";
      msgBodyModel.text = msgText;
      if(isAtAll == true)
        msgBodyModel.is_at_all = isAtAll;
      if((atMembers?.length??0) > 0)
        msgBodyModel.at_user_list = atMembers;
    }

    MessageModel messageModel = MessageModel(
        from_uid: uid,
        created_at: msgBodyModel.create_time,
        msg_body: msgBodyModel
    );

    MessageStreamModel? chatMessageModel = chatMap[targetUid];

    if (chatMessageModel == null) {
      chatMessageModel = MessageStreamModel();
      chatMap[targetUid] = chatMessageModel;
    }

    chatMessageModel.insertMessage(messageModel);
    //更新会话。会和服务器上的会话不一致
    conversationStreamModel.sentNewMsg(messageModel);

    return messageModel;
  }

  MessageModel sendingMessageFail(int conversionType, int targetUid,
      MessageModel messageModel){
    messageModel.status = MessageStatus.failure.number;
    MessageStreamModel? chatMessageModel = chatMap[targetUid];

    if (chatMessageModel == null) {
      chatMessageModel = MessageStreamModel();
      chatMap[targetUid] = chatMessageModel;
    }

    chatMessageModel.insertMessage(messageModel);

    return messageModel;
  }

  //conversionType:1 单聊 2 群聊
  Future<PayloadModel> sendMessage(int conversionType, int targetUid,
      {MsgBodyModel? msgBodyModel,
        String? msgText,
        String? msgImage,
        String? msgVideo,
        String? msgFile,
        String? fileName,
        String? attachment,
        String? msgAudio,
        double? duration,
        List<int>? atMembers,
        bool? isAtAll,
      }) async {
    String tmpKey = uuid.v1();
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    String cmd;
    String sendTarget;
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel;
    if (conversionType == 1) {
      cmd = "send.single.message";
      sendTarget = "target_uid";
    } else {
      cmd = "send.group.message";
      sendTarget = "group_id";
    }
    payloadHeadModel = PayloadHeadModel(cmd: cmd, seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    if(msgBodyModel!=null) {
      Map msgBody = msgBodyModel.toJson();
      msgBody.removeWhere((key, value) => value==null);
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": msgBody,
      };
    }else if (msgImage != null) {
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": {
          "create_time": DateTime.now().millisecondsSinceEpoch,
          "url": msgImage,
          "msg_type": "image",
          "tmpKey": tmpKey
        }
      };
      if(attachment != null)
        payloadModel.content["msg_body"]["attachment"] = attachment;
    } else if (msgVideo != null) {
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": {
          "create_time": DateTime.now().millisecondsSinceEpoch,
          "url": msgVideo,
          "msg_type": "video",
          "tmpKey": tmpKey
        }
      };
      if(attachment != null)
        payloadModel.content["msg_body"]["attachment"] = attachment;
    } else if (msgFile != null) {
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": {
          "create_time": DateTime.now().millisecondsSinceEpoch,
          "url": msgFile,
          "file_name": fileName,
          "msg_type": "file",
          "tmpKey": tmpKey
        }
      };
    } else if (msgAudio != null) {
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": {
          "create_time": DateTime.now().millisecondsSinceEpoch,
          "url": msgAudio,
          "duration": duration,
          "msg_type": "audio",
          "tmpKey": tmpKey
        }
      };
    } else if (msgText != null) {
      payloadModel.content = {
        sendTarget: targetUid,
        "msg_body": {
          "create_time": DateTime.now().millisecondsSinceEpoch,
          "text": msgText,
          "msg_type": "text",
          "tmpKey": tmpKey
        }
      };
      if(isAtAll == true)
        payloadModel.content["msg_body"]['is_at_all'] = isAtAll;
      if((atMembers?.length??0) > 0)
        payloadModel.content["msg_body"]['at_user_list'] = atMembers;
    }

    String playLoadString = json.encode(payloadModel.toJson());
    //playLoadString = '{"head":{"cmd":"send.single.message","seq":"5"},"content":{"target_uid":455673287112916997,"msg_body":{"msg_code":1000,"msg_type":"text","text":"11111111111111","tmpKey":"uOIaUJRwGndLCrWrnhSL6S84nTtJ7pdy"}}}';

    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    //var codeUnits = playLoadString.codeUnits;//utf16
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);
    _log(bytesToStringAsString(uint8buffer));

    int megId =
        mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);
    Completer<PayloadModel> completer = Completer();
    pubbackMap[megId] = completer;
    final PayloadModel result = await completer!.future;
    return result;
  }

  Future<PayloadModel> modifyMessage(
      String messageId,
      MsgBodyModel msgBodyModel,
      ) async {
    String tmpKey = uuid.v1();
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    String cmd;
    String sendTarget;
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel;

    cmd = "modify.message";
    payloadHeadModel = PayloadHeadModel(cmd: cmd, seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;

    Map msgBody = msgBodyModel.toJson();
    msgBody.removeWhere((key, value) => value==null);
    payloadModel.content = {
      "message_id": messageId,
      "msg_body": msgBody,
    };

    String playLoadString = json.encode(payloadModel.toJson());

    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    //var codeUnits = playLoadString.codeUnits;//utf16
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);
    _log(bytesToStringAsString(uint8buffer));

    int megId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);
    Completer<PayloadModel> completer = Completer();
    pubbackMap[megId] = completer;
    final PayloadModel result = await completer!.future;
    return result;
  }

  Future<PayloadModel> getMessageById(
      String messageId,
      ) async {
    String tmpKey = uuid.v1();
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    String cmd;
    String sendTarget;
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel;

    cmd = "get.message.info";
    payloadHeadModel = PayloadHeadModel(cmd: cmd, seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;

    payloadModel.content = {
      "message_id": messageId,
    };

    String playLoadString = json.encode(payloadModel.toJson());

    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    //var codeUnits = playLoadString.codeUnits;//utf16
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);
    _log(bytesToStringAsString(uint8buffer));

    int megId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer<PayloadModel> completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  int getConversationList() {
    int uid = UserService.to.profile.user_id ?? 0;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
        PayloadHeadModel(cmd: "get.session.list", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
        mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);
    /*
    String activateResp = activate + ".resp";
    Completer? completer = receivedMap[activateResp] ;
    if(completer == null) {
      completer = Completer();
      receivedMap[activateResp] = completer;
    }
    final List<ConversationModel> result = await completer.future;
    return result;

     */
    return msgId;
  }

  //lastMsgId=null 表示新打开页面
  MessageStreamModel getChatMessage(
      int conversationType, int conversationId, String? lastMsgId) {
    MessageStreamModel? chatMessageModel = chatMap[conversationId];
    if (chatMessageModel != null && lastMsgId == null) {
      //重复打开聊天页面的情况。共享一套数据
      return chatMessageModel;
    }

    if (chatMessageModel == null) {
      chatMessageModel = MessageStreamModel();
      chatMap[conversationId] = chatMessageModel;
    }

    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";

    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
        PayloadHeadModel(cmd: "get.roam.msg", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "target_id": conversationId,
      "session_type": conversationType,
      "last_msg_id": lastMsgId,
      "limit": Constants.pageSize //每页条数
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int megId =
        mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    return chatMessageModel;
  }

  int setMessageRead(int conversationId, List<String> msgIds,bool isAll) {
    int uid = UserService.to.profile.user_id!;
    //更新会话未读消息数量
    conversationStreamModel.updateUnread(conversationId, msgIds,isAll);
    ConversationModel? conversation =
        conversationStreamModel.getConversation(conversationId);
    //更新消息已读userId
    MessageStreamModel? chatMessageModel = chatMap[conversationId];
    if (chatMessageModel != null) {
      chatMessageModel.updateReadUser(msgIds, uid, false,isAll);
    }

    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
        PayloadHeadModel(cmd: "set.message.read", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "session_id": conversation!.session_id!,
      "message_ids": msgIds,
      "is_all":isAll,
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
        mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    return msgId;
  }

  int deleteMessage(String sessionId, String messageId,bool isAll) {
    int uid = UserService.to.profile.user_id!;

    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "delete.message", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "session_id": sessionId,
      "message_id": messageId,
      "is_all":isAll
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    return msgId;
  }


  Future<PayloadModel> setSessionPinned(
      int conversationType, int conversationId, bool pinned) async {
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
        PayloadHeadModel(cmd: "set.session.pinned", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "target_id": conversationId,
      "session_type": conversationType,
      "is_pinned": pinned
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
        mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  Future<PayloadModel> setSessionRemind(int conversationType, int conversationId, int remind) async{
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "set.session.remind", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "target_id": conversationId,
      "session_type": conversationType,
      "remind_type": remind
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  //删除会话
  Future<PayloadModel> deleteSession(String sessionId) async{
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "delete.session", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "session_id": sessionId,
      "is_all": false,
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  //清空消息
  Future<PayloadModel> clearHistoryMessage(int conversationType, int conversationId) async{
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "clear.message", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "target_id": conversationId,
      "session_type": conversationType,
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  Future<PayloadModel> setMessagePinned(
      String messageId, bool pinned) async {
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "set.message.pinned", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "message_id": messageId,
      "is_pinned": pinned
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  Future<PayloadModel> getPinnedMessageList(
      int conversationType, int conversationId) async {
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "get.pinned.message.list", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "target_id": conversationId,
      "session_type": conversationType
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }

  Future<PayloadModel> getMemberOnlineState(
      List Uids) async {
    int uid = UserService.to.profile.user_id!;
    String pTopic = "ims/${uid}/publish";
    PayloadModel payloadModel = PayloadModel();
    PayloadHeadModel payloadHeadModel =
    PayloadHeadModel(cmd: "get.member.online.state", seq: (++seq).toString());
    payloadModel.head = payloadHeadModel;
    payloadModel.content = {
      "member_ids": Uids,
    };

    String playLoadString = json.encode(payloadModel.toJson());
    _log("_发送数据-topic:$pTopic,playLoad:$playLoadString");
    Uint8Buffer uint8buffer = Uint8Buffer();
    var codeUnits = utf8.encode(playLoadString);
    uint8buffer.addAll(codeUnits);

    int msgId =
    mqttClient.publishMessage(pTopic, qos, uint8buffer, retain: false);

    String payloadSeq = seq.toString();
    Completer completer = Completer();
    receivedMap[payloadSeq] = completer;

    final PayloadModel result = await completer.future;
    return result;
  }


  void removeChatMessage(MessageStreamModel chatMessageModel) {
    chatMap.removeWhere((key, value) => value == chatMessageModel);
  }

  ConnectionStateModel getCurrentConnectionState() {
    return currentState;
  }

  /// Converts an array of bytes to a character string.
  String bytesToStringAsString(Uint8Buffer message) {
    // 不会乱码
    //String messageTxt = Utf8Decoder().convert(message);
    String messageTxt = utf8.decode(message);
    return messageTxt;
  }

  /// 订阅群事件(groupID不为null时，订阅指定群，为空时订阅所有群)
  void subscribeGroupEvent({int? groupID}) {
    if (groupID != null) {
      mqttClient!.subscribe("ims/${groupID!}/group/event", MqttQos.exactlyOnce);
      mqttClient!.subscribe("ims/${groupID!}/group", MqttQos.exactlyOnce);
    } else {
      for (var group in GroupManager.groupList) {
        mqttClient!.subscribe(
            "ims/${group.groupId!}/group/event", MqttQos.exactlyOnce);
        mqttClient!.subscribe(
            "ims/${group.groupId!}/group", MqttQos.exactlyOnce);
      }
    }
  }
}
