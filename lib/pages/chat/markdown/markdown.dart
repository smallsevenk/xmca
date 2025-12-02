import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';
import 'package:xmca/pages/chat/markdown/md_a_builder.dart';
import 'package:xmca/pages/chat/markdown/md_img_builder.dart';
import 'package:xmca/pages/chat/markdown/md_table_builder.dart';
import 'package:xmca/pages/chat/util/audio_util.dart';
import 'package:xmca/pages/chat/util/doc_preview_util.dart';
import 'package:xmca/pages/chat/util/image_preview.dart';
import 'package:xmca/pages/chat/widget/web_view.dart';

class XMarkdown extends StatefulWidget {
  final String data;
  final VoidCallback? stopPlay;
  final Function()? humanCsTap;
  const XMarkdown(this.data, {super.key, this.stopPlay, this.humanCsTap});

  @override
  State<XMarkdown> createState() => _CsMarkdownState();
}

class _CsMarkdownState extends State<XMarkdown> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var text = widget.data;
    TextStyle textStyle = TextStyle(
      color: CColor.c1A1A1A,
      fontSize: 32.sp,
      fontWeight: FontWeight.w400,
      height: 44.sp / 28.sp,
    );
    //     text = '''
    // | 日期 日期日期日期日期日期日期日期日期日期日期      | 天气   | 温度  | 日期       | 天气   | 温度  | 日期       | 天气   | 温度  | 日期 日期日期日期日期日期日期日期日期日期日期      | 天气   | 温度  | 日期       | 天气   | 温度  | 日期       | 天气   | 温度  |
    // | ---------- | ------ | ----- | ---------- | ------ | ----- | ---------- | ------ | ----- | ---------- | ------ | ----- | ---------- | ------ | ----- | ---------- | ------ | ----- |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  || 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  || 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  || 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  | 2025-09-15 | 晴    | 281°C  | 2025-09-15 | 晴    | 28°C  |2025-09-15 | 晴    | 28°C  |
    // ''';

    text = text.replaceAllMapped(
      RegExp(r'(\[[^\]]*\]\([^\)]+\.(mp4|mov|avi|wmv|flv|mkv)\))', caseSensitive: false),
      (m) => '\n\n${m[1]}\n\n',
    );
    text = text.replaceUnderscoreInLinks;
    text = text.xmImgsTag;

    var border = BorderSide(color: CColor.cEDEDED.withValues(alpha: .93), width: 1.w);

    return Markdown(
      shrinkWrap: true,
      data: text,
      physics: NeverScrollableScrollPhysics(),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: textStyle,
        listBullet: textStyle,
        a: textStyle.copyWith(color: CColor.c4F7EFF),
        tableHead: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xff1A1A1A),
          fontSize: 30.sp,
          height: 48 / 28,
        ),

        tableBody: TextStyle(color: Color(0xff1A1A1A), fontSize: 30.sp, height: 48 / 28),
        tableHeadDecoration: BoxDecoration(color: CColor.cF6F6F6),
        tableHeadAlign: TextAlign.left,
        tableCellsPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.w),
        tableCellConstraints: BoxConstraints(maxWidth: 200),
        tableColumnWidth: IntrinsicColumnWidth(),
        tableBorder: TableBorder(horizontalInside: border, verticalInside: border),
      ),
      onTapLink: (text, href, title) {
        widget.stopPlay?.call();
        var url = href ?? '';
        if (url.endsWith('.xmcs')) {
          // xmca标签
          widget.humanCsTap?.call();
        } else if (url.contains(RegExp(r'\.(png|jpg|jpeg|gif|bmp)$', caseSensitive: false))) {
          // 图片
          _showImagePreview(url);
        } else if (url.contains(RegExp(r'\.(mp3|wav|aac|m4a|ogg)$', caseSensitive: false))) {
          // 音频
          _showAudioPlayer(url);
        } else if (url.contains(
          RegExp(r'\.(pdf|doc|docx|xls|xlsx|ppt|pptx|txt)$', caseSensitive: false),
        )) {
          // 文档
          _showDocumentPreview(url);
        } else if (url.startsWith('http')) {
          // 其他链接
          _lanuchUrl(url);
        } else {
          showToast('未知链接：$href');
        }
      },
      sizedImageBuilder: (config) => MDImageBuilder(widget: widget, config: config),
      builders: {'a': ATagBuilder(stopPlay: widget.stopPlay)},
      padding: EdgeInsets.zero,
      tableBuilder: (scrollBuilder, tb) {
        return MDTableContanier(table: tb, markdownData: text, child: scrollBuilder);
      },
    );
  }

  // 打开图片预览（淡入淡出模态动画）
  _showImagePreview(String url, {String? title}) {
    ImagePreview.show(
      context: context,
      imageUrls: [url],
      initialIndex: 0,
      titles: [title ?? ''],
      indicatorColor: Colors.white,
    );
  }

  // 打开音频播放器
  _showAudioPlayer(String url) {
    AudioUtil.instance.play(url);
  }

  // 打开文档预览
  _showDocumentPreview(String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DocPreviewUtil(docUrl: url)));
  }

  // 打开内置浏览器
  _lanuchUrl(String url) {
    if (XPlatform.isAndroid()) {
      xKeyboradHide(context: context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebviewPage(title: '链接预览', initialUrl: url, isShowAppBar: true),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
