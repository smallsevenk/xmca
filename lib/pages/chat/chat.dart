// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart' hide Text;
// import 'package:xkit/x_kit.dart';
// import 'package:xmca/cubit/chat_cubit.dart';
// import 'package:xmca/repo/resp/message.dart';

// class ChatRoomPage extends StatefulWidget {
//   const ChatRoomPage({super.key});

//   @override
//   State<ChatRoomPage> createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   late final ChatCubit _cubit;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _textController = TextEditingController();

//   // 用于测量 ListView 可视区域位置与高度
//   final GlobalKey _listKey = GlobalKey();

//   // 新增：当内容未填满整屏时，动态增加底部 padding，保证最后一条消息完全可见
//   double _extraBottomPadding = 0.0;

//   // 新增：是否显示“回到底部”按钮
//   bool _showScrollToBottom = false;

//   // 节流/防抖相关
//   DateTime? _lastAdjustAt;
//   bool _adjustScheduled = false;
//   Timer? _scrollDebounceTimer;
//   static const Duration _adjustThrottle = Duration(milliseconds: 40);
//   static const Duration _scrollDebounce = Duration(milliseconds: 100);

//   @override
//   void initState() {
//     super.initState();
//     _cubit = ChatCubit();

//     // 页面构建完成后滚到底部，确保最后一条消息可见
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom(jump: true);
//     });

//     // 监听滚动，决定是否显示回到底部按钮
//     _scrollController.addListener(_handleScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScroll);
//     _scrollTimerCancel();
//     _cubit.close(); // 释放 cubit
//     _scrollController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   void _scrollTimerCancel() {
//     _scrollDebounceTimer?.cancel();
//     _scrollDebounceTimer = null;
//   }

//   // 新增：滚动监听器，距离底部超过阈值时显示按钮（防抖）
//   void _handleScroll() {
//     if (!_scrollController.hasClients || !_scrollController.position.haveDimensions) return;
//     _scrollTimerCancel();
//     _scrollDebounceTimer = Timer(_scrollDebounce, () {
//       final max = _scrollController.position.maxScrollExtent;
//       final cur = _scrollController.offset;
//       final shouldShow = (max - cur) > 80.0; // 阈值可调
//       if (shouldShow != _showScrollToBottom) {
//         setState(() {
//           _showScrollToBottom = shouldShow;
//         });
//       }
//     });
//   }

//   void _sendMessage() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     Future.delayed(Duration(milliseconds: 300), () {
//       final text = _textController.text.trim();
//       if (text.isEmpty) return;
//       _textController.clear();
//       _cubit.sendUserMessage(text);

//       // 发送后隐藏回到底部按钮（消息会自动滚动）
//       if (_showScrollToBottom) {
//         setState(() {
//           _showScrollToBottom = false;
//         });
//       }
//     });
//   }

//   void _scrollToBottom({bool jump = false}) {
//     if (!_scrollController.hasClients) return;
//     if (!_scrollController.position.haveDimensions) return;
//     final target = _scrollController.position.maxScrollExtent;
//     final current = _scrollController.offset;
//     final delta = (target - current).abs();

//     // 若距离很大则直接 jump 避免长距离 animate 导致跳动感
//     if (jump || delta > 300) {
//       _scrollController.jumpTo(target);
//       return;
//     }

//     _scrollController.animateTo(
//       target,
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOut,
//     );
//   }

//   /// 确保最后一条消息可见：优先使用 last.key 的 ensureVisible（可设为 jump），没有 key 或失败则回退到 _scrollToBottom
//   void _ensureLastMessageVisible({bool preferJump = false}) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final state = _cubit.state;
//       if (state.messages.isEmpty) return;
//       final last = state.messages.last;
//       if (last.hasKey && last.key!.currentContext != null) {
//         try {
//           Scrollable.ensureVisible(
//             last.key!.currentContext!,
//             alignment: 1.0, // 保证底部可见（整条消息可见）
//             duration: preferJump
//                 ? const Duration(milliseconds: 0)
//                 : const Duration(milliseconds: 200),
//             curve: Curves.easeOut,
//           );
//           return;
//         } catch (_) {
//           // fallthrough to fallback
//         }
//       }
//       _scrollToBottom(jump: preferJump);
//     });
//   }

//   /// 在流式过程中调整滚动 回复过程中最后一条消息不够一屏时要保持整条消息内容可见
//   /// 如果因为内容增长导致消息底部超出可视区域，则不再继续向上移动，保持该消息顶部可见。
//   void _adjustScrollDuringStreaming(Message streamingMessage) {
//     // 节流：避免高频调用造成昂贵测量与滚动
//     final now = DateTime.now();
//     if (_lastAdjustAt != null && now.difference(_lastAdjustAt!) < _adjustThrottle) return;
//     _lastAdjustAt = now;

