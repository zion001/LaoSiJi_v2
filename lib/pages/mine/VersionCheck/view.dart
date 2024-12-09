import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class VersioncheckPage extends GetView<VersioncheckController> {
  const VersioncheckPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return const Center(
      child: Text("VersioncheckPage"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VersioncheckController>(
      init: VersioncheckController(),
      id: "versioncheck",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text("versioncheck")),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
