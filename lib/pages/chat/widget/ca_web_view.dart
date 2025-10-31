import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

/// 封装的可复用 WebView 页面组件，支持传入标题和初始 URL
class WebviewPage extends StatefulWidget {
  final String title; // 页面标题
  final String initialUrl; // 初始加载的 URL
  final bool isShowAppBar; // 是否显示 AppBar

  const WebviewPage({
    super.key,
    required this.title,
    required this.initialUrl,
    required this.isShowAppBar,
  });

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final WebViewController _controller; // WebView 控制器
  final ValueNotifier<int> _loadingProgress = ValueNotifier<int>(0); // 使用 ValueNotifier 管理加载进度

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              _loadingProgress.value = progress; // 更新加载进度
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              _loadingProgress.value = 0;
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              _loadingProgress.value = 100;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          ValueListenableBuilder<int>(
            valueListenable: _loadingProgress,
            builder: (context, progress, child) {
              if (progress < 100) {
                return LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 3,
                  backgroundColor: CAColor.c232323,
                  valueColor: AlwaysStoppedAnimation<Color>(CAColor.cEACD76),
                );
              }
              return SizedBox.shrink(); // 隐藏进度条
            },
          ),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return widget.isShowAppBar
        ? PreferredSize(
            preferredSize: Size(ScreenUtil().screenWidth, 88.w),
            child: Container(
              margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              width: ScreenUtil().screenWidth,
              height: 88.w,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // 返回上一页
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 60.w,
                      height: 60.w,
                      margin: EdgeInsets.only(left: 25.w, top: 10.w),
                      child: CAImage('back', width: 60.w, color: CAColor.c1A1A1A),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: CAColor.c1A1A1A,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    right: 25.w,
                    top: 10.w,
                    child: GestureDetector(
                      onTap: () {
                        _controller.reload(); // 刷新 WebView
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(Icons.refresh, color: CAColor.c1A1A1A, size: 48.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : PreferredSize(
            preferredSize: Size(ScreenUtil().screenWidth, 0),
            child: SizedBox.shrink(), // 不显示 AppBar
          );
  }

  @override
  void dispose() {
    _controller.clearLocalStorage(); // 清理缓存
    _loadingProgress.dispose(); // 释放 ValueNotifier
    super.dispose();
  }
}
