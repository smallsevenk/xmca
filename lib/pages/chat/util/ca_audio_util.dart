/*
 * 文件名称: audio_util.dart
 * 创建时间: 2025/05/15 17:33:40
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:xkit/helper/x_global.dart';

class AudioUtil {
  static final AudioUtil _instance = AudioUtil._internal();
  static AudioUtil get instance => _instance;
  factory AudioUtil() => _instance;

  late final AudioPlayer _audioPlayer;
  AudioPlayer get audioPlayer => _audioPlayer;

  AudioUtil._internal() {
    _audioPlayer = AudioPlayer();
  }

  /// 播放音频文件
  Future<void> play(String url) async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else if (isPaused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(UrlSource(url, mimeType: 'audio/mpeg'));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      showToast('播放音频失败: $e');
    }
  }

  /// 播放本地文件
  Future<void> playLocal(String assetPath) async {
    try {
      await _audioPlayer.setSource(DeviceFileSource(assetPath, mimeType: 'audio/mpeg'));
      await _audioPlayer.resume();
      onComplete(() {
        stop();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error playing local audio: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// 设置音量 (0.0 ~ 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// 监听播放进度
  void onProgress(Function(Duration position) callback) {
    _audioPlayer.onPositionChanged.listen((position) {
      callback(position);
    });
  }

  /// 监听播放完成事件
  void onComplete(Function() callback) {
    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint('onPlayerComplete');
      callback();
    });
  }

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  bool get isPaused => _audioPlayer.state == PlayerState.paused;
  bool get isStopped => _audioPlayer.state == PlayerState.stopped;

  /// 释放资源
  void dispose() {
    stop();
    _audioPlayer.dispose();
  }
}
