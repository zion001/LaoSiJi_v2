import 'dart:convert';

import 'package:im_flutter/common/index.dart';

class SystemConfigModel {
  String? androidIsForce;
  String? androidMinVersion;
  String? androidUrl;
  String? androidVersion;
  String? huaweiObs;
  String? iosIsForce;
  String? iosMinVersion;
  String? iosUrl;
  String? iosVersion;
  String? isGroupAllProhibitions;
  String? isOpenCreateGroup;
  String? messageFrequency;
  String? messageFrequencyTip;
  String? sensitiveWords;
  String? updateExpireDay;
  String? updateExpireTip;

  SystemConfigModel({
    this.androidIsForce,
    this.androidMinVersion,
    this.androidUrl,
    this.androidVersion,
    this.huaweiObs,
    this.iosIsForce,
    this.iosMinVersion,
    this.iosUrl,
    this.iosVersion,
    this.isGroupAllProhibitions,
    this.isOpenCreateGroup,
    this.messageFrequency,
    this.messageFrequencyTip,
    this.sensitiveWords,
    this.updateExpireDay,
    this.updateExpireTip,
  });

  factory SystemConfigModel.fromJson(Map<String, dynamic> json) {
  
    var strHuaWei = json['huawei_obs'] as String?;
    if ( strHuaWei != null ) {
      Map<String, dynamic> json = jsonDecode(strHuaWei);
      ObsConfig.key = json['obs_app_key'];
      ObsConfig.secret = json['obs_app_secret'];
      ObsConfig.endPoint = json['obs_app_endpoint'];
      ObsConfig.bucket = json['obs_app_bucket'];
      ObsConfig.host = json['huawei_access_host'];
    }
    
    return SystemConfigModel(
      androidIsForce: json['android_is_force'] as String?,
      androidMinVersion: json['android_min_version'] as String?,
      androidUrl: json['android_url'] as String?,
      androidVersion: json['android_version'] as String?,
      huaweiObs: json['huawei_obs'] as String?,
      iosIsForce: json['ios_is_force'] as String?,
      iosMinVersion: json['ios_min_version'] as String?,
      iosUrl: json['ios_url'] as String?,
      iosVersion: json['ios_version'] as String?,
      isGroupAllProhibitions: json['is_group_all_prohibitions'] as String?,
      isOpenCreateGroup: json['is_open_create_group'] as String?,
      messageFrequency: json['message_frequency'] as String?,
      messageFrequencyTip: json['message_frequency_tip'] as String?,
      sensitiveWords: json['sensitive_words'] as String?,
      updateExpireDay: json['update_expire_day'] as String?,
      updateExpireTip: json['update_expire_tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'android_is_force': androidIsForce,
        'android_min_version': androidMinVersion,
        'android_url': androidUrl,
        'android_version': androidVersion,
        'huawei_obs': huaweiObs,
        'ios_is_force': iosIsForce,
        'ios_min_version': iosMinVersion,
        'ios_url': iosUrl,
        'ios_version': iosVersion,
        'is_group_all_prohibitions': isGroupAllProhibitions,
        'is_open_create_group': isOpenCreateGroup,
        'message_frequency': messageFrequency,
        'message_frequency_tip': messageFrequencyTip,
        'sensitive_words': sensitiveWords,
        'update_expire_day': updateExpireDay,
        'update_expire_tip': updateExpireTip,
      };
}