//     if (!streamingMessage.hasKey) return; // 无 key（无法测量）则直接返回
//     final listCtx = _listKey.currentContext; // 获取列表（容器）上下文
//     final msgCtx = streamingMessage.key!.currentContext; // 获取当前流式消息的上下文
//     if (listCtx == null || msgCtx == null) return; // 若任一为 null，则无法继续，返回

//     final RenderBox listBox = listCtx.findRenderObject() as RenderBox; // 列表的 RenderBox，用于几何计算
//     final RenderBox msgBox = msgCtx.findRenderObject() as RenderBox; // 消息的 RenderBox，用于几何计算

//     // final listTopGlobal = listBox.localToGlobal(Offset.zero).dy; // 列表顶部全局 y 坐标
//     // final listBottomGlobal = listTopGlobal + listBox.size.height; // 列表底部全局 y 坐标
//     // final msgTopGlobal = msgBox.localToGlobal(Offset.zero).dy; // 消息顶部全局 y 坐标
//     // final msgBottomGlobal = msgTopGlobal + msgBox.size.height; // 消息底部全局 y 坐标

//     // 如果消息底部与列表底部之间有间距，说明内容未填满一屏，需要把最后一条推到底部并增加底部 padding
//     // final double bottomGap = listBottomGlobal - msgBottomGlobal; // 计算消息底部与列表底部的间隙
//     // if (bottomGap > 1.0) {
//     //   // 有明显间隙（>1 px）时处理
//     //   final double newExtra = bottomGap; // 新的额外底部 padding 值
//     //   if ((newExtra - _extraBottomPadding).abs() > 0.5) {
//     //     // 变化显著时更新状态
//     //     setState(() {
//     //       _extraBottomPadding = newExtra; // 更新额外底部 padding，推内容到列表底部
//     //     });
//     //   }
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     // 在下一帧尝试把消息滚入视野底部
//     //     try {
//     //       Scrollable.ensureVisible(
//     //         msgCtx,
//     //         alignment: 1.0, // 底部对齐，保证消息底部可见（整条消息可见）
//     //         duration: const Duration(milliseconds: 0), // 立即对齐
//     //       );
//     //     } catch (_) {
//     //       _scrollToBottom(jump: true); // 兜底：若 ensureVisible 失败则直接跳到底部
//     //     }
//     //   });
//     //   return; // 已处理完不足一屏的情况，返回
//     // }

//     // 计算列表高度与消息高度，用于判断消息是否过大（接近或超过可视区）
//     final double listHeight = listBox.size.height; // 列表高度
//     final double msgHeight = msgBox.size.height; // 当前消息高度
//     const double largeMessageFactor = 0.92; // 判定为“大消息”的阈值因子（可调整）
//     debugPrint('列表高度 $listHeight，消息高度 $msgHeight');

//     if (msgHeight >= listHeight * largeMessageFactor) {
//       debugPrint('启用锁定到顶部模式');
//       // 如果消息高度接近或超过阈值
//       streamingMessage.lockedToTop = true; // 将消息置为“锁定到顶部”模式
//       try {
//         Scrollable.ensureVisible(
//           msgCtx,
//           alignment: 0.0,
//           duration: const Duration(milliseconds: 0),
//         ); // 确保消息顶部可见
//       } catch (_) {}
//       return; // 已处理大消息情况，返回
//     } else {
//       streamingMessage.lockedToTop = false;
//       debugPrint('消息底部在可视区内，滚到底部');
//       _scrollToBottom(); // 平滑滚到底部，保持最后消息完整可见
//     }

//     // // 如果消息没有被锁定到顶部，且消息底部在可视区域内，则可以安全滚到底部
//     // if (!streamingMessage.lockedToTop && msgBottomGlobal <= listBottomGlobal) {
//     //   debugPrint('消息底部在可视区内，滚到底部');
//     //   _scrollToBottom(); // 平滑滚到底部，保持最后消息完整可见
//     // } else {
//     //   // 否则（消息被锁定或底部不可见），确保消息顶部可见（不再向上移动以显示底部）
//     //   debugPrint('消息底部不可见或锁定到顶部，确保顶部可见');
//     //   if (msgTopGlobal < listTopGlobal) {
//     //     // 如果消息顶部在列表上边界上方（不可见）
//     //     try {
//     //       Scrollable.ensureVisible(
//     //         msgCtx,
//     //         alignment: 0.0, // 顶部对齐，确保消息顶部可见
//     //         duration: const Duration(milliseconds: 0),
//     //       );
//     //     } catch (_) {
//     //       // 兜底方案：手动计算并 jump 到目标偏移，避免异常时丢失可见性控制
//     //       final dyToTop = _scrollController.offset - (listTopGlobal - msgTopGlobal);
//     //       final target = dyToTop.clamp(0.0, _scrollController.position.maxScrollExtent);
//     //       _scrollController.jumpTo(target);
//     //     }
//     //   }
//     // }
//   }

