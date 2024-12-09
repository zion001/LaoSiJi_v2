import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:im_flutter/common/index.dart';

/// 功能单元格（名称/图标----内容-----图标）

class OptionListCell extends StatelessWidget {
  // 前方Widget
  Widget? prefix;
  // 后方Widget
  Widget? suffix;
  // 标题
  String title;
  // 内容
  String content;
  // 背景颜色
  Color? color;

  OptionListCell({
    super.key,
    this.prefix,
    this.suffix,
    this.title = '',
    this.content = '',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var array = <Widget>[];
    array.add(Gap(AppSpace.page));
    if (prefix != null) {
      array.add(prefix!.tightSize(40.w));
    }
    array.add(TextWidget.title3(title));
    array.add(TextWidget.body2(
      content,
      textAlign: TextAlign.right,
      color: AppColors.primary,
    ).expanded());
    if (suffix == null) {
      array.add(IconWidget.icon(Icons.arrow_right_sharp));
    } else {
      array.add(suffix!.tightSize(40.w));
    }
    array.add(Gap(AppSpace.page));
    return array.toRow().card(color: color);
  }
}
