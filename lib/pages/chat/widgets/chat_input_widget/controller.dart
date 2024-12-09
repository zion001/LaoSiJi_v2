import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:im_flutter/common/mqtt/message_stream_model.dart';

enum InputStauts {
  text,
  audio,
  emoji,
  more,
}

class ChatInputWidgetController extends GetxController {
  ChatInputWidgetController();
  ConversationModel? chatConversation;
  ScrollController? scrollController;
  StreamSubscription? subscription;
  StreamSubscription? editMessageSubscription;
  MessageStreamModel? _messageStreamModel;
  MessageModel? refMessage;
  bool isEdit = false;

  final isVoiceInput = false.obs;

  /*
  ConversationModel? _chatConversation;
  ConversationModel? get chatConversation => _chatConversation;
  set chatConversation(ConversationModel? model) {
    chatConversation = model;
  }
  */

  set messageStreamModel(MessageStreamModel model) {
    _messageStreamModel = model;
    editMessageSubscription?.cancel();
    editMessageSubscription = _messageStreamModel!.getEditMessage().listen((event) {
      refMessage=event;
        if(refMessage?.msg_body?.reply_message != null && refMessage?.msg_body?.reply_message?.message_id == null) {
          isEdit = false;

        }else{
          isEdit = true;
          inputTextFieldController.text = event?.msg_body?.text ?? '';
        }

        update(["chat_input_widget"]);
    });
  }
  
  //文本输入控制器
  TextEditingController inputTextFieldController = TextEditingController();

  //焦点
  FocusNode focusNode = FocusNode();

  // 当前输入的状态
  InputStauts status = InputStauts.text;

  // 禁言状态
  bool isMuted = false;

  // 当前状态，下方组件高度
  double bottomContainerH = 0.0;

  bool showMore = false;
  bool showSendSoundText = false;
  bool showEmojiPanel = false;
  bool showKeyboard = false;

  TextEditingController searchController = TextEditingController();

  GroupMemberModel allMemberModel = GroupMemberModel(userId: 0,nickname: '所有人');
  String lastInput = '';