//   void _scheduleAdjustStreaming(Message last) {
//     // 避免重复排期
//     if (_adjustScheduled) return;
//     _adjustScheduled = true;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _adjustScheduled = false;
//       _adjustScrollDuringStreaming(last);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     return BlocProvider.value(
//       value: _cubit,
//       child: BlocListener<ChatCubit, ChatState>(
//         bloc: _cubit,
//         listener: (context, state) {
//           // 每次流式更新时（最后一条为流式），让 UI 调整滚动行为
//           if (state.messages.isNotEmpty) {
//             final last = state.messages.last;
//             if (last.isStreaming) {
//               _scheduleAdjustStreaming(last);
//             } else {
//               // 流式结束后尽量滚到底部，并重置本地 extra padding
//               setState(() {
//                 _extraBottomPadding = 0.0;
//               });
//               // 使用 ensureVisible/jump 的统一方法，避免重复且在布局稳定后执行
//               _ensureLastMessageVisible(preferJump: true);
//             }
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: BlocBuilder<ChatCubit, ChatState>(
//               bloc: _cubit,
//               builder: (context, state) {
//                 return Text(state.roomInfo?.name ?? '聊天');
//               },
//             ),
//           ),
//           body: Column(
//             children: [
//               Expanded(
//                 child: Container(
//                   key: _listKey,
//                   child: BlocBuilder<ChatCubit, ChatState>(
//                     bloc: _cubit,
//                     builder: (context, state) {
//                       final messages = state.messages;
//                       return ListView.builder(
//                         controller: _scrollController,
//                         padding: EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 12,
//                         ).copyWith(bottom: 12 + bottomInset + _extraBottomPadding),
//                         itemCount: messages.length,
//                         keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//                         itemBuilder: (context, index) {
//                           final m = messages[index];
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 6),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               mainAxisAlignment: m.isMe
//                                   ? MainAxisAlignment.end
//                                   : MainAxisAlignment.start,
//                               children: [
//                                 if (!m.isMe) CircleAvatar(radius: 16, child: Text('他')),
//                                 const SizedBox(width: 8),
//                                 ConstrainedBox(
//                                   constraints: BoxConstraints(
//                                     maxWidth: MediaQuery.of(context).size.width * 0.72,
//                                   ),
//                                   child: Container(
//                                     // 只给正在流式更新的消息设置 key 以便测量位置
//                                     key: m.hasKey ? m.key : null,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                       horizontal: 14,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: m.isMe ? Colors.blueAccent : Colors.grey.shade200,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: const Radius.circular(16),
//                                         topRight: const Radius.circular(16),
//                                         bottomLeft: Radius.circular(m.isMe ? 16 : 4),
//                                         bottomRight: Radius.circular(m.isMe ? 4 : 16),
//                                       ),
//                                     ),
//                                     child: _buildMessageContent(m, context),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 if (m.isMe) CircleAvatar(radius: 16, child: Text('我')),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               // 输入框区域
//               SafeArea(
//                 top: false,
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 12, right: 12),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _textController,
//                           textInputAction: TextInputAction.send,
//                           onSubmitted: (_) => _sendMessage(),
//                           decoration: InputDecoration(
//                             hintText: '输入消息...',
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 12,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(20),
//                               borderSide: BorderSide.none,
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: _sendMessage,
//                         child: const Text('发送'),
//                         style: ElevatedButton.styleFrom(
//                           shape: const StadiumBorder(),
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ), // 新增：回到底部按钮（仅当 _showScrollToBottom 为 true 时显示）
//           floatingActionButton: _showScrollToBottom
//               ? FloatingActionButton(
//                   tooltip: '回到底部',
//                   onPressed: () {
//                     // 点击回到底部并隐藏按钮
//                     _ensureLastMessageVisible(preferJump: false);
//                     setState(() {
//                       _showScrollToBottom = false;
//                     });
//                   },
//                   child: const Icon(Icons.arrow_downward),
//                 )
//               : null,
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageContent(Message m, BuildContext context) {
//     // 对于普通文本直接渲染 Markdown（能处理图片/链接等）
//     final displayText = m.isStreaming ? (m.currentTextWithCursor) : m.text;
//     return MarkdownBody(
//       data: displayText,
//       styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
//         p: Theme.of(
//           context,
//         ).textTheme.bodyMedium?.copyWith(color: m.isMe ? Colors.white : Colors.black87),
//       ),
//       onTapLink: (text, href, title) async {
//         if (href == null) return;
//         final uri = Uri.tryParse(href);
//         if (uri != null && (href.endsWith('.mp4') || href.endsWith('.mov'))) {
//           // 视频直接用外部方式打开
//           // if (await canLaunchUrl(uri)) await launchUrl(uri);
//         } else {
//           print('点击链接: $href');
//         }
//       },
//       imageBuilder: (uri, title, alt) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(uri.toString(), fit: BoxFit.cover),
//         );
//       },
//     );
//   }
// }
