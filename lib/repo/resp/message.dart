import 'package:flutter/material.dart';

class Message {
  String text; // 最终文本
  DateTime time;
  bool isMe;

  // 流式回复相关
  bool isStreaming;
  String fullText;
  String currentText = '';
  final GlobalKey? key;

  // 流式时超过视图高度则锁定为顶部可见
  bool lockedToTop = false;

  Message({required this.text, required this.time, required this.isMe})
    : isStreaming = false,
      fullText = '',
      key = null,
      lockedToTop = false;

  Message.streaming({required this.fullText, required this.time, required this.isMe})
    : isStreaming = true,
      text = '',
      currentText = '',
      key = GlobalKey(),
      lockedToTop = false;

  bool get hasKey => key != null;

  // 打字期间不添加光标字符（UI 用渐隐等效果）
  String get currentTextWithCursor => currentText;
}
