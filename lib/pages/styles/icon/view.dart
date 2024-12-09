import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class IconPage extends GetView<IconController> {
  const IconPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return ListView(
      children: [
        ListTile(
          leading: IconWidget.icon(Icons.home),
          title: const TextWidget.body1('IconWidget.icon'),
        ),
        ListTile(
          leading: IconWidget.image(AssetsImages.settingPng),
          title: const TextWidget.body1('IconWidget.image'),
        ),
        ListTile(
          leading: IconWidget.url(
              'https://img.6tu.com/2022/02/20220216064614150.jpg'),
          title: const TextWidget.body1('IconWidget.url'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IconController>(
      init: IconController(),
      id: "icon",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text("icon")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
