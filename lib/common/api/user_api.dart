import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/user_profile_model.dart';

class UserApi {
  /// 注册
  static Future<bool> register(
      {required String username, required String password}) async {
    var params = {
      'nickname': username,
      'username': username,
      'password': password.toMd5,
      // 'avatar': 'http://img.touxiangkong.com/uploads/allimg/2023021313/yyivxtwjlgx.jpg',
      'custom_field': '',
    };

    Resource res = await HttpUtil.post(
      //'user/auth/register',
      'users/register',
      params: params,
    );
    if (res.isSuccess()) {
      Loading.success('注册成功');
      return true;
    } else {
      Loading.error(res.message);
      return false;
    }
  }

  /// 登录
  static Future<UserTokenModel?> login(
      {required String username, required String password}) async {
    Resource res = await HttpUtil.post(
      'users/login',
      params: {
        'username': username,
        'password': password.toMd5,
      },
    );
    if (res.isSuccess()) {
      UserTokenModel model = UserTokenModel.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 退出登录
  static Future<bool> logout (
      {required String loginId, required String fcmToken}) async {
    Resource res = await HttpUtil.post(
      'users/logout',
      params: {
        'login_id': int.parse(loginId),
        'push_token': fcmToken,
      },
    );
    if (res.isSuccess()) {
      return true;
    } else {
      return false;
    }
  }

  /// 获取我的用户信息
  static Future<UserProfileModel?> getMyProfile() async {
    var res = await HttpUtil.get('users/getMyProfile');
    if (res.isSuccess()) {
      UserProfileModel model = UserProfileModel.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 获取个人配置
  static Future<MyConfigProfile?> getMyConfigProfile() async {
    var res = await HttpUtil.get('users/getMyConfigProfile');
    if (res.isSuccess()) {
      MyConfigProfile model = MyConfigProfile.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 修改个人配置
  /// config.add_friend_confirm 是否添加好友需要确认
  /// config.allow_group_add_friend 是否允许通过群聊添加好友
  /// config.find_by_username 是否允许通过账号查找
  /// config.is_qr_add_friend 是否允许通过二维码添加
  static Future<MyConfigProfile?> setMyConfigProfile(
      Map<String, int> params) async {
    var res = await HttpUtil.post(
      'users/modifyMyConfigProfile',
      params: {'config': params},
    );
    if (res.isSuccess()) {
      MyConfigProfile model = MyConfigProfile.fromJson(res.data);
      Loading.dismiss();
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 修改密码
  static Future<UserProfileModel?> changePassword(
      {required String oldPsd,required String newPsd}) async {
    Resource res = await HttpUtil.post(
      'users/modifyMyProfile',
      params: {
        'old_password' : oldPsd,
        'password': newPsd,
      },
    );
    if (res.isSuccess()) {
      UserProfileModel model = UserProfileModel.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 修改头像
  static Future<UserProfileModel?> changeAvatar(
      {required String avatar}) async {
    Resource res = await HttpUtil.post(
      'users/modifyMyProfile',
      params: {
        'avatar': avatar,
      },
    );
    if (res.isSuccess()) {
      UserProfileModel model = UserProfileModel.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 修改昵称
  static Future<UserProfileModel?> changeNickname(
      {required String nickname}) async {
    Resource res = await HttpUtil.post(
      'users/modifyMyProfile',
      params: {
        'nickname': nickname,
      },
    );
    if (res.isSuccess()) {
      UserProfileModel model = UserProfileModel.fromJson(res.data);
      return model;
    } else {
      Loading.error(res.message);
      return null;
    }
  }
}
