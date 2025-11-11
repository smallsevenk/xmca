// ...existing code...
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerWebview extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;
  final bool autoPlay;

  const VideoPlayerWebview({
    super.key,
    required this.videoUrl,
    this.videoTitle,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerWebview> createState() => _CSVideoPlayerWebviewState();
}

class _CSVideoPlayerWebviewState extends State<VideoPlayerWebview> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _loading = true;
  bool _isDisposed = false;

  String get _html =>
      '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    html,body{height:100%;margin:0;background:#000;}
    .video-wrap{display:flex;align-items:center;justify-content:center;height:100%;}
    video{max-width:100%;max-height:100%;width:100%;height:auto;object-fit:contain;background:black;}
    /* 隐藏默认长按菜单/选择行为，避免干扰 */
    video, html, body { -webkit-user-select: none; -webkit-touch-callout: none; }
  </style>
</head>
<body>
  <div class="video-wrap">
    <video id="player" controls ${widget.autoPlay ? "autoplay playsinline" : ""} webkit-playsinline>
      <source src="${htmlEscape.convert(widget.videoUrl)}" type="video/mp4">
      Your browser does not support HTML5 video.
    </video>
  </div>
  <script>
    const video = document.getElementById('player');
    // 当页面进入后台或被要求暂停时，flutter 将调用 JS pause/play
    // 提供一个简单的接口以便调试/调用
    window.flutterPause = function() { try { video.pause(); return true; } catch(e) { return false; } };
    window.flutterPlay = function() { try { video.play(); return true; } catch(e) { return false; } };
    video.addEventListener('loadeddata', () => {
      // notify flutter if needed via JS channel
    });
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // webview_flutter >=4.x: WebViewController + WebViewWidget
    if (Platform.isAndroid) {
      // nothing required for new API; if using webview_flutter_android + older code, import and set platform externally
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (err) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      );

    _loadHtml();
  }

  void _loadHtml() {
    _loading = true;
    if (mounted) setState(() {});
    _controller.loadRequest(
      Uri.dataFromString(_html, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
    );
  }

  // 暂停视频（调用 webview 中的 JS）
  Future<void> _pauseVideo() async {
    try {
      await _controller.runJavaScript('window.flutterPause && window.flutterPause();');
    } catch (_) {}
  }

  // 播放视频（调用 webview 中的 JS）
  Future<void> _playVideo() async {
    if (!widget.autoPlay) return;
    try {
      await _controller.runJavaScript('window.flutterPlay && window.flutterPlay();');
    } catch (_) {}
  }

  // 返回时确保暂停并释放页面资源
  Future<void> _cleanupWebView() async {
    try {
      await _pauseVideo();
      // 加载 about:blank 可帮助释放内存
      await _controller.loadRequest(Uri.parse('about:blank'));
      await _controller.clearCache();
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWebview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // url 变化时重新加载
    if (widget.videoUrl != oldWidget.videoUrl) {
      _loadHtml();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseVideo();
    } else if (state == AppLifecycleState.resumed) {
      _playVideo();
    }
  }

  Future<bool> _onWillPop() async {
    // 页面返回前暂停并尽量释放 webview 资源
    await _pauseVideo();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        // appBar: AppBar(
        //   title: Text(widget.videoTitle ?? '视频播放'),
        //   backgroundColor: Colors.black87,
        //   actions: [
        //     IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHtml),
        //     IconButton(
        //       icon: const Icon(Icons.fullscreen),
        //       onPressed: () async {
        //         // 横屏进入全屏页面，传入相同 html，返回后恢复方向
        //         await SystemChrome.setPreferredOrientations([
        //           DeviceOrientation.landscapeLeft,
        //           DeviceOrientation.landscapeRight,
        //         ]);
        //         await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (_) => _FullScreenWebView(html: _html, autoPlay: widget.autoPlay),
        //           ),
        //         );
        //         await SystemChrome.setPreferredOrientations([
        //           DeviceOrientation.portraitUp,
        //           DeviceOrientation.portraitDown,
        //         ]);
        //       },
        //     ),
        //   ],
        // ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // 尽量在 dispose 前清理 webview（注意：dispose 不能 async，故不 await）
    _cleanupWebView();
    super.dispose();
  }
}

class _FullScreenWebView extends StatefulWidget {
  final String html;
  final bool autoPlay;
  // ignore: unused_element_parameter
  const _FullScreenWebView({required this.html, this.autoPlay = true});

  @override
  State<_FullScreenWebView> createState() => _FullScreenWebViewState();
}

class _FullScreenWebViewState extends State<_FullScreenWebView> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _loading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      );

    _controller.loadRequest(
      Uri.dataFromString(widget.html, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
    );
  }

  Future<void> _pauseVideo() async {
    try {
      await _controller.runJavaScript('window.flutterPause && window.flutterPause();');
    } catch (_) {}
  }

  Future<void> _playVideo() async {
    if (!widget.autoPlay) return;
    try {
      await _controller.runJavaScript('window.flutterPlay && window.flutterPlay();');
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseVideo();
    } else if (state == AppLifecycleState.resumed) {
      _playVideo();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // 尝试停止播放并清理
    try {
      _controller.runJavaScript('window.flutterPause && window.flutterPause();');
      _controller.loadRequest(Uri.parse('about:blank'));
      _controller.clearCache();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            top: 24,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  // 返回前暂停视频并退出
                  await _controller.runJavaScript('window.flutterPause && window.flutterPause();');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
// ...existing code...