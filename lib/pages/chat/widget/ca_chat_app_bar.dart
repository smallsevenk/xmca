/*
 * 文件名称: chat_app_bar.dart
 * 创建时间: 2025/06/26 17:13:43
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 聊天室应用栏组件
 */

import 'package:flutter/material.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/helper/ca_global.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

// 为了解决 showMenu 点击菜单后会自动聚焦页面文本框问题
final FocusNode titleFocusNode = FocusNode();

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onTitleTap;
  final VoidCallback? onAutoPlayTap;
  final bool autoPlay;
  final Function()? onClearTap;

  const ChatAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.onTitleTap,
    this.onAutoPlayTap,
    this.autoPlay = false,
    this.onClearTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.001),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: onBack,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 30.w, right: 24.w),
          child: CAImage('back', color: CAColor.c1A1A1A),
        ),
      ),
      titleSpacing: 0,
      centerTitle: true,
      title: IconButton(
        focusNode: titleFocusNode,
        onPressed: () {},
        onLongPress: () {
          if (onTitleTap != null) {
            onTitleTap!();
          }
        },
        icon: Text(
          title,
          style: TextStyle(color: CAColor.c1A1A1A, fontSize: 36.sp, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      actions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            titleFocusNode.requestFocus();
            final RenderBox appBarBox = context.findRenderObject() as RenderBox;
            final Offset offset = appBarBox.localToGlobal(Offset.zero);
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                offset.dx + appBarBox.size.width - 10,
                offset.dy + kToolbarHeight + ScreenUtil().statusBarHeight,
                0,
                0,
              ),
              items: [
                _buildPopupMunuItem(text: '清空对话记录', icon: 'clear', onTap: onClearTap),
                _buildPopupMunuItem(
                  text: '${autoPlaySwitchIsOpen ? '关闭' : '开启'}自动播放',
                  icon: 'autoplay${autoPlaySwitchIsOpen ? 1 : 0}',
                  onTap: onAutoPlayTap,
                ),
              ],
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20.w),
            height: double.infinity,
            margin: EdgeInsets.only(right: 30.w),
            child: CAImage('drawer', width: 48.w),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMunuItem({
    required String icon,
    required String text,
    required Function()? onTap,
  }) {
    return PopupMenuItem(
      value: icon,
      onTap: onTap,
      child: Row(
        children: [
          CAImage(icon, width: 40.w),
          SizedBox(width: 8.w),

          Text(
            text,
            style: TextStyle(color: CAColor.c1A1A1A, fontSize: 32.sp),
          ),
        ],
      ),
    );
  }
}
