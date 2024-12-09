import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/models/response_model/group_profile/group_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SetGroupAvatarController extends GetxController {
  SetGroupAvatarController();

  int operation = Get.arguments['operation']; // 1 创建群聊  2 修改群头像
  List<int> selectedMembers =
      Get.arguments['selectedMembers']; // 创建群聊时，选中群成员(修改群信息时无效)
  String groupName = Get.arguments['groupName']; // 群名称(修改群信息时无效)
  GroupProfile groupProfile = Get.arguments['groupProfile']; // 群信息(创建群无效)
  String? avatar;

  // 创建头像时，上传头像的URL
  String avatarUrl = '';

  _initData() {
    if (groupProfile.avatar != null && groupProfile.avatar!.isNotEmpty) {
      avatarUrl = groupProfile.avatar!;
    }
    update(["set_group_avatar"]);
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

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  void onAvatarTapped() {
    choosePhoto(ImageSource.gallery);
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

    var tempAatarName = '${groupProfile.groupId ?? 0}/${const Uuid().v1()}.png';
    OBSResponse? response =
        await OBSClient.putFile(tempAatarName, compressedFile);

    if ((response?.fileName ?? "") != "") {
      avatar = tempAatarName;
      avatarUrl = '$avatar';
      //avatarUrl = 'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/$avatar';
      Loading.dismiss();
      update(["set_group_avatar"]);
    } else {
      // 上传失败
      Loading.error('图片上传失败');
    }
  }

  Future<void> onSubmitTapped() async {
    if (avatar == null) {
      Loading.error('请先上传头像');
      return;
    }

    // 上传成功， //创建群聊
    if (operation == 1) {
      CreatGroupResultModel? model =
          await GroupApi.createGroup(avatar!, groupName, selectedMembers);
      if (model != null) {
        Loading.success('创建成功');
        // 回退到会话列表
        Get.back();
        Get.back();
        Get.back();
        // 刷新群
        await GroupManager.refreshGroupInfomation(model.groupId ?? 0);
        // todo 进入聊天页
      } else {
        Loading.error('创建失败');
      }
    } else if (operation == 2) {
      // 修改群头像
      bool success =
          await GroupApi.setGroupAvatar(groupProfile.groupId ?? 0, avatar!);
      if (success) {
        var group = groupProfile;
        group.avatar =
            'https://${ObsConfig.bucket}.${ObsConfig.endPoint}/$avatar';
        GroupManager.updateGroup(group);

        // 发送刷新事件
        RefreshGroupsEvent refreshGroupEvent =
            RefreshGroupsEvent(groupId: group?.groupId ?? 0);
        EventBusUtils.shared.fire(refreshGroupEvent);
        Get.back(result: group.avatar);
      }
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
