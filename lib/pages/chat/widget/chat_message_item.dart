import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';
import 'package:xmca/helper/native_util.dart';
import 'package:xmca/pages/chat/markdown/markdown.dart';
import 'package:xmca/pages/comm/widgets/image.dart';
import 'package:xmca/repo/resp/message_resp.dart';

class ChatMessageItem extends StatefulWidget {
  final DBMessage item;

  final GestureLongPressStartCallback? onLongPressStart;
  final Function(DBMessage)? onResend;
  final Function()? onUserTagTap; // 点击用户标签的回调
  final ValueNotifier<bool> isPlaying;
  final VoidCallback? onCopy;
  final VoidCallback? onPlay;
  final VoidCallback? stopPlay;
  final Function(String)? onSendPrmpt;
  final bool Function() isLast;
  final List<DBMessage> Function() getMessages;

  const ChatMessageItem({
    super.key,
    required this.item,
    this.onLongPressStart,
    this.onResend,
    this.onCopy,
    this.onPlay,
    this.stopPlay,
    this.onUserTagTap,
    required this.isPlaying,
    this.onSendPrmpt,
    required this.isLast,
    required this.getMessages,
  });

  @override
  ChatMessageItemState createState() => ChatMessageItemState();
}

class ChatMessageItemState extends State<ChatMessageItem> {
  bool _suggestClicked = false;
  late DBMessage _item;
  final _cornerRadius = 24.w;
  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void updateContent(String content) {
    setState(() {
      widget.item.text = content;
    });
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = !_item.isSender;
    final tempText = _item.text.isNotEmpty ? _item.text : '';

    final bgColor = isLeft ? CColor.cWhite : CColor.cC4D3FA;
    final contentBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(isLeft ? 2.w : _cornerRadius),
      topRight: Radius.circular(isLeft ? _cornerRadius : 2.w),
      bottomLeft: Radius.circular(_cornerRadius),
      bottomRight: Radius.circular(_cornerRadius),
    );
    // 如果消息状态为 0，显示加载动画
    if (_item.text.isEmpty && !_item.isSender && _item.status == 0) {
      return Row(children: [ThinkingView()]);
    }

    var showTime = _item.displayTime != null && _item.displayTime!.isNotEmpty;
    var headerViews = showTime
        ? [
            Gap(40.w),
            Center(
              child: Text(_item.displayTime ?? '', style: TextStyle(color: CColor.c969DA7)),
            ),
            Gap(24.w),
          ]
        : [Gap(40.w)];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...headerViews,
          GestureDetector(
            onLongPressStart: widget.onLongPressStart,
            child: _buildMessageBubble(tempText, bgColor, contentBorderRadius),
          ),
          if (widget.isLast.call() && !_item.isSender && (_item.suggestions ?? []).isNotEmpty)
            _buildSuggestView(),
        ],
      ),
    );
  }

  Widget _buildReSendButton() {
    return GestureDetector(
      onTap: () => widget.onResend?.call(widget.item),
      child: caImage('resend', width: 48.w),
    );
  }

  Widget _buildMessageBubble(String text, Color bgColor, BorderRadius borderRadius) {
    final padding = EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.w);
    final decoration = BoxDecoration(color: bgColor, borderRadius: borderRadius);
    if (_item.isSender) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_item.status == 3) _buildReSendButton(),
          Gap(10),
          Container(
            constraints: BoxConstraints(maxWidth: 512.w),
            padding: padding,
            decoration: decoration,
            child: Text(
              text,
              style: TextStyle(
                color: CColor.c1A1A1A,
                fontSize: 32.sp,
                fontWeight: FontWeight.w400,
                height: 44.sp / 28.sp, // 行高
              ),
            ),
          ),
        ],
      );
    }
    var isLast = widget.isLast.call();

    return Container(
      decoration: decoration,
      padding: padding.copyWith(bottom: isLast ? 16.w : 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          XMarkdown(
            text,
            stopPlay: widget.stopPlay,
            humanCsTap: () {
              NativeUtil.humanCustomerService?.call([]);
            },
          ),
          if (isLast) ...[
            // 底部工具栏
            Gap(24.w),
            Divider(height: 1.w, color: CColor.cEDEDED),
            Gap(16.w),
            _buildBottomToolBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomToolBar() {
    var isLast = widget.isLast.call();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isLast) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onCopy,
            child: caImage('copy', width: 64.w),
          ),
          Gap(24.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPlay,
            child: ValueListenableBuilder(
              valueListenable: widget.isPlaying,
              builder: (context, isPlaying, child) {
                return widget.isPlaying.value
                    ? Image.asset(
                        'assets/chat/playing.gif',
                        package: 'xmca',
                        width: 64.w,
                        height: 64.w,
                      )
                    : caImage('play', width: 64.w);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestView() {
    List<String?> suggests = _item.suggestions ?? [];
    List<Widget> texts = suggests.map((v) {
      return Container(
        margin: EdgeInsets.only(right: 96.w, top: 16.w),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
          ),
          onPressed: () {
            if (_suggestClicked) return;
            _suggestClicked = true;
            widget.onSendPrmpt?.call(v ?? '');
            Future.delayed(const Duration(seconds: 1), () => _suggestClicked = false);
          },
          child: Text(
            v ?? '',
            style: TextStyle(color: CColor.c1A1A1A, fontSize: 28.sp, fontWeight: FontWeight.w400),
          ),
        ),
      );
    }).toList();
    final suggestTipStr = widget.getMessages.call().length <= 1 ? '常见的问题：' : '你可以继续问我：';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(24.w),
        Text(
          suggestTipStr,
          style: TextStyle(color: CColor.c51565F, fontSize: 28.sp),
        ),
        ...texts,
      ],
    );
  }

  // _pushLoglist() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => const LogListPage()));
  // }

  @override
  void dispose() {
    super.dispose();
  }
}

// AI风格三个点加载动画
class ThinkingView extends StatefulWidget {
  const ThinkingView({super.key});

  @override
  State<ThinkingView> createState() => _ThinkingViewState();
}

class _ThinkingViewState extends State<ThinkingView> {
  late Timer _timer;
  int _activeIndex = 0;

  final List<Color> _dotColors = [Colors.black, Colors.grey, Color(0xFFCCCCCC)];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _activeIndex = (_activeIndex + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 24.w, top: 40.w, bottom: 40.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          Color color;
          if (i == _activeIndex) {
            color = _dotColors[0];
          } else if ((i - _activeIndex).abs() == 1 ||
              (i == 0 && _activeIndex == 2) ||
              (i == 2 && _activeIndex == 0)) {
            color = _dotColors[1];
          } else {
            color = _dotColors[2];
          }
          return Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}
