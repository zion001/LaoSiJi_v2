import 'package:flutter/material.dart';
import 'package:im_flutter/common/index.dart';

class DateMessageWidget extends StatelessWidget {
  MessageModel messageModel;
  DateMessageWidget(this.messageModel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(messageModel.msg_body?.text ?? ''),
    );
  }
}
