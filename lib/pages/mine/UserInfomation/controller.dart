import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/routers/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class UserinfomationController extends GetxController {
  UserinfomationController();

  _initData() {
    update(["userinfomation"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void onChangeNameTapped() {
    Get.toNamed(RouteNames.mineChangeNickname);
  }

  void onQRCodeTapped() {
    Get.toNamed(RouteNames.mineQRCode);
  }

  void onAvatarTapped() {
    Get.bottomSheet(
      <Widget>[
        // 从相册选择
        TextWidget.title2(LocaleKeys.minePhotoAlbum.tr)
            .paddingAll(AppSpace.card)
            .onTap(() {
          choosePhoto(ImageSource.gallery);
          Get.back();
        }),
        // 用相机拍摄
        TextWidget.title2(LocaleKeys.mineCamera.tr)
            .paddingAll(AppSpace.card)
            .onTap(() {
          choosePhoto(ImageSource.camera);
          Get.back();
        }),
      ]
          .toColumn(
            mainAxisSize: MainAxisSize.min,
          )
          .backgroundColor(AppColors.background),
    );
  }

  // 从相册选择
  void choosePhoto(ImageSource source) async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      return;
    }
    File file = File(pickedFile!.path);
    Loading.show();
    File? compressedFile = await compress(file);
    if (compressedFile == null) {
      Loading.dismiss();
      return;
    }

    var name =
        '${UserService.to.profile.user_id ?? 0}/${const Uuid().v1()}.png';
    OBSResponse? response = await OBSClient.putFile(name, compressedFile);

    if ((response?.fileName ?? "") != "") {
      // 上传成功
      UserProfileModel? model = await UserApi.changeAvatar(avatar: name);
      //await UserApi.changeAvatar(avatar: response?.url ?? "");
      if (model != null) {
        Loading.success('更新头像成功');
        // 更新用户数据
        UserService.to.updateMyProfile(model);
      }
    } else {
      // 上传失败
      Loading.error('头像上传失败');
    }
  }

  /// 压缩图片
  Future<File?> compress(File file) async {
    final Directory temp = await getTemporaryDirectory();
    var path = file.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    File? newFile = await FlutterImageCompress.compressAndGetFile(
        path, '${temp.path}/img_$name.jpg',
        minWidth: 300, minHeight: 300, quality: 80);
    return newFile;
  }
}
