/*
 * 文件名称: chat_input.dart
 * 创建时间: 2025/06/26 17:12:00
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  聊天室输入框组件
 */

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/pages/chat/widget/ca_input_toolbar.dart';
import 'package:xmca/pages/chat/util/ca_av_util.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/chat/util/ca_chat_input_enum.dart';
import 'package:xmca/pages/chat/widget/ca_voice_wave.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class ChatInput extends StatelessWidget {
  final ValueNotifier<ChatInputMode> chatInputMode;
  final TextEditingController textController;
  final BuildContext context;
  final GlobalKey igKey;
  final Function reloadMessageList;
  final void Function(String message) onSendMessage;
  final void Function(DragDownDetails details)? onStartRecognition;
  final void Function(bool isVoice)? onCallAgentType;
  final void Function()? onStopRecognition;
  final void Function()? onHumanCs;
  final void Function() onScrollListToHead;
  final ValueNotifier<List<double>> amplitudes;
  final ValueNotifier<bool> cancelSend;

  const ChatInput({
    super.key,
    required this.chatInputMode,
    required this.textController,
    required this.context,
    required this.igKey,
    required this.reloadMessageList,
    required this.onSendMessage,
    required this.onScrollListToHead,
    required this.amplitudes,
    required this.cancelSend,
    this.onStartRecognition,
    this.onCallAgentType,
    this.onStopRecognition,
    this.onHumanCs,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cancelSend,
      builder: (BuildContext context, dynamic cancel, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolBar(),
            _buildInputTool(),
            if (chatInputMode.isFuncShowing) _buildFunctionPanel(),
          ],
        );
      },
    );
  }

  ///  输入栏上方工具条
  Widget _buildToolBar() {
    if (chatInputMode.isSpeaking) return _buildSpeakingTipMaskView();
    List<InputToolbarItem> items = [InputToolbarItem(icon: 'cs', title: '人工客服')];
    return CAInputToolbar(items: items, humanCsTap: onHumanCs);
  }

  ///  录音提示遮罩层
  Widget _buildSpeakingTipMaskView() {
    if (!chatInputMode.isSpeaking) return SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: cancelSend,
      builder: (BuildContext context, dynamic cancel, Widget? child) {
        return Container(
          height: 96.w,
          width: ScreenUtil().screenWidth,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 24.w),
          decoration: BoxDecoration(),
          child: Text(
            cancel ? '松手取消' : '松手发送 上滑取消',
            style: TextStyle(color: cancel ? CAColor.cFF6335 : CAColor.c51565F, fontSize: 28.sp),
          ),
        );
      },
    );
  }

  // 输入工具栏
  Widget _buildInputTool() {
    bool isVoiceMode = chatInputMode.isSpeak || chatInputMode.isSpeaking;
    Widget tool = Row(
      children: [
        if (!chatInputMode.isSpeaking) ..._buildLeadingWidgets(isVoiceMode),
        ..._buildMiddlingWidgets(isVoiceMode),
        if (!isVoiceMode) ..._buildTrailing(),
      ],
    );
    return SafeArea(
      top: false,
      bottom: chatInputMode.isFuncShowing ? false : true,
      child: Container(
        key: igKey,
        width: ScreenUtil().screenWidth - 60.w,
        constraints: BoxConstraints(minHeight: 108.w),
        decoration: BoxDecoration(
          color: chatInputMode.isSpeaking
              ? cancelSend.value
                    ? CAColor.cFF6335
                    : CAColor.c4F7EFF
              : CAColor.cWhite,
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withValues(alpha: .08),
              offset: Offset(0, 4),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        margin:
            EdgeInsets.symmetric(horizontal: 30.w) +
            EdgeInsets.only(bottom: chatInputMode.isFuncShowing ? 0 : 16.w),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) {
            double dx = details.globalPosition.dx;
            if (chatInputMode.isSpeak && dx > 120.w && dx < ScreenUtil().screenWidth - 200.w) {
              onStartRecognition?.call(DragDownDetails(globalPosition: details.globalPosition));
            }
          },
          onPanUpdate: (details) {
            // 判断手指是否滑出按钮上方
            RenderBox? box = igKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              Offset topLeft = box.localToGlobal(Offset.zero);
              Size size = box.size;
              Rect btnRect = topLeft & size;
              if (!btnRect.contains(details.globalPosition)) {
                // 手指已滑出按钮区域
                cancelSend.value = true;
              } else {
                cancelSend.value = false;
              }
            }
          },
          onPanEnd: (details) {
            if (chatInputMode.isSpeaking) {
              onStopRecognition?.call();
            }
          },
          onPanCancel: () {
            if (chatInputMode.isSpeaking) {
              onStopRecognition?.call();
            }
          },
          child: tool,
        ),
      ),
    );
  }

  List<Widget> _buildLeadingWidgets(bool isVoiceMode) {
    List<Widget> widgets = [];

    widgets.add(Gap(20.w));
    if (!textController.text.isNotEmpty) {
      widgets.add(
        GestureDetector(
          onTap: () {
            if (!isVoiceMode) {
              XPermissionUtil.checkMicAndSpeeh(context: () => context);
              chatInputMode.value = ChatInputMode.speak;
            } else {
              chatInputMode.value = ChatInputMode.textSend;
            }
          },
          child: CAImage(isVoiceMode ? 'keyborad' : 'input_mic', width: 56.w),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildMiddlingWidgets(bool isVoiceMode) {
    if (isVoiceMode) {
      return [
        if (chatInputMode.isSpeak) Gap(45.w),
        SizedBox(
          height: 108.w,
          width: chatInputMode.isSpeaking ? 690.w : 460.w,
          child: chatInputMode.isSpeaking
              ? ValueListenableBuilder(
                  valueListenable: amplitudes,
                  builder: (context, amplitudes, child) {
                    return CAVoiceWave(
                      amplitudes: amplitudes,
                      borderRadius: 16.w,
                      backgroundColor: Colors.transparent,
                    );
                  },
                )
              : Center(
                  child: Text(
                    '长按说话',
                    style: TextStyle(
                      color: CAColor.c1A1A1A,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ];
    }

    return [
      Gap(12.w),
      Container(
        width:
            ((chatInputMode.isTextSend || chatInputMode.isInit) && textController.text.isNotEmpty)
            ? 542.w
            : 460.w,
        constraints: BoxConstraints(minHeight: 46.w, maxHeight: 200.w),
        child: TextField(
          controller: textController,
          onTap: () {
            Future.delayed(Duration(milliseconds: 500), () {
              onScrollListToHead.call();
            });
            if (chatInputMode.value != ChatInputMode.textSend) {
              chatInputMode.value = ChatInputMode.textSend;
            }
          },
          style: TextStyle(color: CAColor.c1A1A1A, fontSize: 32.sp),
          maxLines: null,
          maxLength: 300,
          buildCounter:
              (_, {required int currentLength, required bool isFocused, required int? maxLength}) {
                return null; // 隐藏计数器
              },
          decoration: InputDecoration(
            hintText: '请输入...',
            hintStyle: TextStyle(color: CAColor.c969DA7, fontSize: 32.sp),
            border: InputBorder.none,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildTrailing() {
    List<Widget> widgets = [];
    bool isSend =
        textController.text.trim().isNotEmpty && (chatInputMode.isTextSend || chatInputMode.isInit);
    String imageName = isSend ? 'send' : 'send0';
    //chatInputMode.isFuncShowing
    // ? 'func1'
    // : 'func0';

    widgets.add(Spacer());
    widgets.add(
      Padding(
        padding: EdgeInsets.only(right: 20.w, left: 30.w, top: 20.w, bottom: 20.w),
        child: XDebounceGestureDetector(
          child: isSend ? CAImage(imageName, width: 56.w) : CAImage(imageName, width: 56.w),
          onTap: () {
            if (isSend) {
              onSendMessage.call(textController.text.trim());
              textController.clear();
            } else {
              _handleFunctionTap.call();
            }
          },
        ),
      ),
    );
    return widgets;
  }

  // 功能面板构建
  Widget _buildFunctionPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: ScreenUtil().screenWidth,
      height: chatInputMode.isFuncShowing ? 248.w + ScreenUtil().bottomBarHeight : 0,
      child: GridView(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 40.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 74.w,
          childAspectRatio: 120.w / 168.w,
        ),
        children: [
          _buildFunctionButton('语音通话', 'call_voice', () {
            CAAvUtil.getMediaPermissions(context: () => context);
            onCallAgentType?.call(true);
          }),
          _buildFunctionButton('视频通话', 'call_video', () {
            CAAvUtil.getMediaPermissions(context: () => context);
            onCallAgentType?.call(false);
          }),
        ],
      ),
    );
  }

  Widget _buildFunctionButton(String title, String funcIcon, GestureTapCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          CAImage('func_$funcIcon', width: 120.w),
          Spacer(),
          Text(
            title,
            style: TextStyle(color: CAColor.c51565F, fontSize: 26.sp, height: 1),
          ),
        ],
      ),
    );
  }

  void _handleFunctionTap() {
    // if (!chatInputMode.isFuncShowing) {
    //   chatInputMode.value = CAChatInputMode.functionShow;
    // } else {
    //   chatInputMode.value = CAChatInputMode.functionHide;
    // }
    // xmKeyboradHide();
  }
}
