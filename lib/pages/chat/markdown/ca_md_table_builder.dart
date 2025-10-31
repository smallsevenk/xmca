import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class CAMDTableContanier extends StatelessWidget {
  final String markdownData = '';
  final Widget child;
  final Table table;
  const CAMDTableContanier({
    super.key,
    required String markdownData,
    required this.table,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var container = Container(
      decoration: BoxDecoration(
        border: Border.all(color: CAColor.cEDEDED.withValues(alpha: 0.93), width: 1.w),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 72.w,
            decoration: BoxDecoration(
              color: CAColor.cEDEDED,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)), // 只设置顶部圆角
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.w),
            child: Row(
              children: [
                Text(
                  '表格',
                  style: TextStyle(fontSize: 28.sp, color: CAColor.c51565F),
                ),
                Spacer(),
                CAImage('cs_table_copy', width: 48.w).onTap(() {
                  // 复制表格内容到剪贴板
                  Clipboard.setData(ClipboardData(text: markdownData));
                  showToast('复制完成');
                }),
                Gap(24.w),
                CAImage('cs_full_screen', width: 48.w).onTap(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MDFullTable(markdownData: markdownData, table: table, child: child),
                    ),
                  );
                }),
              ],
            ),
          ),
          child,
        ],
      ),
    );

    return container;
  }
}

class MDFullTable extends StatelessWidget {
  final Widget child;
  final Table table;
  final String markdownData;
  const MDFullTable({
    super.key,
    required this.markdownData,
    required this.table,
    required this.child,
  });

  static final GlobalKey _tableImageKey = GlobalKey();

  Future<void> _saveTableAsImage(BuildContext context) async {
    try {
      var boundary = _tableImageKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        var image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        if (byteData == null) {
          showToast('图片生成失败');
          return;
        }
        final pngBytes = byteData.buffer.asUint8List();

        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
          name: "table_${DateTime.now().millisecondsSinceEpoch}",
        );
        if (result['isSuccess'] == true) {
          showToast('已保存到相册');
        } else {
          showToast('保存失败');
        }
      } else {
        showToast('保存失败: boundary is null');
      }
    } catch (e) {
      showToast('保存失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            // 恢复竖屏
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Future.delayed(Duration(milliseconds: 50), () {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            });
          },
        ),
        actions: [
          CAImage('cs_table_copy', width: 48.w).onTap(() {
            // 复制表格内容到剪贴板
            Clipboard.setData(ClipboardData(text: markdownData));
            showToast('复制完成');
          }),
          Gap(50.w),
          CAImage('cs_download', width: 48.w, color: Colors.red).onTap(() {
            _saveTableAsImage(context);
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RepaintBoundary(key: _tableImageKey, child: child),
          ),
        ),
      ),

      // child 就是表格
    );
  }
}
