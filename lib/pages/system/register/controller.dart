import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:im_flutter/common/index.dart';

class RegisterController extends GetxController {
  //用户名
  TextEditingController userNameController = TextEditingController();
  //密码
  TextEditingController passwordController = TextEditingController();
  final agreeProtocol = true.obs;
  final isShowObscureIcon = true.obs;
  final WebViewController _webViewController = WebViewController();

  /// 表单 key
  GlobalKey formKey = GlobalKey<FormState>();

  RegisterController();

  _initData() {
    update(["register"]);
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

  // 注册
  Future<void> onTapRegister() async {
    if (!(formKey.currentState as FormState).validate()) {
      return;
    }
    if (!agreeProtocol.value) {
      Loading.error('请点击同意《用户服务协议》和《隐私政策》');
      return;
    }

    Loading.show();

    bool isSuccess = await UserApi.register(
      username: userNameController.text,
      password: passwordController.text,
    );
    if (isSuccess) {
      Get.back(result: {
        'username': userNameController.text,
        'password': passwordController.text
      });
    }
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
