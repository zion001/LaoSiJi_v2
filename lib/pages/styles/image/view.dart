import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/widgets/image.dart';

import 'index.dart';

class ImagePage extends GetView<ImageController> {
  const ImagePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return ListView(
      children: const [
        ListTile(
          leading: ImageWidget.url(
              'https://www.ygexing.com/d/file/p/2022/09-18/83e4c77db286a44a2f1899a7b4efcc04.jpg'),
          title: TextWidget.body1('ImageWidget.url'),
        ),
        ListTile(
          leading: ImageWidget.asset(AssetsImages.settingPng),
          title: TextWidget.body1('ImageWidget.asset'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageController>(
      init: ImageController(),
      id: "image",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text("image")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
