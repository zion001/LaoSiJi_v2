import 'package:im_flutter/common/index.dart';

class FriendApi {
  /// 好友列表
  static Future<List<FriendListItemModel>> friendList() async {
    Resource res = await HttpUtil.get('friend/getFriendList');
    if (res.isSuccess()) {
      List list = res.data as List;
      List<FriendListItemModel> friends =
          list.map((e) => FriendListItemModel.fromJson(e)).toList();
      return friends;
    } else {
      Loading.error(res.message);
      return <FriendListItemModel>[];
    }
  }

  /// 搜索好友
  static Future<UserInfoBasic?> searchFriend(String username) async {
    Resource res = await HttpUtil.post('friend/searchFriend',
        params: {"username": username});

    print(res.data);

    if (res.isSuccess()) {
      if (res.data != null) {
        UserInfoBasic model = UserInfoBasic.fromJson(res.data);
        return model;
      } else {
        Loading.error("未找到该用户");
        return null;
      }
    } else {
      Loading.error(res.message);
      return null;
    }
  }

/*
  /// 检查好友关系(好像不需要这个接口了)
  static Future<bool> checkFriend(String userId) async {
    Resource res = await HttpUtil.get('friend/checkFriend',
        params: {"target_uid": userId});
    if (res.isSuccess()) {
      //0 = A 的好友表中没有 B，B 的好友表中也没有 A
      //1 = A 的好友表中有 B，但 B 的好友表中没有 A
      //2 = A 的好友表中没有 B，但 B 的好友表中有 A
      //3 = A 的好友表中有 B，B 的好友表中也有 A
      var relation = res.data['relation'];
      return relation == 1 || relation == 3;
    } else {
      Loading.error(res.message);
      return false;
    }
  }
  */

  /// 添加好友
  /// source: 好友来源 1搜索添加 2二维码 3群聊
  /// 返回值: 30539=需要经过对方确认才能添加为好友, 0=对方允许任何人添加自己为好友， -1=异常
  static Future<int> addFriend(int targetUid, int source) async {
    Loading.show();
    Resource res = await HttpUtil.post('friend/addFriend', params: {
      "target_uid": targetUid,
      'source': source,
    });
    if (res.isSuccess()) {
      var relation = res.data['code'];
      return relation;
    } else {
      Loading.error(res.message);
      return -1;
    }
  }

  /// 删除好友
  static Future<bool> deleteFriend(int targetUid) async {
    Loading.show();
    Resource res = await HttpUtil.post('friend/deleteFriend', params: {
      //"target_ids": [targetUid],
      "target_uid": targetUid,
    });
    if (res.isSuccess()) {
      return true;
    } else {
      Loading.error(res.message);
      return false;
    }
  }

/* 和搜索结果数据一致，暂时好像不需要这个了
  /// 获取好友详情
  static Future<UserInfoDetail?> userInfoDetail(int targetUid) async {
    Resource res = await HttpUtil.post('friend/getFriendProfile', params: {
      "target_ids": [targetUid],
    });
    if (res.isSuccess()) {
      List list = res.data['list'] as List;
      if (list.length == 1) {
        return UserInfoDetail.fromJson(list.first);
      } else {
        return null;
      }
    } else {
      Loading.error(res.message);
      return null;
    }
  }
  */

  /// 修改好友昵称
  static Future<String?> updateRemark(int targetUid, String remark) async {
    Resource res = await HttpUtil.post('friend/setFriendRemark', params: {
      'target_uid': targetUid,
      'remark': remark,
    });
    if (res.isSuccess()) {
      return remark;
    } else {
      Loading.error(res.message);
      return null;
    }
  }

  /// 获取好友申请列表
  static Future<List<FriendApplyModel>> friendApplyList() async {
    Resource res = await HttpUtil.get(
      'friend/getFriendApplicationList',
    );

    if (res.isSuccess()) {
      List list = res.data as List;
      List<FriendApplyModel> applyList =
          list.map((e) => FriendApplyModel.fromJson(e)).toList();
      return applyList;
    } else {
      Loading.error(res.message);
      return <FriendApplyModel>[];
    }
  }

  /// 同意好友申请
  static Future<bool> acceptAppy(int applyId) async {
    Loading.show();
    Resource res =
        await HttpUtil.post('friend/acceptFriendApplication', params: {
      "apply_id": applyId,
    });
    if (res.isSuccess()) {
      Loading.dismiss();
      return true;
    } else {
      Loading.error(res.message);
      return false;
    }
  }

  /// 拒绝好友申请
  static Future<bool> refuseAppy(int applyId) async {
    Loading.show();
    Resource res =
        await HttpUtil.post('friend/refuseFriendApplication', params: {
      "apply_id": applyId,
    });
    if (res.isSuccess()) {
      Loading.dismiss();
      return true;
    } else {
      Loading.error(res.message);
      return false;
    }
  }
}
