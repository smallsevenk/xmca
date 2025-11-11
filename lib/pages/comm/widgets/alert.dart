/*
 * 文件名称: alert.dart
 * 创建时间: 2025/04/12 08:42:35
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/material.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';

class CAAlert {
  static final _defaultTitleStyle = TextStyle(fontSize: 36.sp, color: CAColor.cWhite);

  static final _defaultCancelStyle = TextStyle(
    fontSize: 34.sp,
    color: CAColor.c4F7EFF,
    height: 51.sp / 28.sp,
    fontWeight: FontWeight.w500,
  );

  static final _defaultContentStyle = TextStyle(
    fontSize: 34.sp,
    color: CAColor.c1A1A1A,
    height: 51.sp / 28.sp,
    fontWeight: FontWeight.w500,
  );

  static final _defaultConfirmStyle = TextStyle(
    color: CAColor.cFF6335,
    fontSize: 34.sp,
    fontWeight: FontWeight.w600,
  );

  static final List<Color> _defaultConfirmBackgroundColors = [CAColor.cFFEB98, CAColor.cCAAB62];

  static void show({
    String? title,
    String? content,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    TextStyle? cancelStyle,
    TextStyle? confirmStyle,
    String confirmText = '确认',
    String cancelText = '取消',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool? barrierDismissible,
    bool showCancel = true,
    List<Color>? confirmBackgroundColors,
    required BuildContext Function() context,
  }) {
    showDialog(
      context: context.call(),
      barrierDismissible: barrierDismissible ?? true,
      builder: (context) => _AlertContent(
        title: title ?? '',
        content: content ?? '',
        titleStyle: titleStyle ?? _defaultTitleStyle,
        contentStyle: contentStyle ?? _defaultContentStyle,
        cancelStyle: cancelStyle ?? _defaultCancelStyle,
        confirmStyle: confirmStyle ?? _defaultConfirmStyle,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        showCancel: showCancel,
        barrierDismissible: barrierDismissible ?? true,
        confirmBackgroundColors: confirmBackgroundColors ?? _defaultConfirmBackgroundColors,
      ),
    );
  }
}

class _AlertContent extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle titleStyle;
  final TextStyle contentStyle;
  final TextStyle cancelStyle;
  final TextStyle confirmStyle;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;
  final bool barrierDismissible;
  final List<Color> confirmBackgroundColors;

  const _AlertContent({
    required this.title,
    required this.content,
    required this.titleStyle,
    required this.contentStyle,
    required this.cancelStyle,
    required this.confirmStyle,
    required this.confirmText,
    required this.cancelText,
    required this.showCancel,
    required this.barrierDismissible,
    required this.confirmBackgroundColors,
    this.onConfirm,
    // ignore: unused_element_parameter
    this.onCancel,
  });

  bool get onlyOne => title.trim().isEmpty || content.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 640.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            color: CAColor.cWhite,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onlyOne)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 35.w) +
                      EdgeInsets.only(top: 48.w, bottom: 32.w),
                  child: Text(content, style: contentStyle, textAlign: TextAlign.center),
                ),

              Divider(height: 1.w, color: CAColor.cE5E5E5),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showCancel) _buildCancelButton(context),
        if (showCancel) Container(width: 1.w, height: 88.w, color: CAColor.cE5E5E5),
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onCancel?.call();
          Navigator.pop(context);
        },
        child: Container(
          height: 88.w,
          alignment: Alignment.center,
          child: Text(cancelText, style: cancelStyle),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (barrierDismissible) {
            Navigator.pop(context);
          }
          onConfirm?.call();
        },
        child: Container(
          height: 88.w,
          alignment: Alignment.center,
          child: Text(confirmText, style: confirmStyle),
        ),
      ),
    );
  }
}
