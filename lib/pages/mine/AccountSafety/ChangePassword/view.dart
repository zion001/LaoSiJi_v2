import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:validatorless/validatorless.dart';

import 'index.dart';

class ChangepasswordPage extends GetView<ChangepasswordController> {
  const ChangepasswordPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      // 旧密码
      /*

      */
      // 新密码
      Form(
        key: controller.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Obx(() => TextFormField(
                autocorrect: false,
                obscureText: controller.isNewShowObscureIcon.value,
                //autofocus: true,
                validator: Validatorless.multiple([
                  Validatorless.required(LocaleKeys.passwordPlaceholder.tr),
                ]),
                controller: controller.oldPasswordController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "请输入旧密码",
                  hintStyle: const TextStyle(fontSize: 14),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.isNewShowObscureIcon.value =
                      !controller.isNewShowObscureIcon.value;
                    },
                    icon: Icon(
                      controller.isNewShowObscureIcon.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 15,
                      color: AppColors.surfaceVariant,
                    ),
                  ),
                ),

                keyboardType: TextInputType.visiblePassword,
              )),

              Gap(AppSpace.card),
              Obx(() => TextFormField(
                autocorrect: false,
                obscureText: controller.isNewShowObscureIcon.value,
                //autofocus: true,
                validator: Validatorless.multiple([
                  Validatorless.required(LocaleKeys.passwordPlaceholder.tr),
                  IMValidators.password('密码为6-32位英文字母或数字组合'),
                ]),
                controller: controller.newPasswordController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "请输入新密码，6-32位英文、数字或字母组合",
                  hintStyle: const TextStyle(fontSize: 14),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.isNewShowObscureIcon.value =
                      !controller.isNewShowObscureIcon.value;
                    },
                    icon: Icon(
                      controller.isNewShowObscureIcon.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 15,
                      color: AppColors.surfaceVariant,
                    ),
                  ),
                ),

                keyboardType: TextInputType.visiblePassword,
              )),
              Gap(AppSpace.card),
              Obx(() => TextFormField(
                autocorrect: false,
                obscureText: controller.isNewShowObscureIcon.value,
                //autofocus: true,
                validator: Validatorless.multiple([
                  Validatorless.compare(controller.newPasswordController, '两次输入密码不相同')

                ]),
                controller: controller.newPasswordAgainController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "再次输入新密码",
                  hintStyle: const TextStyle(fontSize: 14),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.isNewShowObscureIcon.value =
                      !controller.isNewShowObscureIcon.value;
                    },
                    icon: Icon(
                      controller.isNewShowObscureIcon.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 15,
                      color: AppColors.surfaceVariant,
                    ),
                  ),
                ),

                keyboardType: TextInputType.visiblePassword,
              )),
            ]
        )
      ),



      Gap(AppSpace.card * 3),

      ButtonWidget.textFilled(
        "确定",
        onTap: () => controller.onChangePasswordTapped(),
      ).tight(height: 50),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .marginSymmetric(horizontal: AppSpace.page, vertical: AppSpace.page);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangepasswordController>(
      init: ChangepasswordController(),
      id: "changepassword",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '账号和安全',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
