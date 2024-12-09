import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class AccountsafetyPage extends GetView<AccountsafetyController> {
  const AccountsafetyPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return [
      OptionListCell(title: '登录密码').height(50).onTap(() {
        controller.onChangePasswordTapped();
      })
    ]
        .toColumn()
        .marginSymmetric(horizontal: AppSpace.card, vertical: AppRadius.card);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsafetyController>(
      init: AccountsafetyController(),
      id: "accountsafety",
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
