import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';

class MyAppBar extends AppBar {
  MyAppBar(
    BuildContext context, //上下文，必须
    String titleName, //页面标题，必须
    {
    super.key,
    bool isCenterTitle = true, //是否中间居中，默认中间居中，参数可选
    final actions, //右边部分，可能存放图标，文字等，可能还有点击事件，参数可选
    final backIcon = const Icon(
      Icons.arrow_back_ios,
      //color: AppColors.onPrimary,
      size: 22,
    ), //左边返回箭头图标，默认是<，可自定义，，参数可选也可以是文字
    final String rightText = '', //右边文字，参数可选
    bool showBackIcon = true,
    final rightCallback, //右边文字或者图标的点击函数，参数可选
  }) : super(
          title: Text(titleName),
          leading: showBackIcon
              ? IconButton(icon: backIcon, onPressed: () => {Get.back()})
              : Text(""),
          centerTitle: isCenterTitle,
          elevation: 0,
          //  titleTextStyle: TextStyle(
          //      fontSize: 17,
          //      color: Colors.pink
          // ),
          toolbarHeight: 54.w,
          /* flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              DXPublicTheme.gradientBegin,
              DXPublicTheme.gradientEnd
            ], begin: Alignment.bottomLeft, end: Alignment.bottomRight)),
            
          ),
          */
          actions: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  rightCallback();
                },
                child: Container(
                  child: actions,
                ).paddingRight(10.w),
              ),
            )
          ],
        );
}
