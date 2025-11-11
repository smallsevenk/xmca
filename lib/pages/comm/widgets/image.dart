/*
 * 文件名称: xmimage.dart
 * 创建时间: 2025/07/08 19:47:17
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/widgets.dart';

class XImage extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final String? path;

  const XImage(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path ?? 'assets/chat/$assetName.png',
      package: 'xmca',
      width: width,
      height: height ?? width,
      fit: fit,
      color: color,
    );
  }
}
