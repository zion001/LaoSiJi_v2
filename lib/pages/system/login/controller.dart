import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/services/fcm_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/routers/index.dart';
import 'package:im_flutter/common/services/user_service.dart';

class LoginController extends GetxController {
  //用户名
  TextEditingController userNameController = TextEditingController();
  //密码
  TextEditingController passwordController = TextEditingController();
  final agreeProtocol = true.obs;
  final isShowObscureIcon = true.obs;
  final WebViewController _webViewController = WebViewController();

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  LoginController();

  _initData() {
    update(["login"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    super.onClose();
    userNameController.dispose();
    passwordController.dispose();
  }

  // 去注册
  void onTapToRegister() {
    Get.toNamed(RouteNames.systemRegister)?.then((params) {
      if (params != null) {
        userNameController.text = params['username'].toString();
        passwordController.text = params['password'].toString();
      }
    });
  }

  // 登录
  Future<void> onTapLogin() async {
//    NotificationService().showNotification();
//    return;

    if (!(formKey.currentState as FormState).validate()) {
      return;
    }
    if (!agreeProtocol.value) {
      Loading.error('请点击同意《用户服务协议》和《隐私政策》');
      return;
    }
    Loading.show();
    UserTokenModel? tokenModel = await UserApi.login(
      username: userNameController.text,
      password: passwordController.text,
    );
    if (tokenModel == null) {
      return;
    }
    // 保存TOKEN和loginId
    await UserService.to.setToken(tokenModel.accessToken ?? '');
    await UserService.to.setLoginId(tokenModel.loginId ?? -100);
    // 获取用户信息
    bool isLogin = await UserService.to.getMyProfile();
    if (isLogin) {
    // Loading.success('登录成功');
      // 发送登录事件
      LoginSuccessEvent loginEvent = LoginSuccessEvent();
      EventBusUtils.shared.fire(loginEvent);

      // 绑定FCM
      FirebaseMessaging.instance.getToken().then((fcmToken) {
        if (fcmToken != null) {
          FcmManager.setFcm(fcmToken);
        }
      });

      Get.back();
    }
    Loading.dismiss();
  }

  onTapProtocol(BuildContext context,String protocol,String title) async{
    Loading.show();
    Map? sysAgreementConfig = await SystemApi.getSysAgreementConfig();
    Loading.dismiss();
    if(sysAgreementConfig is Map)
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ImWebview(
            htmlContent:sysAgreementConfig![protocol]!,
            title: title,
          ),
        ),
      );
  }
}
