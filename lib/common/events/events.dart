/// 刷新联系人
class RefreshContactsEvent {
  // 这里面可以加参数，用于指定部份刷新
}

/// 刷新群
class RefreshGroupsEvent {
  int groupId;
  RefreshGroupsEvent({required this.groupId});
}

/// 刷新个人信息
class RefreshProfileEvent {
  // 这里面可以加参数，用于指定部份刷新
}

/// 刷新好友申请列表
class RefreshFriendListEvent {}

/// 重新登录成功
class LoginSuccessEvent {}
