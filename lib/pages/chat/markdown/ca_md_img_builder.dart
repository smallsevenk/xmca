import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/chat/markdown/ca_markdown.dart';
import 'package:xmca/pages/chat/util/ca_image_preview.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class CAMDImageBuilder extends StatelessWidget {
  final MarkdownImageConfig config;
  final CAMarkdown widget;
  const CAMDImageBuilder({super.key, required this.widget, required this.config});

  @override
  Widget build(BuildContext context) {
    var alts = config.alt?.split('|') ?? [];
    var urlsStr = Uri.decodeFull(config.uri.toString());
    List<String> urls = urlsStr.split('|');
    var imgs = <Widget>[];
    for (int i = 0; i < urls.length; i++) {
      var url = urls[i];
      imgs.add(
        GestureDetector(
          onTap: () {
            widget.stopPlay?.call();
            CAImagePreview.show(
              context: context,
              imageUrls: urls,
              initialIndex: i,
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
                  color: CAColor.cF4F5FA,
                  alignment: Alignment.center,
                  child: CAImage('', path: 'assets/chat/cs_img_loading.gif', width: 64.w),
                ),
                errorWidget: (context, url, error) =>
                    Container(
                      color: CAColor.cF4F5FA,
                      alignment: Alignment.center,
                      child: CAImage('cs_img_error'),
                    ).onTap(() {
                      showToast('无效图片资源,无法预览');
                    }),
              ),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: imgs),
    );
  }
}
