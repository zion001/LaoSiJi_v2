import 'package:im_flutter/common/index.dart';
import 'package:im_flutter/common/mqtt/im_client.dart';

class ConversationManager {
  //根据uid或者groupId获取ConversationModel
  static ConversationModel? getConversationModel(int conversationId) {
    Map<int, ConversationModel> conversations =
        ImClient.getInstance().conversationStreamModel.conversations;
    return conversations[conversationId];
  }

  //设置会话置顶
  static Future<PayloadModel> setSessionPinned(
      int conversationType, int conversationId, bool pinned) {
    return ImClient.getInstance()
        .setSessionPinned(conversationType, conversationId, pinned);
  }

  //删除会话
  static Future<PayloadModel> deleteSession(String sessionId) {
    return ImClient.getInstance().deleteSession(sessionId);
  }

  //清空聊天记录
  static Future<PayloadModel> clearHistoryMessage(int conversationType, int conversationId) {
    return ImClient.getInstance().clearHistoryMessage(conversationType,conversationId);
  }

  //获取会话列表
  static List<ConversationModel> getConversationList() {
    Map<int, ConversationModel> conversations =
        ImClient.getInstance().conversationStreamModel.conversations;
    List<ConversationModel> listConversationModel =
        conversations.values.toList();
    listConversationModel
        .sort(ImClient.getInstance().conversationStreamModel.sortConversation);

    return listConversationModel;
  }
}
