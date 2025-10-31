/*
 * 文件名称: chat_input_enum.dart
 * 创建时间: 2025/06/26 17:12:36
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 聊天室输入框状态枚举
 */

import 'package:flutter/material.dart';

enum ChatInputMode {
  init,
  speak,
  speaking,
  promptShow,
  promptHide,
  textSend,
  functionShow,
  functionHide,
}

extension ChatInputModelExtension on ValueNotifier<ChatInputMode> {
  get isInit => value == ChatInputMode.init;
  get isSpeak => value == ChatInputMode.speak;
  get isSpeaking => value == ChatInputMode.speaking;
  get isPromptShowing => value == ChatInputMode.promptShow;
  get isPromptHide => value == ChatInputMode.promptHide;
  get isTextSend => value == ChatInputMode.textSend;
  get isFuncShowing => value == ChatInputMode.functionShow;
  get isFuncHide => value == ChatInputMode.functionHide;
  get isTextSendOrFunctionShow => isTextSend || isFuncShowing;
}
