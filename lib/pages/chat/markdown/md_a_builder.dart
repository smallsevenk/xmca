import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownElementBuilder;
import 'package:markdown/markdown.dart' show Element;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/pages/chat/util/video_player.dart';
import 'package:xmca/pages/chat/widget/web_view.dart';
import 'package:xmca/pages/comm/widgets/image.dart';

const String videoThumbnailCacheKey = 'video_thumbnail_cache_key';

class ATagBuilder extends MarkdownElementBuilder {
  final VoidCallback? stopPlay;
  ATagBuilder({this.stopPlay});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag == 'a') {
      final href = element.attributes['href'] ?? '';
      // 只处理视频链接
      if (href.isNotEmpty &&
          href.contains(RegExp(r'\.(mp4|mov|avi|wmv|flv|mkv)$', caseSensitive: false))) {
        return FutureBuilder<Uint8List?>(
          future: getVideoFirstFrame(href),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(snapshot.data!, width: 220, height: 140, fit: BoxFit.cover),
                  ),
                  Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
                ],
              );
            } else {
              return Container(
                width: 220,
                height: 140,
                color: Colors.black12,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: XImage('cs_video_placeholder', width: 220, height: 140),
                    ),
                    Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
                  ],
                ),
              );
            }
          },
        ).onTap(() => _showVideoPlayer(context: context, url: href, title: element.textContent));
      } else {
        return null;
      }
    }
    return super.visitElementAfterWithContext(context, element, preferredStyle, parentStyle);
  }

  // 打开视频播放器
  _showVideoPlayer({required BuildContext context, required String url, String? title}) {
    stopPlay?.call();
    if (XPlatform.isAndroid()) {
      xKeyboradHide(context: context);
    }
    Uri uri = Uri.parse(url);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => XPlatform.isAndroid()
            // ? VideoPlayerWebview(videoUrl: url)
            ? WebviewPage(
                title: title ?? uri.pathSegments.last,
                initialUrl: url,
                isShowAppBar: true,
              )
            : VideoPlayerPage(videoUrl: url, videoName: title ?? uri.pathSegments.last),
      ),
    );
  }

  Future<Uint8List?> getVideoFirstFrame(String url) async {
    var thumbnail = await getThumbnail(url);
    // 1. 先查缓存
    if (thumbnail != null) return thumbnail;

    // 2. 生成缩略图，失败时重试
    for (int i = 0; i < 3; i++) {
      try {
        var data = await VideoThumbnail.thumbnailData(
          video: url,
          imageFormat: ImageFormat.PNG,
          maxWidth: 220, // 可自定义宽度
          quality: 80,
          timeMs: 1000, // 获取1秒处的帧
        );

        if (data != null) {
          // 保存到缓存
          saveThumbnail(url, data);
          return data;
        }
      } catch (e) {
        xdp('获取视频第一帧失败(${i + 1}/3): $e');
        // 最后一次重试失败才返回 null
        if (i == 2) return null;
        // 等待后重试
        await Future.delayed(Duration(milliseconds: 200));
      }
    }
    return null;
  }

  // 保存首帧图片
  Future<bool> saveThumbnail(String url, Uint8List thumbnailData) async {
    var dataMap = await XSpUtil.getMap(videoThumbnailCacheKey);
    // 存储时进行 base64 编码
    dataMap[url] = base64Encode(thumbnailData);
    return XSpUtil.saveMap(videoThumbnailCacheKey, dataMap);
  }

  // 读取首帧图片
  Future<Uint8List?> getThumbnail(String url) async {
    try {
      var dataMap = await XSpUtil.getMap(videoThumbnailCacheKey);
      if (dataMap.containsKey(url)) {
        final base64Str = dataMap[url];
        if (base64Str is String) {
          final bytes = base64Decode(base64Str);
          return bytes;
        }
      }
      xdp('没有换存视频第一帧');
      return null;
    } catch (e) {
      xdp('读取首帧图片失败: $e \n$url');
      return null;
    }
  }
}
