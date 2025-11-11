// ignore_for_file: use_build_context_synchronously

/*
 * 文件名称: logs.dart
 * 创建时间: 2025/07/08 19:47:11
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:flutter/material.dart';
import 'package:xkit/x_kit.dart';

class LogListPage extends StatefulWidget {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _CSLogListPageState();
}

class _CSLogListPageState extends State<LogListPage> {
  bool _reverse = false;
  String _startTimeStr = '';
  String _endTimeStr = '';

  DateTime? _startTime;
  DateTime? _endTime;

  // 假设日志格式为 '2025-05-26 10:23:45 ...'
  DateTime? _parseLogTime(String log) {
    try {
      final match = RegExp(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})').firstMatch(log);
      if (match != null) {
        return DateTime.parse(match.group(1)!);
      }
    } catch (_) {}
    return null;
  }

  List<String> get _filteredLogs {
    final logs = xglog();
    List<String> filtered = logs;
    if (_startTime != null || _endTime != null) {
      filtered = filtered.where((log) {
        final logTime = _parseLogTime(log);
        if (logTime == null) return false;
        if (_startTime != null && logTime.isBefore(_startTime!)) return false;
        if (_endTime != null && logTime.isAfter(_endTime!)) return false;
        return true;
      }).toList();
    }
    return _reverse ? filtered.reversed.toList() : filtered;
  }

  Future<void> _pickStartTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime ?? now),
      );
      if (time != null) {
        // 新增：弹窗输入秒
        int second = 0;
        final secStr = await showDialog<String>(
          context: context,
          builder: (ctx) {
            String input = '0';
            return AlertDialog(
              title: const Text('选择秒'),
              content: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0~59'),
                onChanged: (v) => input = v,
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(input), child: const Text('确定')),
              ],
            );
          },
        );
        if (secStr != null && int.tryParse(secStr) != null) {
          second = int.parse(secStr).clamp(0, 59);
        }
        final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute, second);
        setState(() {
          _startTime = dt;
          _startTimeStr = dt.toString().substring(0, 19);
        });
      }
    }
  }

  Future<void> _pickEndTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endTime ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime ?? now),
      );
      if (time != null) {
        // 新增：弹窗输入秒
        int second = 59;
        final secStr = await showDialog<String>(
          context: context,
          builder: (ctx) {
            String input = '59';
            return AlertDialog(
              title: const Text('选择秒'),
              content: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0~59'),
                onChanged: (v) => input = v,
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(input), child: const Text('确定')),
              ],
            );
          },
        );
        if (secStr != null && int.tryParse(secStr) != null) {
          second = int.parse(secStr).clamp(0, 59);
        }
        final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute, second);
        setState(() {
          _endTime = dt;
          _endTimeStr = dt.toString().substring(0, 19);
        });
      }
    }
  }

  void _onStartTimeInput(String v) {
    setState(() {
      _startTimeStr = v.trim();
      try {
        _startTime = DateTime.parse(_startTimeStr);
      } catch (_) {
        _startTime = null;
      }
    });
  }

  void _onEndTimeInput(String v) {
    setState(() {
      _endTimeStr = v.trim();
      try {
        _endTime = DateTime.parse(_endTimeStr);
      } catch (_) {
        _endTime = null;
      }
    });
  }

  void _clearTime() {
    setState(() {
      _startTime = null;
      _endTime = null;
      _startTimeStr = '';
      _endTimeStr = '';
    });
  }

  void _openEnvironmentSwitchPage() {
    // 跳转到环境切换页面
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const EnvironmentSwitchPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志列表').onTap(() {
          _openEnvironmentSwitchPage();
        }),
        actions: [
          IconButton(
            icon: Icon(_reverse ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _reverse ? '倒序' : '正序',
            onPressed: () {
              setState(() {
                _reverse = !_reverse;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              xrlog();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _startTimeStr),
                    decoration: InputDecoration(
                      labelText: '起始时间(yyyy-MM-dd HH:mm:ss)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: _pickStartTime,
                      ),
                    ),
                    onChanged: _onStartTimeInput,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _endTimeStr),
                    decoration: InputDecoration(
                      labelText: '结束时间(yyyy-MM-dd HH:mm:ss)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: _pickEndTime,
                      ),
                    ),
                    onChanged: _onEndTimeInput,
                  ),
                ),
                IconButton(icon: const Icon(Icons.clear), onPressed: _clearTime),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [for (var log in _filteredLogs) Text(' ${log.replaceAll('T', '')}')],
            ),
          ),
        ],
      ),
    );
  }
}
