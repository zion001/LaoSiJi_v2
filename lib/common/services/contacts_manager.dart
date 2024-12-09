import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

/// 联系人分组
class ContactGroup {
  // 分组标题
  String groupTitle;
  // 分组内成员列表
  List<FriendListItemModel> list;

  ContactGroup({required this.groupTitle, required this.list});
}

/// 联系人管理
class ContactsManager {
  /// 好友列表(已分组排序)
  static List<ContactGroup> friendGroupList = [];

  /// 刷新联系人数据
  static Future<void> refreshFriendList() async {
    List<FriendListItemModel> friendList = await FriendApi.friendList();

    friendGroupList.clear();

    Map<String, List<FriendListItemModel>> map = {};
    for (var element in friendList) {
      var title = element.pinYin ?? '#';
      if (map[title] == null) {
        map[title] = List<FriendListItemModel>.empty(growable: true);
      }
      map[title]?.add(element);
    }

    map.forEach((key, value) {
      value.sort(
        (a, b) => (a.user_profile?.nickname ?? '')
            .compareTo(b.user_profile?.nickname ?? ''),
      );
      friendGroupList.add(ContactGroup(groupTitle: key, list: value));
    });
    friendGroupList.sort(
      (a, b) => a.groupTitle.compareTo(b.groupTitle),
    );

    await getMemberOnlineState();
  }

  /// 获取指定联系人
  static FriendListItemModel? getFriend(int userId) {
    for (var group in friendGroupList) {
      for (var friend in group.list) {
        if (friend.uid == userId) {
          return friend;
        }
      }
    }
    return null;
  }

  /// 更新指定联系人备注
  static updateFriendRemark(int userId, String remark) {
    var friend = getFriend(userId);
    if (friend == null) {
      return;
    }
    friend.remark = remark;
  }

  /// 更新指定联系人
  static updateFriend(FriendListItemModel friend) {
    var f = getFriend(friend.uid ?? 0);
    if (f == null) {
      return;
    }
    f = friend;
  }

  /// 增加联系人
  static void addFriend(FriendListItemModel friend) {
    // 如果原来有这个，就删除
    deleteFriend(friend.uid ?? 0);

    /// TODO: 增加的联系人，需要获取他的在线状态
    ///

    // 先判断是否有这个分组
    bool hasTheGroup = false;
    int index = 0;
    for (index = 0; index < friendGroupList.length; ++index) {
      if (friendGroupList[index].groupTitle == friend.pinYin) {
        hasTheGroup = true;
        break;
      }
    }
    // 如有这个分组，则在分组内增加此联系人，并重新排序
    if (hasTheGroup) {
      friendGroupList[index].list.add(friend);
      friendGroupList[index].list.sort(
            (a, b) => (a.user_profile?.nickname ?? '')
                .compareTo(b.user_profile?.nickname ?? ''),
          );
    } else {
      // 如没有这个分组，则需增加这个分组
      ContactGroup newGroup =
          ContactGroup(groupTitle: friend.pinYin ?? '#', list: [friend]);
      friendGroupList.add(newGroup);
      friendGroupList.sort(
        (a, b) => a.groupTitle.compareTo(b.groupTitle),
      );
    }
  }

  /// 删除联系人
  static void deleteFriend(int userId) {
    for (int i = 0; i < friendGroupList.length; ++i) {
      for (int j = 0; j < friendGroupList[i].list.length; ++j) {
        if (friendGroupList[i].list[j].uid == userId) {
          // 删除对应联系人
          friendGroupList[i].list.removeAt(j);
          // 如果删除后，该组成员为空，则删除该分组
          if (friendGroupList[i].list.isEmpty) {
            friendGroupList.removeAt(i);
          }
          return;
        }
      }
    }
  }

  //从socket获取在线状态
  static Future<void> getMemberOnlineState() async {
    Map<int,FriendListItemModel> friendMap = {};
    for(ContactGroup contactGroup in friendGroupList){
      for(FriendListItemModel friendListItemModel in contactGroup.list){
        friendMap[friendListItemModel.uid!] = friendListItemModel;
      }
    }
    PayloadModel payloadModel = await ImClient.getInstance().getMemberOnlineState(friendMap.keys.toList());
    friendMap.forEach((key, value) {
      MemberStateModel? memberStateModel = payloadModel.content[key.toString()];
      value.isOnline = memberStateModel?.recent?.status == 1;
    });
  }
}
