import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class VideoPlayer {
  /// 全屏图片预览
  static void show({required String videoUrl, required BuildContext context, String? videoName}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '图片预览',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return VideoPlayerPage(
          videoUrl: videoUrl,
          videoName: videoName,
        ).onTap(() => Navigator.pop(context));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? videoName;

  const VideoPlayerPage({super.key, required this.videoUrl, this.videoName});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // 先释放旧 controller，防止多次进入时未释放
    try {
      if (mounted && _chewieController != null) {
        _chewieController?.dispose();
        _chewieController = null;
      }
      if (mounted && _videoController.value.isInitialized) {
        await _videoController.dispose();
      }
    } catch (_) {}
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
      );
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
      // 新增友好提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频解码失败，建议更换视频或转码为兼容格式（H.264 Main Profile, 1080P以内）')),
        );
      }
    }
  }

  @override
  void dispose() {
    try {
      _chewieController?.dispose();
    } catch (_) {}
    try {
      _videoController.dispose();
    } catch (_) {}
    super.dispose();
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
            child: CAImage('cs_close', color: CAColor.c1A1A1A),
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          widget.videoName ?? '视频预览',
          style: TextStyle(color: CAColor.c1A1A1A, fontSize: 36.sp, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? const Center(child: Text('视频加载失败'))
          : SafeArea(child: Chewie(controller: _chewieController!)),
    );
  }
}
