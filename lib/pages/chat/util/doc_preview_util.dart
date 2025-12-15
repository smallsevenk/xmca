import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';
import 'package:xmca/pages/chat/widget/web_view.dart';
import 'package:xmca/pages/comm/widgets/image.dart';
import 'package:xmca/repo/api/service/api_service.dart';

class DocPreviewUtil extends StatefulWidget {
  final String docUrl;
  final String? fileName;

  const DocPreviewUtil({super.key, required this.docUrl, this.fileName});

  @override
  State<DocPreviewUtil> createState() => _DocPreviewPageState();
}

class _DocPreviewPageState extends State<DocPreviewUtil> {
  String? _localPath;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  Future<void> _prepareFile() async {
    final url = widget.docUrl;
    final fileName = widget.fileName ?? url.split('/').last;
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';

    if (await File(filePath).exists()) {
      setState(() => _localPath = filePath);
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      await Service.instance.xdio.download(
        url,
        filePath,
        onReceiveProgress: (count, total) {
          setState(() {
            _progress = total > 0 ? count / total : 0;
          });
        },
      );
      setState(() {
        _localPath = filePath;
        _downloading = false;
      });
    } catch (e) {
      setState(() => _downloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下载失败: $e')));
      }
    }
  }

  Widget _buildPreview() {
    if (_localPath == null) return const SizedBox();
    final ext = _localPath!.split('.').last.toLowerCase();

    if (ext == 'pdf') {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      );
    } else if (ext == 'txt') {
      return FutureBuilder<String>(
        future: File(_localPath!).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('读取失败: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(snapshot.data ?? ''),
          );
        },
      );
    } else if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      if (XPlatform.isAndroid()) {
        xKeyboradHide(context: context);
      }
      // 使用微软Office在线预览
      final onlineUrl = Uri.encodeComponent(widget.docUrl);
      final officeUrl = 'https://view.officeapps.live.com/op/view.aspx?src=$onlineUrl';
      return WebviewPage(
        initialUrl: officeUrl,
        title: widget.fileName ?? '文档预览',
        isShowAppBar: false,
      );
    } else {
      return const Center(child: Text('暂不支持该格式的内置预览'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.001),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 30.w, right: 24.w),
            child: caImage('back', color: CColor.c1A1A1A),
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          widget.fileName ?? '文档预览',
          style: TextStyle(color: CColor.c1A1A1A, fontSize: 36.sp, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _downloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('正在下载文档...'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            )
          : _buildPreview(),
    );
  }
}
