/*
 * 文件名称: voice_wave.dart
 * 创建时间: 2025/07/14 10:30:14
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 语音波形组件
 */

import 'dart:math';

import 'package:flutter/material.dart';

/// 波浪数量
const int _waveCount = 44;

/// 最小衰减值
const double _minDecay = 0.4;

class VoiceWave extends StatelessWidget {
  final List<double> amplitudes;
  final double waveWidth;
  final double waveHeight;
  final double spacing;
  final Color waveColor;
  final Color backgroundColor;
  final Size? backgroundSize;
  final EdgeInsets padding;
  final bool stopped;
  final double borderRadius;

  const VoiceWave({
    super.key,
    required this.amplitudes,
    this.waveWidth = 3.0,
    this.waveHeight = 20.0,
    this.spacing = 2.0,
    this.waveColor = Colors.white,
    this.backgroundColor = const Color(0xff3D57F8),
    this.backgroundSize,
    this.padding = EdgeInsets.zero,
    this.stopped = false,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: backgroundSize?.width,
      height: backgroundSize?.height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(amplitudes.length, (index) {
            double h = 7;
            if (!stopped) {
              h = amplitudes[index] * waveHeight.clamp(7.0, waveHeight);
            }
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              width: waveWidth,
              height: h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: waveColor,
                borderRadius: BorderRadius.circular(waveWidth / 2),
              ),
            );
          }),
        ),
      ),
    );
  }

  static List<double> get defaultAmplitudes {
    return List<double>.filled(_waveCount, _minDecay);
  }

  static List<double> generateAmplitudes(double rms) {
    double norm = ((rms + 160) / 160).clamp(0.0, 1.0);
    final random = Random();

    // 1. 构造每段长度
    List<int> segLens = List.generate(11, (i) => i % 2 == 0 ? 3 : 5);
    // 2. 修正最后一段长度，保证总数等于_waveCount
    int total = segLens.reduce((a, b) => a + b);
    if (total != _waveCount) {
      segLens[10] += (_waveCount - total);
    }
    // 3. 计算每段起始下标
    List<int> segStartIdx = [];
    int acc = 0;
    for (int len in segLens) {
      segStartIdx.add(acc);
      acc += len;
    }

    return List.generate(_waveCount, (i) {
      // 找到当前i属于哪个段
      int seg = 0;
      for (int s = 0; s < segStartIdx.length; s++) {
        int start = segStartIdx[s];
        int end = start + segLens[s] - 1;
        if (i >= start && i <= end) {
          seg = s;
          break;
        }
      }
      double decay = 1.0;
      if (seg % 2 == 1) {
        // 奇数段做中间高两边低
        int start = segStartIdx[seg];
        int end = start + segLens[seg] - 1;
        int center = (start + end) ~/ 2;
        double dist = (i - center).abs() / ((end - start) / 2);
        decay = 1 - dist * 0.25; // 0.75~1.0
      }
      double coef = (seg % 2 == 0) ? 0.4 : decay;

      var h = (norm * 1.2 + random.nextDouble() * 0.8) * coef;
      return h;
    });
  }
}
