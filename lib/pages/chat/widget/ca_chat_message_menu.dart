/*
 * 文件名称: chat_message_menu.dart
 * 创建时间: 2025/05/15 17:34:19
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 聊天室消息菜单组件
 */

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';
import 'package:xmca/repo/resp/ca_message_resp.dart';

class MessageMenuAction {
  final String icon;
  final String text;
  final VoidCallback onTap;
  MessageMenuAction(this.icon, this.text, this.onTap);
}

class CAMessageItemMenu {
  /// 计算弹窗参数并展示菜单
  static OverlayEntry showMenuWithActions({
    required BuildContext context,
    required Offset globalPosition,
    required int index,
    required DBMessage msg,
    required GlobalKey inputGlobalKey,
    required Function(int index) onCopy,
    required Function(int index) onDelete,
    required Function(int index) onPlay,

    VoidCallback? onDismiss,
  }) {
    RenderBox inputRenderBox = inputGlobalKey.currentContext!.findRenderObject() as RenderBox;
    final screenHeight = MediaQuery.of(context).size.height;
    double bubbleWidth = 304.w;
    double bubbleHeight = (msg.isSender || index == 0) ? 192.w : 280.w;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 计算是否需要显示在消息气泡上方
    final showBelow =
        (globalPosition.dy + bubbleHeight) <
        (screenHeight - keyboardHeight - inputRenderBox.size.height);

    late OverlayEntry overlayEntry;
    overlayEntry = _showMenu(
      context: context,
      globalPosition: globalPosition,
      bubbleWidth: bubbleWidth,
      bubbleHeight: bubbleHeight,
      showBelow: showBelow,
      msg: msg,
      index: index,
      onCopy: onCopy,
      onDelete: onDelete,
      onPlay: onPlay,
    );
    return overlayEntry;
  }

  static OverlayEntry _showMenu({
    required BuildContext context,
    required Offset globalPosition,
    required double bubbleWidth,
    required double bubbleHeight,
    required bool showBelow,
    required int index,
    required dynamic msg,
    required Function(int index) onCopy,
    required Function(int index) onDelete,
    required Function(int index) onPlay,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 确保弹出框不会超出屏幕左右边界
    double left = globalPosition.dx - bubbleWidth / 2;
    if (left < 0) {
      left = 10; // 贴边显示，留出 10 像素间距
    } else if (left + bubbleWidth > screenWidth - 10) {
      left = screenWidth - bubbleWidth - 10; // 贴边显示，留出 10 像素间距
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Container(color: CAColor.cBlack.withValues(alpha: .4)),
          ),
          Positioned(
            left: left,
            top: showBelow ? globalPosition.dy : globalPosition.dy - bubbleHeight,
            child: Container(
              width: bubbleWidth,
              height: bubbleHeight,
              padding: EdgeInsets.only(top: 12.w, bottom: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: Column(
                children: [
                  _buildMenuItem(overlayEntry, 'copy', '复制', () => onCopy(index)),
                  if (index != 0) _buildMenuItem(overlayEntry, 'del', '删除', () => onDelete(index)),
                  if (!msg.isSender)
                    _buildMenuItem(overlayEntry, 'play', '播放', () => onPlay(index)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  static Widget _buildMenuItem(
    OverlayEntry overlayEntry,
    String icon,
    String text,
    GestureTapCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          overlayEntry.remove();
          onTap.call();
        },
        child: SizedBox(
          height: 80.w,
          child: Row(
            children: [
              Gap(24.w),
              CAImage('menu_$icon', width: 40.w),
              Gap(12.w),
              Text(
                text,
                style: TextStyle(
                  color: CAColor.c1A1A1A,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none, // 去掉下划线
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
