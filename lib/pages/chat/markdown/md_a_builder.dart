import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownElementBuilder;
import 'package:markdown/markdown.dart' show Element;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:xkit/x_kit.dart';
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
        // 使用独立的 StatefulWidget 缓存 Future/结果，避免父级频繁 rebuild 时重复创建 Future 导致闪烁
        return _VideoThumb(
          href: href,
          title: element.textContent,
          stopPlay: stopPlay,
          onTapPlay: () =>
              _showVideoPlayer(context: context, url: href, title: element.textContent),
        );
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
        builder: (_) {
          return WebviewPage(
            title: title ?? uri.pathSegments.last,
            initialUrl: url,
            isShowAppBar: true,
          );
          // return XPlatform.isAndroid()
          //     // ? VideoPlayerWebview(videoUrl: url)
          //     ? WebviewPage(
          //       title: title ?? uri.pathSegments.last,
          //       initialUrl: url,
          //       isShowAppBar: true,
          //     )
          //     : VideoPlayerPage(videoUrl: url, videoName: title ?? uri.pathSegments.last);
        },
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

class _VideoThumb extends StatefulWidget {
  final String href;
  final String? title;
  final VoidCallback? stopPlay;
  final VoidCallback? onTapPlay;

  const _VideoThumb({required this.href, this.title, this.stopPlay, this.onTapPlay});

  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
  Future<Uint8List?>? _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = _getVideoFirstFrame(widget.href);
  }

  @override
  void didUpdateWidget(covariant _VideoThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.href != widget.href) {
      _thumbFuture = _getVideoFirstFrame(widget.href);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbFuture,
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
          ).onTap(() {
            widget.stopPlay?.call();
            widget.onTapPlay?.call();
          });
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
                  child: caImage('cs_video_placeholder', width: 220, height: 140),
                ),
                Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
              ],
            ),
          ).onTap(() {
            widget.stopPlay?.call();
            widget.onTapPlay?.call();
          });
        }
      },
    );
  }

  // 以下方法从原 ATagBuilder 迁移过来，以便局部缓存缩略图结果
  Future<Uint8List?> _getVideoFirstFrame(String url) async {
    var thumbnail = await _getThumbnail(url);
    if (thumbnail != null) return thumbnail;

    for (int i = 0; i < 3; i++) {
      try {
        var data = await VideoThumbnail.thumbnailData(
          video: url,
          imageFormat: ImageFormat.PNG,
          maxWidth: 220,
          quality: 80,
          timeMs: 1000,
        );

        if (data != null) {
          await _saveThumbnail(url, data);
          return data;
        }
      } catch (e) {
        xdp('获取视频第一帧失败(${i + 1}/3): $e');
        if (i == 2) return null;
        await Future.delayed(Duration(milliseconds: 200));
      }
    }
    return null;
  }

  Future<bool> _saveThumbnail(String url, Uint8List thumbnailData) async {
    var dataMap = await XSpUtil.getMap(videoThumbnailCacheKey);
    dataMap[url] = base64Encode(thumbnailData);
    return XSpUtil.saveMap(videoThumbnailCacheKey, dataMap);
  }

  Future<Uint8List?> _getThumbnail(String url) async {
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
