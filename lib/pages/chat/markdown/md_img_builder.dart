import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';
import 'package:xmca/pages/chat/markdown/markdown.dart';
import 'package:xmca/pages/chat/util/image_preview.dart';
import 'package:xmca/pages/comm/widgets/image.dart';

class MDImageBuilder extends StatefulWidget {
  final MarkdownImageConfig config;
  final XMarkdown widget;
  const MDImageBuilder({super.key, required this.widget, required this.config});

  @override
  State<MDImageBuilder> createState() => _MDImageBuilderState();
}

class _MDImageBuilderState extends State<MDImageBuilder> {
  // 缓存每个 URL 对应的 image widget，避免在外层频繁 rebuild 导致子 widget 重新创建/闪烁
  final Map<String, Widget> _imageWidgetCache = {};

  @override
  void didUpdateWidget(covariant MDImageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 URL 列表发生变化，保留缓存中仍需的项，移除不再使用的缓存可选（这里不删除以便复用）
  }

  Widget _buildImageItem(String url, List<String> urls, List<String> alts, int index) {
    // 如果已经缓存则直接返回同一个 Widget 实例
    if (_imageWidgetCache.containsKey(url)) return _imageWidgetCache[url]!;

    Widget w = GestureDetector(
      onTap: () {
        widget.widget.stopPlay?.call();
        ImagePreview.show(
          context: context,
          imageUrls: urls,
          initialIndex: index,
          titles: alts,
          indicatorColor: Colors.white,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.w) + EdgeInsets.only(right: 10.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.w),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 280.w,
            height: 280.w,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: CColor.cF4F5FA,
              alignment: Alignment.center,
              child: caImage('', path: 'assets/chat/cs_img_loading.gif', width: 64.w),
            ),
            errorWidget: (context, url, error) =>
                Container(
                  color: CColor.cF4F5FA,
                  alignment: Alignment.center,
                  child: caImage('cs_img_error'),
                ).onTap(() {
                  showToast('无效图片资源,无法预览');
                }),
          ),
        ),
      ),
    );

    _imageWidgetCache[url] = w;
    return w;
  }

  @override
  Widget build(BuildContext context) {
    var alts = widget.config.alt?.split('|') ?? [];
    var urlsStr = Uri.decodeFull(widget.config.uri.toString());
    List<String> urls = urlsStr.split('|');

    var imgs = <Widget>[];
    for (int i = 0; i < urls.length; i++) {
      var url = urls[i];
      imgs.add(_buildImageItem(url, urls, alts, i));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: imgs),
    );
  }
}
