import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class InputsPage extends GetView<InputsController> {
  const InputsPage({Key? key}) : super(key: key);

// 主视图
  Widget _buildView() {
    return SingleChildScrollView(
      child: _buildInputs().center(),
    );
  }

  Widget _buildInputs() {
    return <Widget>[
      /// 文本
      const InputWidget.text(
        hintText: "文本",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 文本/边框
      const InputWidget.textBorder(
        hintText: "文本/边框",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 文本/填充/边框
      InputWidget.textFilled(
        hintText: "文本/填充/边框",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 图标/文本/填充/边框
      InputWidget.iconTextFilled(
        IconWidget.icon(
          Icons.home,
        ),
        fillColor: Colors.red.shade100,
        hintText: "图标/文本/填充/边框",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 后缀图标/文本/填充/边框
      InputWidget.suffixTextFilled(
        IconWidget.icon(
          Icons.home,
        ),
        hintText: "后缀图标/文本/填充/边框",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 搜索
      InputWidget.search(
        hintText: "搜索",
      ).width(300).paddingBottom(AppSpace.listRow),

      /// 表单输入框
      TextFormWidget(
        isMustBeEnter: false,
        labelText: LocaleKeys.commonCancel.tr,
        //validator: 输入验证
        hintText: '请输入用户名',
      ).paddingAll(16),

      /// 密码
      TextFormWidget(
        isMustBeEnter: true,
        labelText: LocaleKeys.commonCancel.tr,
        isObscure: true,
        hintText: '请输入密码',
        //validator: 输入验证
      ).paddingAll(16),

      // end
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InputsController>(
      init: InputsController(),
      id: "inputs",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text("inputs")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
