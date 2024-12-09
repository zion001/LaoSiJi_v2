import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Form(
                key: controller.formKey,
                //autovalidateMode: AutovalidateMode.onUserInteraction,
                child: [
                  TextWidget.title1(LocaleKeys.appName.tr,
                          color: const Color(0XFF007C7A), size: 32)
                      .center()
                      .tight(height: 200)
                      .paddingTop(AppSpace.listItem),
                  // 用户名
                  TextFormField(
                    autocorrect: false,
                    validator: Validatorless.multiple([
                      Validatorless.required(LocaleKeys.usernamePlaceholder.tr),
                      IMValidators.userName("账号为6-32位英文或数字组合"),
                    ]),
                    controller: controller.userNameController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "请输入您的账号",
                        hintStyle: const TextStyle(fontSize: 14)),
                    keyboardType: TextInputType.visiblePassword,
                  ).paddingTop(AppSpace.listItem),
                  // 密码
                  Obx(() => TextFormField(
                        autocorrect: false,
                        obscureText: controller.isShowObscureIcon.value,
                        //autofocus: true,
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              LocaleKeys.passwordPlaceholder.tr),
                          IMValidators.password("密码为6-32位英文、数字或字母组合"),
                        ]),
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // filled:true,
                          // fillColor: Color(0XFFEBF5F5),
                          // focusedBorder: OutlineInputBorder(
                          //     borderRadius: BorderRadius.circular(10.0),
                          //     borderSide: BorderSide(
                          //       color: Color(0XFFEBF5F5),
                          //     ),
                          //   ),
                          // enabledBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(10.0),
                          //   borderSide: BorderSide(
                          //     color: Color(0XFFEBF5F5),
                          //   ),
                          // ),
                          hintText: "请输入您的密码",
                          hintStyle: const TextStyle(fontSize: 14),
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.isShowObscureIcon.value =
                                  !controller.isShowObscureIcon.value;
                            },
                            icon: Icon(
                              controller.isShowObscureIcon.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 15,
                              color: AppColors.surfaceVariant,
                            ),
                          ),
                        ),

                        keyboardType: TextInputType.visiblePassword,
                      )).paddingTop(AppSpace.listItem),
                  // 登录
                  ButtonWidget.textFilled(
                    LocaleKeys.login.tr,
                    textSize: 18.sp,
                    onTap: controller.onTapLogin,
                    bgColor: const Color(0XFF007C7A),
                    borderRadius: 8,
                  )
                      .tight(height: AppSpace.buttonHeight)
                      .paddingTop(AppSpace.paragraph),
                  // 去注册
                  ButtonWidget.text(
                    LocaleKeys.toRegister.tr,
                    onTap: controller.onTapToRegister,
                    textColor: Colors.black54,
                  )
                      .tight(height: AppSpace.buttonHeight)
                      .paddingTop(AppSpace.listItem),
                ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch))
            .tight(height: ScreenUtil().setHeight(720)),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Obx(
            () => Checkbox(
              shape: const CircleBorder(),
              activeColor: const Color(0XFF007C7A),
              value: controller.agreeProtocol.value,
              onChanged: (bool? value) {
                controller.agreeProtocol.value = value ?? false;
              },
            ),
          ),
          RichText(
              text: TextSpan(
            text: '我已阅读并同意',
            style: const TextStyle(color: Colors.black, fontSize: 12),
            children: [
              TextSpan(
                text: '《服务条款》',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
                //文本的点击事件
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    controller.onTapProtocol(context,'user_service_agreement','服务条款');
                  },
              ),
              const TextSpan(
                text: '和',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              TextSpan(
                text: '《隐私政策》',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    controller.onTapProtocol(context,'privacy_policy','隐私政策');
                  },
              ),
            ],
          ))
        ]),
      ]).marginAll(AppSpace.page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      id: "login",
      builder: (_) {
        return  WillPopScope(
            onWillPop: () {
              print("onWillPop");

              return Future.value(false);
            },
            child: Scaffold(
              body: SafeArea(
                child: _buildView(context),
              ),
            )
        );
      },
    );
  }
}
