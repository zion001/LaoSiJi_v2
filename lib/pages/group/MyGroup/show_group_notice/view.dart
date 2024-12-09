import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

import 'index.dart';

class ShowGroupNoticePage extends GetView<ShowGroupNoticeController> {
  const ShowGroupNoticePage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView() {
    return Text(controller.groupProfile?.notice ?? '').scrollable();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowGroupNoticeController>(
      init: ShowGroupNoticeController(),
      id: "show_group_notice",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '群公告',
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
