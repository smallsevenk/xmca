// import 'dart:async';
// import 'package:xkit/x_kit.dart';
// import 'package:xmca/repo/resp/message.dart';
// import 'package:xmca/repo/resp/message_resp.dart';
// import 'package:xmca/repo/resp/room.dart';

// class ChatState {
//   final List<DBMessage> messages;
//   final RoomInfo? roomInfo;
//   ChatState({required this.messages, this.roomInfo});

//   ChatState copyWith({List<DBMessage>? messages, RoomInfo? roomInfo}) {
//     return ChatState(messages: messages ?? this.messages, roomInfo: roomInfo ?? this.roomInfo);
//   }
// }

// class ChatCubit extends Cubit<ChatState> {
//   ChatCubit() : super(ChatState(messages: [])) {
//     _initRoom();
//     fetchRoomInfo(); // 初始化时拉取房间信息
//   }

//   void _initRoom() {
//     final now = DateTime.now();
//     final items = List.generate(200, (i) {
//       return DBMessage(
//         text: '示例消息 #$i: 这是测试消息，用来填充列表，长度可变$full',
//         time: now.subtract(Duration(minutes: 30 - i)),
//         isMe: i % 3 == 0,
//       );
//     });
//     emit(ChatState(messages: items));
//   }

//   void sendUserMessage(String text) {
//     if (text.trim().isEmpty) return;
//     final msgs = List<Message>.from(state.messages);
//     msgs.add(Message(text: text.trim(), time: DateTime.now(), isMe: true));
//     emit(ChatState(messages: msgs));
//     // 异步触发AI流式回复
//     _startAiResponseSimulation();
//   }

//   //   Future<void> _startAiResponseSimulation() async {
//   //     final full = """
//   // **AI 回答示例**：

//   // 这里是一个示例的 Markdown 回复，包含图片与链接。

//   // ![示例图片](https://picsum.photos/200/120)

//   // - 支持列表
//   // - 支持 *斜体* 和 **加粗**

//   // 视频示例（点击打开）：
//   // https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4

//   // 更多信息请查看 [示例网站](https://example.com)。
//   // """;

//   //     final msgs = List<Message>.from(state.messages);
//   //     final message = Message.streaming(fullText: full, time: DateTime.now(), isMe: false);
//   //     msgs.add(message);
//   //     emit(ChatState(messages: msgs));

//   //     // 打字机效果（分块更新）
//   //     final int chunkSize = 4;
//   //     for (int i = chunkSize; i <= full.length; i += chunkSize) {
//   //       await Future.delayed(const Duration(milliseconds: 40));
//   //       if (!isClosed) {
//   //         message.currentText = full.substring(0, i);
//   //         emit(ChatState(messages: List<Message>.from(state.messages)));
//   //       } else {
//   //         return;
//   //       }
//   //     }

//   //     if (message.currentText.length < full.length && !isClosed) {
//   //       await Future.delayed(const Duration(milliseconds: 40));
//   //       message.currentText = full;
//   //       emit(ChatState(messages: List<Message>.from(state.messages)));
//   //     }

//   //     // 结束：把完整文本赋回并结束流式状态
//   //     if (!isClosed) {
//   //       message.text = message.fullText;
//   //       message.isStreaming = false;
//   //       message.lockedToTop = false;
//   //       emit(ChatState(messages: List<Message>.from(state.messages)));
//   //     }
//   //   }
//   final String full = """
//     **AI 回答示例**：
//     这里是一个示例的 Markdown 回复，包含图片与链接。
//   if (msgHeight >= listHeight * largeMessageFactor) { // 如果消息高度接近或超过阈值
 
//     }
//   }
//     ![示例图片](https://gips0.baidu.com/it/u=1490237218,4115737545&fm=3028&app=3028&f=JPEG&fmt=auto?w=1280&h=720)

//     - 支持列表
//     - 支持 *斜体* 和 **加粗**

//     视频示例（点击打开）：
//     https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4

 
//       }
//     更多信息请查看 [示例网站](https://example.com)。
//     """;

//   /// 模拟 AI 流式回复（返回 Markdown 内容），并以“打字机”效果逐步更新最后一条消息。
//   Future<void> _startAiResponseSimulation() async {
//     // 示例包含图片、链接、视频链接（视频链接将作为普通链接处理）

//     final msgs = List<Message>.from(state.messages);
//     final message = Message.streaming(fullText: full, time: DateTime.now(), isMe: false);
//     msgs.add(message);

//     emit(ChatState(messages: msgs));

//     // 打字机效果：逐字符/分块更新
//     final int chunkSize = 4; // 每次添加多少字符，可调整
//     for (int i = chunkSize; i <= full.length; i += chunkSize) {
//       await Future.delayed(const Duration(milliseconds: 40));
//       if (!isClosed) {
//         message.currentText = full.substring(0, i);
//         emit(ChatState(messages: List<Message>.from(state.messages)));
//       } else {
//         return;
//       }
//     }

//     if (message.currentText.length < full.length && !isClosed) {
//       await Future.delayed(const Duration(milliseconds: 40));
//       message.currentText = full;
//       emit(ChatState(messages: List<Message>.from(state.messages)));
//     }

//     // 结束：把完整文本赋回并结束流式状态
//     if (!isClosed) {
//       message.text = message.fullText;
//       message.isStreaming = false;
//       message.lockedToTop = false;
//       emit(ChatState(messages: List<Message>.from(state.messages)));
//     }
//   }

//   /// 异步获取房间信息（此处为模拟接口，替换为真实网络请求即可）
//   Future<void> fetchRoomInfo({String roomId = 'default-room'}) async {
//     try {
//       // 模拟网络延迟
//       await Future.delayed(const Duration(milliseconds: 400));
//       // 模拟返回数据
//       final info = RoomInfo(
//         id: roomId,
//         name: '豆包聊天室',
//         topic: '讨论 AI 与开发',
//         avatarUrl: 'https://picsum.photos/48',
//         memberCount: 123,
//       );
//       emit(state.copyWith(roomInfo: info));
//     } catch (e) {
//       // 失败时保留原 state，可扩展为 emit error state
//     }
//   }

//   RoomInfo? get roomInfo => state.roomInfo;
// }
