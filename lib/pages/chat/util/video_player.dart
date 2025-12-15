import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/color.dart';
import 'package:xmca/pages/comm/widgets/image.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? videoName;

  const VideoPlayerPage({super.key, required this.videoUrl, this.videoName});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoController!.initialize();

      // 在使用 State.context / 更新状态前确保仍然挂载
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
      );
    } catch (e) {
      // 设置错误状态，只有在挂载时才用 setState 和使用 context
      _error = true;
      if (mounted) {
        setState(() {}); // 更新错误状态
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频解码失败，建议更换视频或转码为兼容格式（H.264 Main Profile, 1080P以内）')),
        );
      }
    } finally {
      // 只有在挂载时才更新 UI 状态
      if (mounted) {
        _loading = false;
        setState(() {});
      }
    }
  }

  Future<void> _releaseVideo() async {
    // 停止播放并释放资源（用于 onWillPop 等异步场景）
    try {
      if (_chewieController != null) {
        _chewieController!.pause();
        _chewieController!.dispose();
        _chewieController = null;
      }
      if (_videoController != null) {
        await _videoController!.pause();
        await _videoController!.dispose();
        _videoController = null;
      }
    } catch (_) {
    } finally {
      xdp('停止播放并释放资源');
    }
  }

  void _releaseVideoSync() {
    // 在 dispose 中安全调用（不 await）
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
      _videoController?.pause();
      _videoController?.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    _releaseVideoSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        await _releaseVideo();
        if (mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.001),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () async {
              await _releaseVideo();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 30.w, right: 24.w),
              child: caImage('cs_close', color: CColor.c1A1A1A),
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          title: Text(
            widget.videoName ?? '视频预览',
            style: TextStyle(color: CColor.c1A1A1A, fontSize: 36.sp, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
            ? const Center(child: Text('视频加载失败'))
            : SafeArea(child: Chewie(controller: _chewieController!)),
      ),
    );
  }
}