  _initData() {
    // 监听群刷新事件，判断是否被禁言
    subscription = EventBusUtils.shared.on<RefreshGroupsEvent>().listen((event) {
      if (event.groupId != (chatConversation?.group_id)) {
        return;
      }
      bool mute = GroupManager.isMuted(event.groupId);
      if (mute != isMuted) {
        isMuted = mute;
        if (isMuted) {
          onMute();
        }
        update(["chat_input_widget"]);
      }
    });


    
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        status = InputStauts.text;
        bottomContainerH = 0.0;
        update(["chat_input_widget"]);
      } else {
        print("失去焦点");
      }
    });

    update(["chat_input_widget"]);

    // 延时一小会儿，不然chatConversation还没有值
    Future.delayed(const Duration(milliseconds: 100), (){
      isMuted = GroupManager.isMuted(chatConversation?.group_id ?? 0);
      update(["chat_input_widget"]);
    });

  }


  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    super.onClose();
    focusNode.dispose();
    inputTextFieldController.dispose();
    subscription?.cancel();
    editMessageSubscription?.cancel();
  }



  // 禁言
  void onMute() {
    hideKeyBoard();
    bottomContainerH = 0;
    showKeyboard = false;
    showEmojiPanel = false;
    showSendSoundText = false;
    showMore = false;
  }

  Future<bool> checkPermission(int value) async {
    final status = await Permission.byValue(value).status;
    if (status.isGranted) {
      return true;
    }

    return await Permission.byValue(value).request().isGranted;
  }

  // 点击MIC
  void onTapMic() async{
    bool hasMicrophonePermission =
        await checkPermission(Permission.microphone.value);
    // if (!hasMicrophonePermission) {
    //   return;
    // }

    isVoiceInput.value = !isVoiceInput.value;
    print('MIC');
    if(isVoiceInput.value) {
      status = InputStauts.audio;
      bottomContainerH = 0.0;
      hideKeyBoard();
    }else{
      focusNode.requestFocus();
    }
    update(["chat_input_widget"]);
  }

  // 点击表情
  void onTapEmoji() {
    print('emoji');
    status = InputStauts.emoji;
    bottomContainerH = 250.0;
    hideKeyBoard();

    isVoiceInput.value = false;

    showKeyboard = false;
    showEmojiPanel = true;
    showSendSoundText = false;
    showMore = false;
    update(["chat_input_widget"]);
  }

  // 点击更多
  void onTapMore() {
    print('more');
    status = InputStauts.more;
    bottomContainerH = 250.0;
    hideKeyBoard();

    isVoiceInput.value = false;

    showKeyboard = false;
    showEmojiPanel = false;
    showSendSoundText = false;
    showMore = true;
    update(["chat_input_widget"]);
  }

  void onTapSend() {
    bool scrollDown = true;
    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    if (inputTextFieldController.text.isNotEmpty) {
      if(refMessage!=null && isEdit){
        MsgBodyModel msgBodyModel = MsgBodyModel.copyFrom(refMessage?.msg_body);
        msgBodyModel.text = inputTextFieldController.text;
        ImClient.getInstance().modifyMessage(refMessage!.message_id!, msgBodyModel);
        _messageStreamModel!.editMessage(null);
        scrollDown = false;
      }else {
        String sendText = inputTextFieldController.text.trim();
        if (sendText.isNotEmpty) {
          List<int> atMembers = addAtMember(sendText);
          bool? isAtAll;
          if (atMembers.contains(0)) {
            isAtAll = true;
            atMembers.remove(0);
          }
          MessageModel? replyMessageModel;
          if(refMessage!=null) {
            replyMessageModel = refMessage;

            //回复加@
            if (refMessage?.from_uid != UserService.to.profile.user_id) {
              if (!atMembers.contains(refMessage?.from_uid)) {
                atMembers.add(refMessage!.from_uid!);
              }
            }
            _messageStreamModel!.replyMessage(null);
          }

          MessageModel messageModel = ImClient.getInstance().addSendingMessage(
              convesationType, conversationId,
              msgText: sendText, atMembers: atMembers, isAtAll: isAtAll,replyMessage: replyMessageModel);

          ImClient.getInstance().sendMessage(convesationType, conversationId,
              msgBodyModel: messageModel.msg_body);
        }
      }
      inputTextFieldController.text = '';
      lastInput = '';
      update(["chat_input_widget"]);

      if(scrollDown)
        scrollController?.jumpTo(scrollController!.position.minScrollExtent);
    }
  }

  // 从相册选择
  void choosePhoto(ImageSource source) async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      return;
    }
    File file = File(pickedFile!.path);

    //final imageSize = ImageSizeGetter.getSize(FileInput(file));
    final imageSize = await decodeImageFromList(file.readAsBytesSync());

    String? attachment;
    File? compressedFile = await compress(file);
    if(compressedFile != null)
      attachment = await makeBase64(compressedFile.path);

    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    MessageModel messageModel = ImClient.getInstance().addSendingMessage(
        convesationType,
        conversationId,
        msgImage: file.path,
        attachment: attachment,
        width: imageSize.width,
        height: imageSize.height
    );
    scrollController?.jumpTo(scrollController!.position.minScrollExtent);
    bottomContainerH = 0.0;
    update(["chat_input_widget"]);

    List pathSplit = file.path.split('/') ?? [];
    String fileName = pathSplit.last;
    List fileNameSplit = fileName.split('.') ?? [];
    String fileExt = '';
    if (fileNameSplit.length > 0) fileExt = '.' + fileNameSplit.last;
    var name =
        '${UserService.to.profile.user_id ?? 0}/${const Uuid().v1()}${fileExt}';
    OBSResponse? response = await OBSClient.putFile(name, file);

    if ((response?.fileName ?? "") != "") {
      // 上传成功
      messageModel.msg_body?.url = response?.url;
      ImClient.getInstance().sendMessage(convesationType, conversationId,
          msgBodyModel: messageModel.msg_body);
      //ImClient.getInstance().sendMessage(convesationType, conversationId,
      //    msgImage: response?.url,attachment: attachment);
      //Loading.dismiss();
    } else {
      // 上传失败
      //Loading.error('上传失败');
      ImClient.getInstance().sendingMessageFail(convesationType, conversationId,
           messageModel);
    }
  }

  /// 压缩图片
  Future<File?> compress(File file) async {
    final Directory temp = await getTemporaryDirectory();
    var path = file.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    File? newFile = await FlutterImageCompress.compressAndGetFile(
        path, '${temp.path}/img_$name.jpg',
        minWidth: 200,
        minHeight: 200,
        quality: 50);
    return newFile;
  }

  // 选择视频
  void chooseVideo(ImageSource source) async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickVideo(source: source);
    if (pickedFile == null) {
      return;
    }
    File file = File(pickedFile!.path);
    var info = await FlutterVideoInfo().getVideoInfo(pickedFile!.path);
    final uint8list = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    var base64Data = base64.encode(uint8list!);
    String attachment = 'data:image/jpeg;base64,$base64Data';

    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    int? videoWidth = (info?.orientation == 90 || info?.orientation == 270)?info?.height:info?.width;
    int? videoHeight = (info?.orientation == 90 || info?.orientation == 270)?info?.width:info?.height;
    MessageModel messageModel = ImClient.getInstance().addSendingMessage(
        convesationType,
        conversationId,
        msgVideo: Uri.encodeFull(file.path),
        width: videoWidth,
        height: videoHeight,
        attachment: attachment,
    );
    scrollController?.jumpTo(scrollController!.position.minScrollExtent);
    bottomContainerH = 0.0;
    update(["chat_input_widget"]);

    List pathSplit = file.path.split('/') ?? [];
    String fileName = pathSplit.last;
    List fileNameSplit = fileName.split('.') ?? [];
    String fileExt = '';
    if (fileNameSplit.length > 0) fileExt = '.' + fileNameSplit.last;
    var name =
        '${UserService.to.profile.user_id ?? 0}/${const Uuid().v1()}${fileExt}';
    OBSResponse? response = await OBSClient.putFile(name, file);

    if ((response?.fileName ?? "") != "") {
      // 上传成功
      messageModel.msg_body?.url = response?.url;
      ImClient.getInstance().sendMessage(convesationType, conversationId,
          msgBodyModel: messageModel.msg_body);

    } else {
      // 上传失败
      ImClient.getInstance().sendingMessageFail(convesationType, conversationId,
          messageModel);
    }
  }

  void chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }
    File file = File(result!.files.single.path!);
    List pathSplit = file.path.split('/') ?? [];
    String fileName = pathSplit.last;
    List fileNameSplit = fileName.split('.') ?? [];
    String fileExt = '';
    if (fileNameSplit.length > 0) fileExt = '.' + fileNameSplit.last;
    var name =
        '${UserService.to.profile.user_id ?? 0}/${const Uuid().v1()}${fileExt}';

    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    MessageModel messageModel = ImClient.getInstance().addSendingMessage(convesationType, conversationId,msgFile: file.path,fileName: fileName);
    scrollController?.jumpTo(scrollController!.position.minScrollExtent);
    bottomContainerH = 0.0;
    update(["chat_input_widget"]);

    OBSResponse? response = await OBSClient.putFile(name, file);

    if ((response?.fileName ?? "") != "") {
      // 上传成功
      messageModel.msg_body?.url = response?.url;
      ImClient.getInstance().sendMessage(convesationType, conversationId,
         msgBodyModel: messageModel.msg_body);

    } else {
      // 上传失败
      ImClient.getInstance().sendingMessageFail(convesationType, conversationId,
          messageModel);
    }
  }

  void choosePerson() async{
    var selectContact = await Get.toNamed(RouteNames.chatSelectContact);
    if(selectContact!=null){
      int convesationType;
      int conversationId;
      if (chatConversation?.friend_profile != null) {
        convesationType = 1;
        conversationId = chatConversation!.friend_profile!.uid!;
      } else {
        convesationType = 2;
        conversationId = chatConversation!.group_profile!.groupId!;
      }

      UserCardModel userCardModel = UserCardModel(
        uid:selectContact.uid,
        nickname:selectContact.user_profile?.nickname,
        avatar: selectContact.user_profile?.avatar,
        username: selectContact.user_profile?.username,
      );

      MessageModel messageModel = ImClient.getInstance().addSendingMessage(
          convesationType, conversationId,
          msgUser: userCardModel);
      ImClient.getInstance().sendMessage(convesationType, conversationId,
          msgBodyModel: messageModel.msg_body);

      update(["chat_input_widget"]);

      scrollController?.jumpTo(scrollController!.position.minScrollExtent);

    }
  }

  startRecord() {
    print("开始录制");
  }

  Future<String?> makeBase64(String path) async {
    List fileNameSplit = path.split('.') ?? [];
    String fileExt = '';
    if (fileNameSplit.length > 0) fileExt = fileNameSplit.last;
    String mediaType;
    if(fileExt == 'wav'){
      mediaType = 'audio/x-wav';
    }else{
      mediaType = 'image/' + fileExt;
    }
    try {
      File file = File(path);
      if (await file.exists()) {
        file.openRead();
        var contents = await file.readAsBytes();
        var base64File = base64.encode(contents);

        return 'data:$mediaType;base64,$base64File';
      } else
        return null;
    } catch (e) {
      print(e.toString());

      return null;
    }
  }

  stopRecord(String path, double audioTimeLength) async {
    print("结束束录制");
    print("音频文件位置" + path);
    print("音频录制时长" + audioTimeLength.toString());
/*
    final fileString = await makeBase64(path);
    if(fileString!=null) {

      ImClient.getInstance().sendMessage(convesationType, conversationId,
          msgAudio: fileString, duration: audioTimeLength);
    }

 */
    File file = File(path);
    int convesationType;
    int conversationId;
    if (chatConversation?.friend_profile != null) {
      convesationType = 1;
      conversationId = chatConversation!.friend_profile!.uid!;
    } else {
      convesationType = 2;
      conversationId = chatConversation!.group_profile!.groupId!;
    }
    MessageModel messageModel = ImClient.getInstance().addSendingMessage(convesationType, conversationId,msgAudio: file.path,duration: audioTimeLength);


    List pathSplit = file.path.split('/') ?? [];
    String fileName = pathSplit.last;
    List fileNameSplit = fileName.split('.') ?? [];
    String fileExt = '';
    if (fileNameSplit.length > 0) fileExt = '.' + fileNameSplit.last;
    var name =
        '${UserService.to.profile.user_id ?? 0}/${const Uuid().v1()}${fileExt}';
    OBSResponse? response = await OBSClient.putFile(name, file);

    if ((response?.fileName ?? "") != "") {
      // 上传成功
      messageModel.msg_body?.url = response?.url;
      ImClient.getInstance().sendMessage(convesationType, conversationId,
          msgBodyModel: messageModel.msg_body, duration: audioTimeLength);

    } else {
      // 上传失败
      ImClient.getInstance().sendingMessageFail(convesationType, conversationId,
          messageModel);
    }
  }

  //隐藏键盘而不丢失文本字段焦点：
  void hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  //失去焦点
  void unFocusFunction() {
    focusNode.unfocus();
  }

  void onTapMember(GroupMemberModel member){
    // atMembers.add(member);
    // atPos.add(inputTextFieldController.text.length - 1);
    inputTextFieldController.text += (member.nickname??'') + ' ';
    lastInput = inputTextFieldController.text;
    Get.back();
  }

  void onTextChange(String value){
    /*
    for(int i = atPos.length - 1;i>=0;i--){
      int start = atPos[i];
      int end = start + 1 + atMembers[i].nickname!.length;
      if(end > value.length || value.substring(start ,end) != ('@' + atMembers[i].nickname!)){
        if(value.substring(start) == '@' + atMembers[i].nickname!.substring(0,atMembers[i].nickname!.length - 1)){
          inputTextFieldController.text = value.substring(0, start);
        }
        else if(value.length> start && value.substring(start,start + 1) == '@') {
          inputTextFieldController.text =
              value.substring(0, start) + value.substring(start + 1);
        }
        atPos.removeAt(i);
        atMembers.removeAt(i);

      }
    }

     */

    lastInput = value;
  }

  List<int> addAtMember(String text){
    List<int> atMembers = [];
    List<GroupMemberModel> groupMembers = [allMemberModel];
    if ((chatConversation?.group_profile?.members?.length ??
        0) > 0)
      groupMembers.addAll(
          chatConversation!.group_profile!.members);

    for(GroupMemberModel groupMemberModel in groupMembers){
      if(text.contains('@' + groupMemberModel.nickname!)){
        atMembers.add(groupMemberModel.userId!);
      }
    }
    return atMembers;
  }
}


/*关于focusNode的常用方法代码如下：

//获取焦点
void getFocusFunction(BuildContext context){
  FocusScope.of(context).requestFocus(focusNode);
}

//失去焦点
void unFocusFunction(){
  focusNode.unfocus();
}

//隐藏键盘而不丢失文本字段焦点：
void hideKeyBoard(){
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

*/
