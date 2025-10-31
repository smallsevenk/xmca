import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class CAImagePreview {
  /// 全屏图片预览
  static void show({
    required BuildContext context,
    required List<String> imageUrls,
    required int initialIndex,
    List<String>? titles,
    Color backgroundColor = Colors.black,
    Color indicatorColor = Colors.white,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '图片预览',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return _ImagePreviewPage(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          titles: titles,
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor,
        ).onTap(() => Navigator.pop(context));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }
}

class _ImagePreviewPage extends StatefulWidget {
  // ...existing code...
  final List<String> imageUrls;
  final int initialIndex;
  final List<String>? titles;
  final Color backgroundColor;
  final Color indicatorColor;

  const _ImagePreviewPage({
    required this.imageUrls,
    required this.initialIndex,
    this.titles,
    this.backgroundColor = Colors.black,
    this.indicatorColor = Colors.white,
  });

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: CAImage('cs_close', width: 48.w),
        ).onTap(() => Navigator.pop(context)),
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
          style: TextStyle(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => _buildPhotoView(index),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 24.w,
            child: _buildPageFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoView(int index) {
    final url = widget.imageUrls[index];
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        // heroAttributes:
        //     widget.heroTag != null ? PhotoViewHeroAttributes(tag: widget.heroTag!) : null,
        errorBuilder: (_, _, _) => CAImage('cs_img_error'),
      );
    } else {
      // 非 http/https 链接，显示占位或错误提示
      return Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 80));
    }
  }

  Widget _buildPageFooter() {
    var titles = widget.titles ?? [];
    var url = widget.imageUrls[_currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[_currentIndex],
          style: TextStyle(color: widget.indicatorColor, fontSize: 32.sp),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Gap(36.w),
        Row(
          children: [
            _buildFooterIcon(icon: 'cs_download', onTap: () => _saveImage(url)),
            Gap(24.w),
            _buildFooterIcon(
              icon: 'cs_link',
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                showToast('已复制链接: $url');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterIcon({String? icon, Function? onTap}) {
    return CAImage(icon ?? '', width: 88.w).onTap(() => onTap?.call());
  }

  Future<void> _saveImage(String url) async {
    try {
      // 请求存储权限
      var check = false;
      if (XPlatform.isAndroid()) {
        check = await XPermissionUtil.checkStorage(context: () => context);
      } else if (XPlatform.isIOS()) {
        check = await XPermissionUtil.checkphotos(context: () => context);
      }
      if (!check) {
        return;
      }
      // 下载图片（使用dio）
      var response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        final result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(response.data!));
        if (result['isSuccess'] == true || result['success'] == true) {
          showToast('图片已保存到相册');
        } else {
          showToast('保存失败');
        }
      } else {
        showToast('图片下载失败');
      }
    } catch (e) {
      showToast('保存失败: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
