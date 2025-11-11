/*
 * 文件名称: nui_util.dart
 * 创建时间: 2025/07/08 19:46:33
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  阿里云工具类
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliyun_nui/flutter_aliyun_nui.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/global.dart';
import 'package:xmca/pages/chat/util/chat_input_enum.dart';
import 'package:xmca/pages/chat/widget/voice_wave.dart';
import 'package:xmca/repo/api/service/common_service.dart';
import 'package:xmca/repo/resp/voice_resp.dart';

// 是否打开自动播放持久话 spkey
const String autoPlayKey = 'CAAutoPlay';

class NuiUtil {
  // 语音识别内容
  static String _recognizedText = '';
  // 是否为不可见内容
  static bool _isInvisibleContent = false;
  static int _recognitionSessionId = 0;

  /// 语音合成流式启动
  static Future<bool> startStreamInputTts({
    required AiVoiceResp? voice,
    bool autoPlay = false,
    required BuildContext Function() context,
  }) async {
    try {
      // 需要自动播放且自动播放开关关闭则直接返回
      if (autoPlay && !autoPlaySwitchIsOpen) return false;
      final deviceId = await XAppDeviceInfo().getDeviceId();
      final token = await getAliToken();
      final config = NuiConfig(
        appKey: AliyunConfig.appKey,
        token: token,
        deviceId: deviceId,
        format: 'pcm',
        voice: voice?.voiceParamName,
        sampleRate: 16000,
        speechRate: voice?.speed,
        pitchRate: voice?.style,
        volume: 80,
      );
      if (ALNui.ttsOnReady) {
        await cancelStreamInputTts();
      }
      await ALNui.startStreamInputTts(config);
      return ALNui.ttsOnReady && await XPermissionUtil.checkMicAndSpeeh(context: context);
    } catch (e, s) {
      showToast('startStreamInputTts error: $e\n$s');
      return false;
    }
  }

  static const String startFlag = '(http';
  static const String endFlag = ')';

  /// 自动播放
  static Future<void> autoPlay(
    String text, {
    required ValueNotifier<bool> isPlaying,
    required bool mounted,
  }) async {
    if (!(await checkNetwork())) {
      showToast("无法连接到服务器,请检查您的网络");
      return;
    }
    if (!autoPlaySwitchIsOpen) return;
    // 不播放()之内和本身
    if (text.contains(startFlag)) {
      var texts = text.split(startFlag);
      _isInvisibleContent = true;
      if (texts.isNotEmpty && texts.first.startsWith(startFlag)) {
        return;
      }
      // (之前的内容需要播报
      text = texts.first;
      _play(text, mounted: mounted, isPlaying: isPlaying);
    } else if (text.contains(endFlag)) {
      var texts = text.split(endFlag);
      _isInvisibleContent = false;
      if (texts.isNotEmpty && texts.last.endsWith(endFlag)) {
        return;
      }
      // )之后的内容需要播报
      text = texts.last;
    }
    if (!_isInvisibleContent && ALNui.ttsOnReady) {
      _play(text, mounted: mounted, isPlaying: isPlaying);
    }
  }

  static _play(String text, {required ValueNotifier<bool> isPlaying, required bool mounted}) async {
    await ALNui.sendStreamInputTts(text.removeSpaces);
  }

  /// 发送文本到语音合成
  static Future<void> playText({
    required String text,
    required ValueNotifier<bool> isPlaying,
    required bool mounted,
    AiVoiceResp? voice,
    required BuildContext Function() context,
  }) async {
    if (text.trim().isNotEmpty) {
      try {
        var isStarted = await startStreamInputTts(voice: voice, context: context);
        if (!isStarted) {
          return;
        } else {
          isPlaying.value = true;
        }
        await ALNui.sendStreamInputTts(text.aiPlayMessage);
        await stopStreamTts(mounted);
      } catch (e, s) {
        showToast('sendText error: $e\n$s');
      }
    }
  }

  /// 结束语音合成
  static Future<void> stopStreamTts(bool mounted) async {
    _isInvisibleContent = false;
    if (mounted && autoPlaySwitchIsOpen) {
      try {
        await ALNui.stopStreamInputTts();
      } catch (e, s) {
        showToast('stopStreamTts error: $e\n$s');
      }
    }
  }

  /// 取消语音合成流
  static Future<void> cancelStreamInputTts() async {
    _isInvisibleContent = false;
    try {
      await ALNui.cancelStreamInputTts();
    } catch (e, s) {
      showToast('cancelStreamInputTts error: $e\n$s');
    }
  }

  /// 释放资源
  static Future<void> release() async {
    try {
      await ALNui.release();
    } catch (e, s) {
      showToast('release error: $e\n$s');
    }
  }

  static String aliyunTtsToken = 'aliyunTtsToken';

  static String aliyunTtsTokenExpire = 'aliyunTtsTokenExpire';

  /// 获取阿里云token（自动缓存与刷新）
  static Future<String> getAliToken() async {
    try {
      var token = XSpUtil.prefs.getString(aliyunTtsToken) ?? '';
      var expire = XSpUtil.prefs.getInt(aliyunTtsTokenExpire) ?? 0;
      var now = DateTime.now().millisecondsSinceEpoch;
      bool isExpired = expire < now;
      if (expire == 0 || token.isEmpty || isExpired) {
        final resp = await CommonService().getAliToken();
        if (resp != null) {
          await XSpUtil.prefs.setString(aliyunTtsToken, resp.token ?? '');
          await XSpUtil.prefs.setInt(aliyunTtsTokenExpire, resp.expire ?? 0);
        }
        token = XSpUtil.prefs.getString(aliyunTtsToken) ?? '';
      }
      return token;
    } catch (e, s) {
      xlog('getAliToken error: $e\n$s');
      return '';
    }
  }

  /// 启动语音识别
  static Future<void> startVoiceRecognition({
    required BuildContext Function() context,
    required Offset globalPosition,
    required ValueNotifier<bool> isPlaying,
    required ValueNotifier<ChatInputMode> chatInputMode,
    required ValueNotifier<bool> cancelSend,
  }) async {
    final int sessionId = ++_recognitionSessionId;
    try {
      // 标记为未取消
      cancelSend.value = false;
      // 如果当前 AI 正在说话则停止
      if (isPlaying.value) {
        isPlaying.value = false;
        await cancelStreamInputTts();
      }

      // 在关键异步点之后检查是否被取消
      if (sessionId != _recognitionSessionId) return;

      // 权限检查（可能有耗时）
      if (!await XPermissionUtil.checkMicAndSpeeh(context: context)) {
        // 权限未通过或用户取消 -> 结束本次启动
        return;
      }

      if (sessionId != _recognitionSessionId) return;

      // 初始化或启动识别（可能有耗时）
      if (!ALNui.recognizeOnReady) {
        await _initRecognize();
      } else {
        final token = await getAliToken();
        if (sessionId != _recognitionSessionId) return;
        await ALNui.startRecognize(token);
      }

      if (sessionId != _recognitionSessionId) {
        // 启动过程中被取消，尝试停止已启动的识别
        try {
          await ALNui.stopRecognize();
        } catch (_) {}
        return;
      }

      if (ALNui.recognizeOnReady) {
        // 语音识别准备就绪
        chatInputMode.value = ChatInputMode.speaking;
      }
    } catch (e, s) {
      xlog('startVoiceRecognition error: $e\n$s');
    }
  }

  /// 停止语音识别
  static Future<void> stopVoiceRecognition({
    required ValueNotifier<ChatInputMode> chatInputMode,
    required ValueNotifier<List<double>> amplitudes,
  }) async {
    // 让当前会话失效，后续 startVoiceRecognition 内部检查会返回
    _recognitionSessionId++;
    chatInputMode.value = ChatInputMode.speak;
    amplitudes.value = VoiceWave.defaultAmplitudes;
    try {
      await ALNui.stopRecognize();
    } catch (e, s) {
      xlog('stopVoiceRecognition error: $e\n$s');
    }
  }

  /// 初始化阿里云语音插件
  static void initAliyunNui({
    required bool mounted,
    required Function(String) onSend,
    required ValueNotifier<bool> isPlaying,
    required ValueNotifier<ChatInputMode> chatInputMode,
    required ValueNotifier<bool> cancelSend,
    required ValueNotifier<List<double>> amplitudes,
  }) {
    ALNui.setSlog((t) => xlog(t));
    ALNui.setMethodCallHandler(
      recognizeResultHandler: (result) {
        if (mounted) {
          _recognizedText = result.result;
          if (_recognizedText.isNotEmpty && result.isLast && !cancelSend.value) {
            onSend.call(_recognizedText);
          } else if (result.isLast && !cancelSend.value) {
            showToast('抱歉,没有识别到您录入的内容');
          }
        }
      },
      errorHandler: (error) {
        if (mounted) {
          if (error.errorCode == -1001 && (!kReleaseMode)) {
            showToast("nui error: ${error.errorCode} ${error.errorMessage}");
          }
          stopVoiceRecognition(chatInputMode: chatInputMode, amplitudes: amplitudes);
        }
      },
      playerDrainFinishHandler: () {
        if (mounted) {
          isPlaying.value = false;
          ALNui.cancelStreamInputTts();
        }
      },
      rmsChangedHandler: (rms) {
        if (mounted) {
          _rmsOnChange(rms: rms, chatInputMode: chatInputMode, amplitudes: amplitudes);
        }
      },
    );
  }

  /// 初始化语音识别
  static Future<void> _initRecognize() async {
    try {
      final deviceId = await XAppDeviceInfo().getDeviceId();
      final token = await getAliToken();
      final config = NuiConfig(appKey: AliyunConfig.appKey, deviceId: deviceId, token: token);
      await ALNui.initRecognize(config);
      if (ALNui.recognizeOnReady) {
        await ALNui.startRecognize(token);
      }
    } catch (e, s) {
      xlog('_initRecognize error: $e\n$s');
    }
  }

  static void _rmsOnChange({
    required double rms,
    required ValueNotifier<ChatInputMode> chatInputMode,
    required ValueNotifier<List<double>> amplitudes,
  }) {
    var showRms = rms + 160;
    if (showRms < 110) {
      amplitudes.value = VoiceWave.defaultAmplitudes;
      return;
    }
    amplitudes.value = VoiceWave.generateAmplitudes(rms);
  }
}
