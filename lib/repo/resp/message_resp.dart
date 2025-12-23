/*
 * 文件名称: message_resp.dart
 * 创建时间: 2025/04/12 08:41:12
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/user_manager.dart';
import 'package:xmca/pages/chat/widget/chat_message_item.dart';

/// 聊天消息
class DBMessage {
  /// 消息ID
  int? id;

  /// 聊天所属的聊天室 ID
  int? roomId;

  /// 用户ID
  int? userId;

  /// 消息内容
  String text;

  /// 消息类型
  MessageType type;

  /// 消息方向
  Role role;

  /// 发送者名称
  String? roleName;

  /// 消息附加信息，用于提供模型相关信息
  String? extra;

  /// 时间戳
  DateTime? ts;

  /// 关联消息ID（问题 ID）
  int? refId;

  /// 服务端 ID
  int? srvMsgId;

  /// 消息状态:  0-等待应答 1-成功  2-失败 3-需要重发
  int status;

  /// 消息发送者的头像，不需要持久化
  String? avatarUrl;

  /// 消息图片列表
  List<String>? images;

  // Uploaded file by user (json(name, url))
  String? file;

  /// 推荐问题
  List<String>? suggestions;

  /// 引用内容
  List<Map>? references;

  /// 是否展开引用内容
  bool isExpandReferences = false;

  String? agentId;

  // 统计类型(0=未解决，1=已解决, 2=未操作)
  int? statisticsType;

  // 父消息 id
  int? pid;

  // 展示时间
  String? displayTime;

  GlobalKey<ChatMessageItemState> messageItemKey = GlobalKey();

  DBMessage(
    this.role,
    this.text, {
    required this.type,
    this.userId,
    this.roleName,
    this.ts,
    this.roomId,
    this.extra,
    this.refId,
    this.srvMsgId,
    this.status = 1,
    this.avatarUrl,
    this.images,
    this.file,
    this.suggestions,
    this.references,
    this.agentId,
    this.statisticsType,
    this.pid,
  });

  /// 是否为发送者
  bool get isSender {
    return role == Role.sender;
  }

  String get markdownWithImages {
    var t = text;
    if (images != null && images!.isNotEmpty) {
      t = images!.map((e) => '![img]($e)\n\n').join('') + t;
    }

    return t;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'role': role.getRoleText(),
      'text': text,
      'type': type.getTypeText(),
      'extra': extra,
      'role_name': roleName,
      'ts': ts?.millisecondsSinceEpoch,
      'room_id': roomId,
      'ref_id': refId,
      'srv_msgid': srvMsgId,
      'status': status,
      'images': images != null ? jsonEncode(images) : null,
      'file': file,
      'suggestions': suggestions != null ? jsonEncode(suggestions) : null,
      'referencess': references != null ? jsonEncode(references) : null,
      'agent_id': agentId,
      'statistics_type': statisticsType,
      'pid': pid,
    };
  }

  DBMessage.fromMap(Map<String, Object?> json)
    : role = Role.getRoleFromText(json.getString('role')),
      text = json.getString('text'),
      type = MessageType.getTypeFromText(json.getString('type')),
      extra = json.getString('extra'),
      status = json.getInt('status') {
    try {
      id = json.getInt('id');
      userId = json.getInt('user_id');
      roleName = json.getString('role_name');
      agentId = json.getString('agentId');
      refId = json.getInt('ref_id');
      srvMsgId = json.getInt('srv_msgid');
      ts = json['ts'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['ts'] as int);
      roomId = json.getInt('room_id');
      suggestions = json['suggestions'] == null
          ? null
          : (jsonDecode(json.getString('suggestions')) as List<dynamic>).cast<String>();

      file = json.getString('file');
      statisticsType = json.getInt('statistics_type');
      pid = json.getInt('pid');

      var imgs = json.getString('images');
      if (imgs.isNotEmpty) {
        images = (jsonDecode(imgs) as List<dynamic>).cast<String>();
      }

      var ref = json.getString('referencess');
      if (ref.isNotEmpty) {
        references = (jsonDecode(ref) as List<dynamic>).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      xdp('DBMessage.fromMap error: $e');
    }
  }

  DBMessage setDisplayTime(DBMessage? preMessage) {
    if (ts != null) {
      if (preMessage?.ts != null) {
        var diff = ts!.difference(preMessage!.ts!).inMinutes;
        // 计算时间差，超过 5 分钟则显示自身时间，否则显示前一条消息时间
        if (diff >= 5) {
          displayTime = ts?.imRoomDisplayTime;
        }
      } else {
        displayTime = ts?.imRoomDisplayTime;
      }
    }

    return this;
  }
}

enum Role {
  receiver,
  sender;

  static Role getRoleFromText(String value) {
    switch (value) {
      case 'receiver':
        return Role.receiver;
      case 'assistant':
        return Role.receiver;
      case 'sender':
        return Role.sender;
      case 'user':
        return Role.sender;
      default:
        return Role.receiver;
    }
  }

  String getRoleText() {
    switch (this) {
      case Role.receiver:
        return 'receiver';
      case Role.sender:
        return 'sender';
    }
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  location,
  command,
  system,
  timeline,
  contextBreak,
  hide,
  initMessage;

  String getTypeText() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
      case MessageType.location:
        return 'location';
      case MessageType.command:
        return 'command';
      case MessageType.system:
        return 'system';
      case MessageType.timeline:
        return 'timeline';
      case MessageType.contextBreak:
        return 'contextBreak';
      case MessageType.hide:
        return 'hide';
      case MessageType.initMessage:
        return 'initMessage';
    }
  }

  static MessageType getTypeFromText(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'location':
        return MessageType.location;
      case 'command':
        return MessageType.command;
      case 'system':
        return MessageType.system;
      case 'timeline':
        return MessageType.timeline;
      case 'contextBreak':
        return MessageType.contextBreak;
      case 'hide':
        return MessageType.hide;
      case 'initMessage':
        return MessageType.initMessage;
      default:
        return MessageType.text;
    }
  }
}

class AIMessage {
  String? id;
  int? userMessageId;
  int? aiMessageId;
  int? roomId;
  String? object;
  int? created;
  String? model;
  List<Choices>? choices; // 回复选项
  List<Map<String, dynamic>>? references; // 引用列表
  String? type;

  AIMessage({
    this.id,
    this.userMessageId,
    this.aiMessageId,
    this.roomId,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.type,
  });

  AIMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userMessageId = json['userMessageId'];
    aiMessageId = json['aiMessageId'];
    roomId = json['roomId'];
    object = json['object'];
    created = json['created'];
    model = json['model'];
    if (json['choices'] != null) {
      choices = <Choices>[];
      json['choices'].forEach((v) {
        choices!.add(Choices.fromJson(v));
      });
    }
    type = json['type'];
    references = json.getList('references');
  }

  String get content {
    if (choices != null && choices!.isNotEmpty) {
      return choices!.first.delta?.content ?? '';
    }
    return '';
  }
}

class Choices {
  int? index;
  Delta? delta;

  Choices({this.index, this.delta});

  Choices.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    delta = json['delta'] != null ? Delta.fromJson(json['delta']) : null;
  }
}

class Delta {
  String? content;
  String? role;

  Delta({this.content, this.role});

  Delta.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    role = json['role'];
  }
}

class SRVMessageList {
  List<SRVMessage>? list;

  SRVMessageList({this.list});

  SRVMessageList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <SRVMessage>[];
      json['list'].forEach((v) {
        list!.add(SRVMessage.fromJson(v));
      });
    }
  }
}

/// 服务端历史消息对象
class SRVMessage {
  int? messageId;
  String? role;
  String? message;
  int? messageHash;
  int? statisticsType;
  int? pid;
  List<Map>? references;

  SRVMessage({
    this.messageId,
    this.role,
    this.message,
    this.messageHash,
    this.statisticsType,
    this.references,
  });

  SRVMessage.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    role = json['role'];
    message = json['message'];
    messageHash = json['messageHash'];
    statisticsType = json['statisticsType'] ?? 2;
    pid = json['pid'];
    references = json.getList('references');
  }

  Map<String, dynamic> toJson(int roomId) {
    return {
      'id': null,
      'user_id': UserManager.userId,
      'role': roleText.getRoleText(),
      'text': message,
      'type': MessageType.text.getTypeText(),
      'extra': null,
      'role_name': null,
      'ts': ts?.millisecondsSinceEpoch,
      'room_id': roomId,
      'ref_id': null,
      'srv_msgid': messageId,
      'status': 1,
      'images': null,
      'file': null,
      'statistics_type': statisticsType ?? 2,
      'pid': pid,
      'referencess': references,
    };
  }

  Role get roleText => role == 'assistant' ? Role.receiver : Role.sender;

  DateTime? get ts =>
      messageHash != null ? DateTime.fromMillisecondsSinceEpoch(messageHash!) : DateTime.now();
}
