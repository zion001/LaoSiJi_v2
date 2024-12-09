import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:im_flutter/common/index.dart';

class ImUtil {
  static ImageWidget getAvatarWidget(String? avatarUrl) {
    ImageWidget avatar = (avatarUrl?.isEmpty ?? true)
        ? ImageWidget.asset(AssetsImages.avatarDefaultPng,
            placeholder: Image.asset(AssetsImages.avatarDefaultPng))
        : ImageWidget.url(
            (avatarUrl?.startsWith('http') ?? false)
                ? (avatarUrl ?? '')
             //   : 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/${avatarUrl ?? ''}',
             : '${ObsConfig.host}${avatarUrl ?? ''}',
            fit: BoxFit.cover,
            placeholder: Image.asset(AssetsImages.avatarDefaultPng));

    return avatar;
  }

  static String getMessageText(MessageModel? messageModel){
    String? msgText;
    if (messageModel?.msg_body?.msg_type == 'image')
      msgText = '[图片]';
    else if (messageModel?.msg_body?.msg_type ==
        'video')
      msgText = '[视频]';
    else if (messageModel?.msg_body?.msg_type == 'file')
      msgText = '[文件] ' + (messageModel?.msg_body?.file_name??'');
    else if (messageModel?.msg_body?.msg_type ==
        'audio')
      msgText = '[语音]';
    else if (messageModel?.msg_body?.msg_type ==
        'card')
      msgText = '[名片]';
    else
      msgText = messageModel?.msg_body?.text;

    return msgText??'';
  }
}
