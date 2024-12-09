import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'index.dart';

/***
 用于测试组件/样式
 ***/

class StyleIndexPage extends GetView<StyleIndexController> {
  const StyleIndexPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Column(
      children: [
        ListTile(
          onTap: controller.onLanguageSelected,
          title: Text(
            "语言:${ConfigService.to.locale.toLanguageTag()}",
          ),
        ),
        ListTile(
          onTap: controller.onThemeSelected,
          title: Text(
            "主题:${ConfigService.to.isDarkMode ? 'dark' : 'light'}",
          ),
        ),
        ListTile(
          onTap: () => Get.toNamed(RouteNames.stylesText),
          title: Text(
            "文本:${ConfigService.to.isDarkMode ? 'dark' : 'light'}",
          ),
        ),
        ListTile(
            onTap: () => Get.toNamed(RouteNames.stylesIcon),
            title: const TextWidget.body1('Icon 图标')),
        ListTile(
            onTap: () => Get.toNamed(RouteNames.stylesButtons),
            title: const TextWidget.body1('Button 按钮')),
        ListTile(
            onTap: () => Get.toNamed(RouteNames.stylesImage),
            title: const TextWidget.body1('Image 图片')),
        ListTile(
            onTap: () => Get.toNamed(RouteNames.stylesInputs),
            title: const TextWidget.body1('Input 输入框')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StyleIndexController>(
      init: StyleIndexController(),
      id: "style_index",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.stylesTitle.tr),
          ),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
