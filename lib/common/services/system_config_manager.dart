import 'dart:convert';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/system_config_model.dart';

/// 系统配置管理
class SystemConfigManager {

  static SystemConfigModel systemConfig = SystemConfigModel();

  static Future<SystemConfigModel?> getConfig() async {
    String? encryptedText = await SystemApi.getSystemConfig();
    if (encryptedText == null) {
      return null;
    }
    //加密key
    final key = Encrypt.Key.fromUtf8('3d703b0e656c4ed7');
    //偏移量
    final iv = Encrypt.IV.fromUtf8('3d703b0e656c4ed7');
    //设置cbc模式
    final encrypter = Encrypt.Encrypter(Encrypt.AES(key, mode: Encrypt.AESMode.cbc, padding: 'PKCS7'));
    //解密
    String decryptedStr = encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
    Map<String, dynamic> json = jsonDecode(decryptedStr);
    systemConfig = SystemConfigModel.fromJson(json);
    return systemConfig;
  }
}