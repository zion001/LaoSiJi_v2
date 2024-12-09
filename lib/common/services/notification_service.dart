import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
        if (payload != null) {
          var arr = payload.split("|");
          var type = arr[0];
          var aimID = arr[1];
          Get.offNamedUntil(RouteNames.systemMain, (route) => false);
          if (type == "1") {
            // 私聊
            FriendListItemModel? user =
                ContactsManager.getFriend(int.parse(aimID));
            if (user != null) {
              Get.toNamed(RouteNames.chat, arguments: {'chat_person': user});
            }
          } else if (type == "2") {
            // 群聊
            GroupProfile? group = GroupManager.groupInfo(
                int.parse(aimID)); //GroupManager.groupInfo(aimID);
            if (group != null) {
              Get.toNamed(RouteNames.chat, arguments: {'chat_group': group});
            }
          }
        }
      },
    );
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('new_message'),
        ),
        iOS: DarwinNotificationDetails());
  }

  //Future showNotification(String title, String body, String payload
  //    /*{int id = 0 String? title, String? body, String? payLoad}*/) async {
  Future showNotification(MessageModel message) async {
    final WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    final AppLifecycleState? appLifecycleState = widgetsBinding.lifecycleState;
    if (appLifecycleState == AppLifecycleState.resumed) {
      //如果在前台，就直接播放声音
      AudioPlayer player = AudioPlayer();
      player.play(AssetSource('sounds/new_message.wav'));

      return;
    }
/*
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    */

    String title = "通知";
    if (message.group_id == 0) {
      // 单聊
      FriendListItemModel? user =
          ContactsManager.getFriend(message.from_uid ?? 0);
      if (user != null) {
        title = user.user_profile?.nickname ?? '通知';
      }
    } else {
      // 群聊
      GroupProfile? group = GroupManager.groupInfo(message.group_id ?? 0);
      if (group != null) {
        title = group.title ?? '通知';
      }
    }

    String body = message.msg_body?.text ?? 'body';
    switch (message.msg_body?.msg_type) {
      case 'image':
        body = '[图片]';
        break;
      case 'video':
        body = '[视频]';
        break;
      case 'file':
        body = '[文件]';
        break;
      case 'audio':
        body = '[语音]';
        break;
      default:
        body = message.msg_body?.text ?? 'body';
    }

    return notificationsPlugin.show(
      0,
      title,
      body,
      await notificationDetails(),
      payload:
          '${message.group_id == 0 ? 1 : 2}|${message.group_id == 0 ? message.from_uid : message.group_id}',
    );
  }
}
