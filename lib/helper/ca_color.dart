/*
 * 文件名称: color.dart
 * 创建时间: 2025/04/12 08:44:01
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/material.dart';

class CAColor {
  static const Color cWhite = Colors.white;
  static const Color cBlack = Colors.black;
  static const Color c191919 = Color(0xFF191919);
  static const Color c232323 = Color(0xFF232323);
  static const Color cEACD76 = Color(0xFFEACD76);
  static const Color cF4F5FA = Color(0xFFF4F5FA);
  static const Color c1A1A1A = Color(0xFF1A1A1A);
  static const Color c51565F = Color(0xFF51565F);
  static const Color cFF6335 = Color(0xFFFF6335);
  static const Color cFFF1DC = Color(0xFFFFF1DC);
  static const Color c4F7EFF = Color(0xFF4F7EFF);
  static const Color cE5E5E5 = Color(0xFFE5E5E5);
  static const Color cFFEB98 = Color(0xFFFFEB98);
  static const Color cCAAB62 = Color(0xFFCAAB62);
  static const Color cC2C2C2 = Color(0xFFC2C2C2);
  static const Color c969DA7 = Color(0xFF969DA7);
  static const Color c5C6EFA = Color(0xFF5C6EFA);
  static const Color cC4D3FA = Color(0xFFC4D3FA);
  static const Color cEDEDED = Color(0xFFEDEDED);
  static const Color cF6F6F6 = Color(0xFFF6F6F6);
}

/// 将颜色转换为字符串
String colorToString(Color color, {String defaultColor = 'FF000000'}) {
  try {
    return color.toString().split('(0x')[1].split(')')[0];
  } catch (e) {
    return defaultColor;
  }
}

/// 将字符串转换为颜色
// Color _hexColor(String hexString, {Color defaultColor = Colors.black}) {
//   try {
//     final buffer = StringBuffer();
//     if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
//     buffer.write(hexString.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   } catch (e) {
//     return defaultColor;
//   }
// }
