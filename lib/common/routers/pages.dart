import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/pages/group/MyGroup/group_detail/index.dart';
import 'package:im_flutter/pages/group/MyGroup/index.dart';
import 'package:im_flutter/pages/mine/AboutUs/index.dart';
import 'package:im_flutter/pages/mine/AccountSafety/ChangePassword/index.dart';
import 'package:im_flutter/pages/mine/MessageNotification/index.dart';
import 'package:im_flutter/pages/mine/UserInfomation/ChangeNickname/index.dart';
import 'package:im_flutter/pages/mine/UserInfomation/MyQRCode/index.dart';
import 'package:im_flutter/pages/mine/UserInfomation/index.dart';
import 'package:im_flutter/pages/mine/VersionCheck/index.dart';
import 'package:im_flutter/pages/mine/privacy_setting/index.dart';
import 'package:im_flutter/pages/styles/inputs/index.dart';
import '../../pages/index.dart';
import 'index.dart';

// 路由
class RoutePages {
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  // 列表
  static List<GetPage> list = [
    GetPage(
      name: RouteNames.chatChatDetail,
      page: () => const ChatDetailPage(),
    ),
    GetPage(
      name: RouteNames.chat,
      page: () => const ChatPage(),
    ),
    GetPage(
      name: RouteNames.chatPinned,
      page: () => const ChatPinnedPage(),
    ),
    GetPage(
      name: RouteNames.chatReference,
      page: () => const ChatReferencePage(),
    ),
    GetPage(
      name: RouteNames.forwardConversation,
      page: () => const ForwardConversationPage(),
    ),
    GetPage(
      name: RouteNames.forwardContact,
      page: () => const ForwardContactPage(),
    ),
    GetPage(
      name: RouteNames.forwardGroup,
      page: () => const ForwardGroupPage(),
    ),
    GetPage(
      name: RouteNames.chatSelectContact,
      page: () => const ChatSelectContactPage(),
    ),
    GetPage(
      name: RouteNames.contactsContactsAddFriend,
      page: () => const AddFriendPage(),
    ),
    GetPage(
      name: RouteNames.contactsContactsUpdateRemark,
      page: () => const UpdateRemarkPage(),
    ),
    GetPage(
      name: RouteNames.contactsContactsUserDetail,
      page: () => const UserDetailPage(),
    ),
    GetPage(
      name: RouteNames.contactsContacts,
      page: () => const ContactsPage(),
    ),
    GetPage(
      name: RouteNames.conversationsConversations,
      page: () => const ConversationsPage(),
    ),
    GetPage(
      name: RouteNames.mineMine,
      page: () => const MinePage(),
    ),
    GetPage(
      name: RouteNames.stylesButtons,
      page: () => const ButtonsPage(),
    ),
    GetPage(
      name: RouteNames.stylesIcon,
      page: () => const IconPage(),
    ),
    GetPage(
      name: RouteNames.stylesImage,
      page: () => const ImagePage(),
    ),
    GetPage(
      name: RouteNames.stylesInputs,
      page: () => const InputsPage(),
    ),
    GetPage(
      name: RouteNames.stylesStyleIndex,
      page: () => const StyleIndexPage(),
    ),
    GetPage(
      name: RouteNames.stylesText,
      page: () => const TextPage(),
    ),
    GetPage(
      name: RouteNames.systemLogin,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: RouteNames.systemMain,
      page: () => const MainPage(),
    ),
    GetPage(
      name: RouteNames.systemRegister,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: RouteNames.systemSplash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: RouteNames.mineAccountSafety,
      page: () => const AccountsafetyPage(),
    ),
    GetPage(
      name: RouteNames.mineMessageNotification,
      page: () => const MessagenotificationPage(),
    ),
    GetPage(
      name: RouteNames.mineAboutUs,
      page: () => const AboutusPage(),
    ),
    GetPage(
      name: RouteNames.mineVersionCheck,
      page: () => const VersioncheckPage(),
    ),
    GetPage(
      name: RouteNames.mineChangePassword,
      page: () => const ChangepasswordPage(),
    ),
    GetPage(
      name: RouteNames.mineUserInfo,
      page: () => const UserinfomationPage(),
    ),
    GetPage(
      name: RouteNames.mineChangeNickname,
      page: () => const ChangenicknamePage(),
    ),
    GetPage(
      name: RouteNames.mineQRCode,
      page: () => const MyqrcodePage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroup,
      page: () => const MyGroupPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupDetail,
      page: () => const GroupDetailPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupChangeGroupNick,
      page: () => const ChangeGroupNickPage(),
    ),
    GetPage(
      name: RouteNames.contactsContactsSelectContacts,
      page: () => const SelectContactsPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupSetGroupName,
      page: () => const SetGroupNamePage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupSetGroupAvatar,
      page: () => const SetGroupAvatarPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupGroupManage,
      page: () => const GroupManagePage(),
    ),
    GetPage(
      name: RouteNames
          .groupMyGroupGroupManageGroupMemberSettingGroupManagerSetting,
      page: () => const GroupManagerSettingPage(),
    ),
    GetPage(
      name:
          RouteNames.groupMyGroupGroupManageGroupMemberSettingGroupMuteSetting,
      page: () => const GroupMuteSettingPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupGroupManageGroupMemberSetting,
      page: () => const GroupMemberSettingPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupSetGroupNotice,
      page: () => const SetGroupNoticePage(),
    ),
    GetPage(
      name: RouteNames.systemQrcodeScanner,
      page: () => const QrcodeScannerPage(),
    ),
    GetPage(
      name: RouteNames.contactsContactsFriendApplyList,
      page: () => const FriendApplyListPage(),
    ),
    GetPage(
      name: RouteNames.minePrivacySetting,
      page: () => const PrivacySettingPage(),
    ),
    GetPage(
      name: RouteNames.groupMyGroupShowGroupNotice,
      page: () => const ShowGroupNoticePage(),
    ),
  ];
}
