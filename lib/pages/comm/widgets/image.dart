/*
 * 文件名称: xmimage.dart
 * 创建时间: 2025/07/08 19:47:17
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/widgets.dart';
import 'package:xkit/widgets/x_image.dart';

caImage(
  String assetName, {
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
  String? path,
}) {
  return XImage(path ?? 'assets/chat/$assetName.png', width: width, height: height ?? width);
}
