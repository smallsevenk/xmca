/*
 * 文件名称: chat_room_cubit.dart
 * 创建时间: 2025/10/31 09:57:09
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xkit/api/x_base_resp.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/global.dart';
import 'package:xmca/helper/user_manager.dart';
import 'package:xmca/pages/chat/util/nui_util.dart';
import 'package:xmca/pages/chat/data/chat_message_data.dart';
import 'package:xmca/pages/chat/data/chat_room_data.dart';
import 'package:xmca/repo/api/service/chat_room_service.dart';
import 'package:xmca/repo/api/service/user_service.dart';
import 'package:xmca/repo/resp/message_resp.dart';
import 'package:xmca/repo/resp/room_resp.dart';
import 'package:xmca/repo/resp/voice_resp.dart';

@immutable
abstract class ChatRoomState {
  get error => null;
}

class ChatRoomInitial extends ChatRoomState {}

// 加载房间信息
class LoadRoomState extends ChatRoomState {
  final ChatRoomResp? room;
  @override
  final Object? error;
  LoadRoomState({this.room, this.error});
}

// 历史记录
class ChatHistoryState extends ChatRoomState {
  final List<DBMessage>? messageList;
  @override
  final Object? error;
  ChatHistoryState({this.messageList, this.error});
}

// Cubit实现
class ChatRoomCubit extends Cubit<ChatRoomState> {
  ChatRoomCubit() : super(ChatRoomInitial());

  /// 加载房间信息
  void initRoomInfo(int? id) async {
    try {
      // 先登同步用户信息
      if (await UserService.instance.syncUserInfo()) {
        // 获取房间信息
        ChatRoomResp? room = await ChatRoomService.instance.getRoomInfo(id);
        var roomId = room?.roomId;
        if (room != null && roomId != null) {
          // 获取或创建本地房间数据
          room = await CARoomDataProvider.getRoom(room, userId: UserManager.userId);
          if (!isClosed) emit(LoadRoomState(room: room));
          // 修复消息状态
          await MessageDataProvider.fixMessageStatus(roomId);
          // 删除无效消息
          await MessageDataProvider.deleteInvalidMessage(roomId);
          // 同步消息
          var msgs = await onSyncCallEndMessageCallback(roomId, room, page: 0);
          // 获取推荐问题
          await getSuggestionAnswer(room: room, messages: msgs);
          return;
        }
      }
      if (!isClosed) emit(LoadRoomState(error: '获取客服信息失败'));
    } catch (e) {
      if (!isClosed) emit(LoadRoomState(error: e.toString()));
    }
  }

  Future<List<DBMessage>> onSyncCallEndMessageCallback(
    int roomId,
    ChatRoomResp room, {
    int? page,
  }) async {
    // 获取服务端消息历史记录
    final srvMsgs = await ChatRoomService.instance.getHistoryMessage(room: room);
    // 同步服务端和本地消息
    await MessageDataProvider.syncServerAndLocalMessages(srvMsgs, room);
    // 加载房间消息列表
    return await loadChatHistory(room: room, page: page);
  }

  /// 加载聊天历史记录
  Future<List<DBMessage>> loadChatHistory({required ChatRoomResp room, int? page}) async {
    List<DBMessage> queryList = [];
    try {
      // 初始化数据库
      queryList = await MessageDataProvider.getMessages(
        room.roomId,
        userId: UserManager.userId,
        page: page,
      );
      if (!isClosed) emit(ChatHistoryState(messageList: queryList));
    } catch (e) {
      if (!isClosed) emit(ChatHistoryState(error: '加载消息记录失败'));
    }
    return queryList;
  }

  Future<void> getSuggestionAnswer({required ChatRoomResp room, List<DBMessage>? messages}) async {
    if (messages == null || messages.isEmpty) return;
    var lastMsg = messages.last;
    // 本地没有推荐时获取推荐问题
    if ((lastMsg.suggestions ?? []).isEmpty) {
      lastMsg.suggestions = await ChatRoomService.instance.getSuggestionAnswer(
        room.roomId,
        messages.length <= 1 ? 0 : lastMsg.srvMsgId,
      );
      MessageDataProvider.updateMessages([lastMsg]);
      messages.last.messageItemKey.currentState?.reload();
      if (!isClosed) emit(ChatHistoryState(messageList: messages));
    }
  }

  Future<int> saveAgentMessage({
    required bool isAsrText,
    required String agentId,
    required String text,
    required ChatRoomResp room,
    required AiVoiceResp? voice,
    required ValueNotifier<bool> isPlaying,
    required bool mounted,
    required Function() onRefreshState,
    required List<DBMessage> messages,
  }) async {
    DBMessage sendMessage = DBMessage(
      isAsrText ? Role.sender : Role.receiver,
      text,
      ts: DateTime.now(),
      type: MessageType.text,
      roomId: room.roomId,
      userId: UserManager.userId,
      roleName: isAsrText ? room.userRole?.name ?? '' : '享脉龙',
      status: 1,
      agentId: agentId,
      statisticsType: 2,
    );
    int sendMessageId = await MessageDataProvider.sendMessage(sendMessage);
    if (sendMessageId != 0) {
      onRefreshState.call();
    }
    loadChatHistory(room: room);
    return sendMessageId;
  }

  /// 发送消息
  void sendMessage({
    required String text,
    required ChatRoomResp room,
    required AiVoiceResp? voice,
    required BuildContext context,
    required ValueNotifier<bool> isPlaying,
    required bool mounted,
    required Function() onRefreshState,
    required DBMessage Function() lastMessage,
    required Function() onScrollList,
  }) async {
    DBMessage sendMessage = DBMessage(
      Role.sender,
      text,
      ts: DateTime.now(),
      type: MessageType.text,
      roomId: room.roomId,
      userId: UserManager.userId,
      roleName: room.userRole?.name ?? '',
      status: 0,
      srvMsgId: -1,
      statisticsType: 2,
    );
    int sendMessageId = await MessageDataProvider.sendMessage(sendMessage);
    sendMessage.id = sendMessageId;

    DBMessage reciveMessage = DBMessage(
      Role.receiver,
      '',
      ts: DateTime.now(),
      type: MessageType.text,
      roomId: room.roomId,
      userId: UserManager.userId,
      roleName: room.aiRole?.name,
      status: 0,
      refId: sendMessage.id,
      srvMsgId: -1,
      statisticsType: 2,
    );
    int reciveMessageId = await MessageDataProvider.sendMessage(reciveMessage);
    reciveMessage.id = reciveMessageId;
    loadChatHistory(room: room);

    if (mounted && autoPlaySwitchIsOpen) {
      isPlaying.value = true;
      await NuiUtil.startStreamInputTts(voice: voice, autoPlay: true, context: () => context);
    }

    // 发起请求
    ChatRoomService.instance.fetchStreamData(
      '/room/sendMessage',
      params: {"roomId": room.roomId, "message": sendMessage.text, "imgList": [], "fileList": []},
      showData: true,
      onRespone: (resp) {
        try {
          if (mounted) {
            // 更新发送消息状态为成功
            if (resp == null) {
              sendMessage.status = 1;
              reciveMessage.status = 1;
            } else {
              CAAIMessage aiAnswerMessageResp = CAAIMessage.fromJson(resp.data);

              // 更新发送消息服务器ID
              if (aiAnswerMessageResp.userMessageId != null) {
                sendMessage.srvMsgId = aiAnswerMessageResp.userMessageId;
              }
              // 更新消息RoomId
              if (aiAnswerMessageResp.roomId != null) {
                sendMessage.roomId = aiAnswerMessageResp.roomId;

                reciveMessage.roomId = aiAnswerMessageResp.roomId;
                room.roomId = aiAnswerMessageResp.roomId!;
              }
              // 更新接收消息服务器ID
              if (aiAnswerMessageResp.aiMessageId != null) {
                reciveMessage.pid = aiAnswerMessageResp.userMessageId;
                reciveMessage.srvMsgId = aiAnswerMessageResp.aiMessageId;
              }
              // 更新接收消息内容
              if (aiAnswerMessageResp.content.trim().isNotEmpty) {
                reciveMessage.text = (reciveMessage.text) + aiAnswerMessageResp.content;
                var lastAiAnswer = lastMessage.call();
                // 打字机效果刷新最后一条Ai回复消息内容
                if (!lastAiAnswer.isSender && lastAiAnswer.status == 0) {
                  lastAiAnswer.messageItemKey.currentState?.updateContent(reciveMessage.text);

                  onScrollList.call();
                }

                NuiUtil.autoPlay(
                  aiAnswerMessageResp.content,
                  isPlaying: isPlaying,
                  mounted: mounted,
                );
              }
            }
            MessageDataProvider.updateMessages([sendMessage, reciveMessage]);
          }
        } catch (e, stackTrace) {
          showToast(e.toString(), stackTrace: stackTrace);
          // 更新发送消息状态为失败
          sendMessage.status = 2;
          reciveMessage.status = 2;
        }
      },
      onError: (error) async {
        if (error is XBaseResp) {
          if (100009 == error.code) {
            sendMessage.text = error.message;
          }
          // 更新发送消息状态为失败
          sendMessage.status = 2;
          reciveMessage.status = 2;
        }
        // 网络失败错误需要重发
        if (error is DioException || error.code == 100010) {
          sendMessage.status = 3;
          await MessageDataProvider.deleteInvalidMessage(room.roomId);
          await MessageDataProvider.updateMessages([sendMessage]);
          await loadChatHistory(room: room);
        }
      },
      onDone: () async {
        if (mounted) {
          NuiUtil.stopStreamTts(mounted);
          if (reciveMessage.status != 1) {
            MessageDataProvider.deleteMessages(reciveMessage.roomId ?? 0, [reciveMessage.id!]);
          }
          MessageDataProvider.updateMessages([sendMessage, reciveMessage]);
          var list = await loadChatHistory(room: room);
          getSuggestionAnswer(room: room, messages: list);
        }
      },
      onRefreshState: () => onRefreshState.call(),
    );
  }

  void deleteMessage(ChatRoomResp room, int msgId, {int? srvMsgId}) async {
    try {
      if (await ChatRoomService.instance.messageDelete(roomId: room.roomId, srvMsgId: srvMsgId)) {
        if (await MessageDataProvider.deleteMessages(room.roomId, [msgId])) {
          loadChatHistory(room: room);
        } else {
          showToast('删除消息失败');
        }
      }
    } catch (e) {
      showToast('删除消息失败: ${e.toString()}');
    }
  }

  void clearChatHistory(ChatRoomResp room) async {
    try {
      if (await ChatRoomService.instance.clear(roomId: room.roomId)) {
        if (await MessageDataProvider.clearMessages(room.roomId)) {
          showToast('聊天记录已清除');
          NuiUtil.cancelStreamInputTts();
          var msgs = await onSyncCallEndMessageCallback(room.roomId, room, page: 0);
          // 获取推荐问题
          await getSuggestionAnswer(room: room, messages: msgs);
        } else {
          showToast('清除聊天记录失败');
        }
      }
    } catch (e) {
      showToast('清除聊天记录失败: ${e.toString()}');
    }
  }
}
