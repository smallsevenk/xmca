/*
 * 文件名称: chat.dart
 * 创建时间: 2025/06/25 09:35:49
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 聊天室
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/cubit/ca_chat_room_cubit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/helper/ca_global.dart';
import 'package:xmca/pages/chat/widget/ca_chat_app_bar.dart';
import 'package:xmca/pages/chat/widget/ca_chat_input.dart';
import 'package:xmca/pages/chat/widget/ca_scroll_buttom.dart';
import 'package:xmca/pages/chat/util/ca_av_util.dart';
import 'package:xmca/pages/chat/util/ca_chat_input_enum.dart';
import 'package:xmca/pages/chat/widget/ca_chat_message_item.dart';
import 'package:xmca/pages/chat/widget/ca_chat_message_menu.dart';
import 'package:xmca/pages/chat/util/ca_nui_util.dart';
import 'package:xmca/pages/chat/data/ca_chat_message_data.dart';
import 'package:xmca/pages/comm/widgets/ca_alert.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';
import 'package:xmca/pages/comm/widgets/ca_logs.dart';
import 'package:xmca/repo/api/service/ca_chat_room_service.dart';
import 'package:xmca/repo/resp/ca_message_resp.dart';
import 'package:xmca/repo/resp/ca_room_resp.dart';
import 'package:xmca/repo/resp/ca_voice_resp.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // 是否显示“滚动到底部”按钮
  bool _showScrollToBottom = false;
  // 房间信息
  late ChatRoomResp _room;
  // 消息列表数据
  List<DBMessage> _messages = [];
  // 聊天工具栏模式
  final ValueNotifier<ChatInputMode> _chatInputMode = ValueNotifier(ChatInputMode.init);
  // 聊天工具栏Key
  final GlobalKey _igKey = GlobalKey();
  // 文本框控制器
  final TextEditingController _textController = TextEditingController();
  // 列表滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 语音合成相关
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  // 是否取消语音发送
  final ValueNotifier<bool> _cancelSend = ValueNotifier(false);
  // 音频振幅
  final ValueNotifier<List<double>> _amplitudes = ValueNotifier(List.filled(44, 0.4));

  GlobalKey<ScrollButtonState> myButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _room = ChatRoomResp(roomId: 0);
    WidgetsBinding.instance.addObserver(this);
    _initNui();
    _listenController();
    context.read<ChatRoomCubit>().initRoomInfo(null);
    // 获取字幕聊天数据
    CAAvUtil.syncChatMessagesOnCallFinished(() {
      context.read<ChatRoomCubit>().onSyncCallEndMessageCallback(_room.roomId, _room);
    });
    XPermissionUtil.checkMicAndSpeeh(context: () => context);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1624),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return _buildChatRoomContent(context);
      },
    );
  }

  Widget _buildChatRoomContent(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CAColor.cF4F5FA,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatRoomCubit, ChatRoomState>(
        listener: _onChatRoomStateChanged,
        builder: (context, state) {
          if (state is LoadRoomState && state.error != null) {
            return Center(
              child: Text(
                '客服助手已失联,\n请点击屏幕唤醒我哦',
                style: TextStyle(fontSize: 32.w, color: CAColor.c4F7EFF),
                textAlign: TextAlign.center,
              ),
            ).onTap(() {
              context.read<ChatRoomCubit>().initRoomInfo(null);
            });
          }
          if (state is ChatHistoryState) {
            return Column(
              children: [
                SizedBox(
                  width: 1,
                  height: 1,
                  child: ScrollButton(
                    key: myButtonKey,
                    onTap: () {
                      if (_scrollController.hasClients) {
                        var maxScroll = _scrollController.position.maxScrollExtent;
                        _scrollController.jumpTo(maxScroll);
                      }
                    },
                  ),
                ),
                _buildMessageList(),
                ValueListenableBuilder(
                  valueListenable: _chatInputMode,
                  builder: (BuildContext context, dynamic value, Widget? child) =>
                      _buildChatInput(context),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  _pushLoglist() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CALogListPage()));
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return ChatAppBar(
      title: _room.name ?? '',
      onTitleTap: () {
        _pushLoglist();
      },
      autoPlay: autoPlaySwitchIsOpen,
      onBack: () {
        if (csBackToNative != null) {
          csBackToNative?.call();
        } else {
          Navigator.pop(context);
        }
      },
      onAutoPlayTap: () {
        setState(() {
          setAutoPlay();
        });
        showToast('自动播放已${autoPlaySwitchIsOpen ? '开启' : '关闭'}');
      },
      onClearTap: () {
        CAAlert.show(
          context: () => context,
          content: '确认清空对话记录吗？',
          onConfirm: () {
            context.read<ChatRoomCubit>().clearChatHistory(_room);
          },
        );
      },
    );
  }

  /// 构建聊天输入框
  ChatInput _buildChatInput(BuildContext context) {
    return ChatInput(
      igKey: _igKey,
      reloadMessageList: _loadChatHistory,
      textController: _textController,
      chatInputMode: _chatInputMode,
      context: context,
      onSendMessage: _sendMessage,
      onScrollListToHead: _scrollListToHead,
      amplitudes: _amplitudes,
      cancelSend: _cancelSend,
      onHumanCs: () async {
        // 测试流式语音播放拦截测试代码
        // await CANuiUtil.startStreamInputTts(
        //   voice: _room.aiRole?.voice,
        //   autoPlay: true,
        //   context: () => context,
        // );
        // CANuiUtil.autoPlay('👉人工客服](', isPlaying: _isPlaying, mounted: mounted);
        // CANuiUtil.autoPlay('http://xxx.xmca', isPlaying: _isPlaying, mounted: mounted);
        // CANuiUtil.autoPlay(')', isPlaying: _isPlaying, mounted: mounted);
        // Future.delayed(Duration(microseconds: 1000)).then((e) {
        //   CANuiUtil.stopStreamTts(mounted);
        // });
        csHumanCustomerService?.call([]);
      },
      onStartRecognition: (details) {
        NuiUtil.startVoiceRecognition(
          context: () => context,
          globalPosition: details.globalPosition,
          isPlaying: _isPlaying,
          chatInputMode: _chatInputMode,
          cancelSend: _cancelSend,
        );
      },
      onStopRecognition: () {
        if (mounted) {
          NuiUtil.stopVoiceRecognition(chatInputMode: _chatInputMode, amplitudes: _amplitudes);
        }
      },
      onCallAgentType: (isVoice) {
        CAAvUtil.startAvCall(_room, isVoice);
      },
    );
  }

  // 在 _buildMessageList 里
  Widget _buildMessageList() {
    return Flexible(
      child: Scrollbar(
        controller: _scrollController,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 30),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(_messages.length, (index) => _buildMessageItem(index: index)),
            ),
            // 悬浮“滚动到底部”按钮
            if (_showScrollToBottom)
              Padding(
                padding: EdgeInsets.all(24.w),
                child: CAImage('scroll', width: 112.w),
              ).onTap(() {
                myButtonKey.currentState?.handleTap();
              }),
          ],
        ).onTap(_blankOnTap),
      ),
    );
  }

  /// 消息列表项
  Widget _buildMessageItem({required int index}) {
    DBMessage item = _messages[index];

    return ChatMessageItem(
      key: item.messageItemKey,
      item: item,
      isLast: () => index == _messages.length - 1,
      getMessages: () => _messages,
      isPlaying: _isPlaying,
      stopPlay: () => _stopPlay(),
      onLongPressStart: (details) => _handleLongPressStart(details, index),
      onResend: (DBMessage message) async {
        CAAlert.show(
          context: () => context,
          title: '重发该条消息？',
          onConfirm: () async {
            try {
              // 处理重发逻辑
              debugPrint('重发消息: ${message.text}');
              await MessageDataProvider.deleteMessages(_room.roomId, [message.id!]);
              _sendMessage(message.text);
            } catch (e) {
              showToast('重发失败');
            }
          },
        );
      },
      onPlay: () async {
        if (_isPlaying.value) {
          _stopPlay();
        } else {
          await NuiUtil.playText(
            text: _messages[index].text,
            voice: _voice,
            isPlaying: _isPlaying,
            mounted: mounted,
            context: () => context,
          );
        }
      },
      onCopy: () => _copyMessage(index),
      onSendPrmpt: _sendMessage,
    );
  }

  /// 监听聊天状态变化
  void _onChatRoomStateChanged(BuildContext context, ChatRoomState state) {
    if (state is LoadRoomState && state.room != null) {
      _room = state.room!;
      if (mounted) {
        setState(() {});
      }
    } else if (state is ChatHistoryState) {
      _messages = state.messageList ?? [];
      _scrollListToHead();
    }
  }

  /// 长按消息处理
  void _handleLongPressStart(LongPressStartDetails details, int index) {
    final msg = _messages[index];

    CAMessageItemMenu.showMenuWithActions(
      inputGlobalKey: _igKey,
      context: context,
      globalPosition: details.globalPosition,
      index: index,
      msg: msg,
      onCopy: _copyMessage,
      onDelete: _deleteMessage,
      onPlay: (idx) async {
        await NuiUtil.playText(
          text: _messages[index].text,
          voice: _voice,
          isPlaying: _isPlaying,
          mounted: mounted,
          context: () => context,
        );
      },
    );
  }

  // 消息操作功能
  void _copyMessage(int index) {
    Clipboard.setData(ClipboardData(text: _messages[index].text));
    showToast('已复制');
  }

  // 删除
  void _deleteMessage(int index) async {
    if (!(await checkNetwork())) {
      showToast("网络信号异常,请检查您的网络");
      return;
    }
    if (mounted) {
      titleFocusNode.requestFocus();
      CAAlert.show(
        context: () => context,
        content: '确认删除该条对话记录吗？',
        onConfirm: () async {
          var msg = _messages[index];
          context.read<ChatRoomCubit>().deleteMessage(_room, msg.id!, srvMsgId: msg.srvMsgId);
        },
      );
    }
  }

  // 发送消息
  void _sendMessage(String text) async {
    // if (!(await checkNetwork())) {
    //    showToast("网络信号异常,请检查您的网络");
    //   return;
    // }
    if (mounted) {
      xKeyboradHide();
      _stopPlay();
      context.read<ChatRoomCubit>().sendMessage(
        text: text,
        room: _room,
        voice: _voice,
        context: context,
        isPlaying: _isPlaying,
        mounted: mounted,
        lastMessage: () => _messages.last,
        onScrollList: () => _scrollListToHead(),
        onRefreshState: () => setState(() {}),
      );
    }
    // 消息发送功能完毕清空输入框
    if (_chatInputMode.isTextSend || _chatInputMode.isInit) {
      _textController.clear();
    }
  }

  AiVoiceResp? get _voice {
    return _room.aiRole?.voice;
  }

  // 停止播放
  void _stopPlay() {
    NuiUtil.cancelStreamInputTts();
    _isPlaying.value = false;
  }

  // 监听
  void _listenController() {
    // 监听输入框
    _textController.addListener(() {
      final isEmpty = _textController.text.trim().isEmpty;
      if (isEmpty && !_chatInputMode.isTextSend) {
        _chatInputMode.value = ChatInputMode.init;
      }
      setState(() {});
    });

    // 监听滚动，控制悬浮按钮显示
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final offset = _scrollController.offset;

      final show = max - offset > 100; // 距底部100像素内不显示按钮
      if (_showScrollToBottom != show) {
        setState(() {
          _showScrollToBottom = show;
        });
      }
    });
  }

  // 加载聊天历史
  void _loadChatHistory({bool isFirstLoad = false}) {
    context.read<ChatRoomCubit>().loadChatHistory(room: _room);
  }

  void _initNui() {
    // 初始化语音合成相关
    NuiUtil.initAliyunNui(
      mounted: mounted,
      isPlaying: _isPlaying,
      chatInputMode: _chatInputMode,
      amplitudes: _amplitudes,
      cancelSend: _cancelSend,
      onSend: (text) {
        _sendMessage(text);
      },
    );
  }

  // 滚动到顶部
  void _scrollListToHead() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        var maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(maxScroll);
        Future.delayed(Duration(milliseconds: 300), () {
          myButtonKey.currentState?.handleTap();
        });
      }
    });
  }

  void _blankOnTap() {
    if (_chatInputMode.isTextSendOrFunctionShow) {
      FocusScope.of(context).unfocus();
      _chatInputMode.value = ChatInputMode.init;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _stopPlay();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _textController.dispose();
      _scrollController.dispose();
      NuiUtil.release();
      ChatRoomService.instance.cancelFlow();
      WidgetsBinding.instance.removeObserver(this);
      _chatInputMode.dispose();
      _isPlaying.dispose();
      _amplitudes.dispose();
      _cancelSend.dispose();
      _igKey.currentState?.dispose();
      super.dispose();
    }
  }
}
