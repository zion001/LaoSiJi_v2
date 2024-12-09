import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: controller.formKey,
        //autovalidateMode: AutovalidateMode.onUserInteraction,
        child: [
          [
            ImageWidget.asset(
              AssetsImages.logoPng,
              radius: AppRadius.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          ].toRow(mainAxisAlignment: MainAxisAlignment.center),
          // 用户名
          Row(
            children: [
              const Text(
                '账号',
                style: TextStyle(fontSize: 17),
              ).tight(width: 50),
              TextFormField(
                autocorrect: false,
                //autofocus: true,
                validator: Validatorless.multiple([
                  Validatorless.required(LocaleKeys.usernamePlaceholder.tr),
                  IMValidators.userName('账号为6-32位英文或数字组合'),
                ]),
                controller: controller.userNameController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "账号为6-32位英文或数字组合",
                    hintStyle: TextStyle(fontSize: 14)),

                keyboardType: TextInputType.visiblePassword,
              ).expanded(),
            ],
          ).paddingTop(AppSpace.paragraph),
          // 密码
          Row(
            children: [
              Text(
                '密码',
                style: TextStyle(fontSize: 17),
              ).tight(width: 50),
              Obx(() => TextFormField(
                    autocorrect: false,
                    obscureText: controller.isShowObscureIcon.value,
                    //autofocus: true,
                    validator: Validatorless.multiple([
                      Validatorless.required(LocaleKeys.passwordPlaceholder.tr),
                      IMValidators.password("密码为6-32位英文、数字或字母组合"),
                    ]),
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "密码为6-32位英文、数字或字母组合",
                      hintStyle: TextStyle(fontSize: 14),
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
                  )).expanded(),
            ],
          ).paddingTop(AppSpace.listItem),

          // 注册
          ButtonWidget.textFilled(
            LocaleKeys.register.tr,
            textSize: 18.sp,
            onTap: controller.onTapRegister,
            bgColor: Color(0XFF007C7A),
            borderRadius: 8,
          ).tight(height: AppSpace.buttonHeight).paddingTop(AppSpace.paragraph),
          Row(children: [
            Obx(
              () => Checkbox(
                shape: CircleBorder(),
                activeColor: Color(0XFF007C7A),
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
          ]).paddingTop(AppSpace.paragraph),
        ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
            .marginAll(AppSpace.page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      init: RegisterController(),
      id: "register",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.black),
            title: Text(LocaleKeys.register.tr,
                style: TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
            ),
          ),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
