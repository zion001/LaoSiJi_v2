import 'dart:convert';

import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
//import 'package:im_flutter/common/models/response_model/user_profile_model.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();
  // 是否登录
  final _isLogin = false.obs;
  bool get isLogin => _isLogin.value;

  // 用户TOKEN
  String token = '';
  // 是否有 token
  bool get hasToken => token.isNotEmpty;

  String loginId = '';

  // 用户资料
  final _profile = UserProfileModel().obs;
  UserProfileModel get profile => _profile.value;

  // 更新用户资料
  void updateMyProfile(UserProfileModel? profile) {
    _profile(profile);
    Storage().setString(Constants.storageMyProfile, jsonEncode(profile));
    _isLogin.value = profile != null;
  }

  @override
  void onInit() {
    super.onInit();
    // 读TOKEN
    token = Storage().getString(Constants.storageToken);
    // 读loginId
    loginId = Storage().getString(Constants.storageLoginId);

    // 读profile
    var profielOffline = Storage().getString(Constants.storageMyProfile);
    if (profielOffline.isNotEmpty) {
      _profile(UserProfileModel.fromJson(jsonDecode(profielOffline)));
      _isLogin.value = true;
    }
  }

  // 设置token
  Future<void> setToken(String value) async {
    await Storage().setString(Constants.storageToken, value);
    token = value;
  }

  // 设置loginId
  Future<void> setLoginId(int value) async {
    await Storage().setString(Constants.storageLoginId, value.toString());
    loginId = value.toString();
  }

  // 获取我的用户信息
  Future<bool> getMyProfile() async {
    if (token.isEmpty) {
      return false;
    }
    UserProfileModel? model = await UserApi.getMyProfile();
    if (model == null) {
      return false;
    }
    _profile(model);
    _isLogin.value = true;
    //保存个人信息
    Storage().setString(Constants.storageMyProfile, jsonEncode(model));
    return true;
  }

  void clearLogin() {
    setToken('');
    Storage().setString(Constants.storageMyProfile, '');
    _profile(UserProfileModel());
    _isLogin.value = false;
  }
}
