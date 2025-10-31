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
import 'package:xkit/extension/x_datetime_ext.dart';
import 'package:xkit/extension/x_map_ext.dart';
import 'package:xmca/helper/ca_user_manager.dart';
import 'package:xmca/pages/chat/widget/ca_chat_message_item.dart';

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

  String? agentId;

  // 统计类型(0=未解决，1=已解决, 2=未操作)
  int? statisticsType;

  // 父消息 id
  int? pid;

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
    this.agentId,
    this.statisticsType,
    this.pid,
  });

  /// 设置消息附加信息
  void setExtra(dynamic data) {
    extra = jsonEncode(data);
  }

  /// 更新消息附加信息
  void updateExtra(dynamic data) {
    // 需要将 data merge 到 extra 中
    final extraData = decodeExtra();
    if (extraData != null) {
      data = <String, dynamic>{...extraData, ...data};
    }

    extra = jsonEncode(data);
  }

  /// 将值添加到附加信息的某个数组键中
  void pushExtra(String key, dynamic value) {
    var extraData = decodeExtra();
    extraData ??= <String, dynamic>{};

    if (!extraData.containsKey(key)) {
      extraData[key] = [];
    }

    extraData[key]!.add(value);
    extra = jsonEncode(extraData);
  }

  /// 从附加信息的某个数组键中删除最后一个值
  void popExtra(String key) {
    var extraData = decodeExtra();
    extraData ??= <String, dynamic>{};
    extraData[key]!.removeLast();
    extra = jsonEncode(extraData);
  }

  /// 获取消息附加信息
  decodeExtra() {
    if (extra == null) {
      return null;
    }

    return jsonDecode(extra!);
  }

  /// 是否是系统消息，包括时间线
  bool isSystem() {
    return type == MessageType.system ||
        type == MessageType.timeline ||
        type == MessageType.contextBreak;
  }

  /// 是否是初始消息
  bool isInitMessage() {
    return type == MessageType.initMessage;
  }

  /// 是否是时间线
  bool isTimeline() {
    return type == MessageType.timeline;
  }

  /// 格式化时间
  String friendlyTime() {
    return ts?.toFriendlyString() ?? '';
  }

  /// 是否已失败
  bool statusIsFailed() {
    return status == 2;
  }

  /// 是否已成功
  bool statusIsSucceed() {
    return status == 1;
  }

  /// 是否等待应答
  bool statusPending() {
    return status == 0;
  }

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
      'agent_id': agentId,
      'statistics_type': statisticsType,
      'pid': pid,
    };
  }

  DBMessage.fromMap(Map<String, Object?> json)
    : id = json.getInt('id'),
      userId = json.getInt('user_id'),
      role = Role.getRoleFromText(json.getString('role')),
      text = json.getString('text'),
      extra = json.getString('extra'),
      type = MessageType.getTypeFromText(json.getString('type')),
      roleName = json.getString('role_name'),
      agentId = json.getString('agentId'),
      refId = json.getInt('ref_id'),
      srvMsgId = json.getInt('srv_msgid'),
      status = json.getInt('status'),
      ts = json['ts'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
      roomId = json.getInt('room_id'),
      suggestions = json['suggestions'] == null
          ? null
          : (jsonDecode(json.getString('suggestions')) as List<dynamic>).cast<String>(),
      images = json['images'] == null
          ? null
          : (jsonDecode(json.getString('images')) as List<dynamic>).cast<String>(),

      file = json.getString('file'),
      statisticsType = json.getInt('statistics_type'),
      pid = json.getInt('pid');
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

class CAAIMessage {
  String? id;
  int? userMessageId;
  int? aiMessageId;
  int? roomId;
  String? object;
  int? created;
  String? model;
  List<CAChoices>? choices;
  String? type;

  CAAIMessage({
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

  CAAIMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userMessageId = json['userMessageId'];
    aiMessageId = json['aiMessageId'];
    roomId = json['roomId'];
    object = json['object'];
    created = json['created'];
    model = json['model'];
    if (json['choices'] != null) {
      choices = <CAChoices>[];
      json['choices'].forEach((v) {
        choices!.add(CAChoices.fromJson(v));
      });
    }
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userMessageId'] = userMessageId;
    data['aiMessageId'] = aiMessageId;
    data['roomId'] = roomId;
    data['object'] = object;
    data['created'] = created;
    data['model'] = model;
    if (choices != null) {
      data['choices'] = choices!.map((v) => v.toJson()).toList();
    }
    data['type'] = type;
    return data;
  }

  String get content {
    if (choices != null && choices!.isNotEmpty) {
      return choices!.first.delta?.content ?? '';
    }
    return '';
  }
}

class CAChoices {
  int? index;
  CADelta? delta;

  CAChoices({this.index, this.delta});

  CAChoices.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    delta = json['delta'] != null ? CADelta.fromJson(json['delta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    if (delta != null) {
      data['delta'] = delta!.toJson();
    }
    return data;
  }
}

class CADelta {
  String? content;
  String? role;

  CADelta({this.content, this.role});

  CADelta.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['role'] = role;
    return data;
  }
}

class CASRVMessageList {
  List<CASRVMessage>? list;

  CASRVMessageList({this.list});

  CASRVMessageList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <CASRVMessage>[];
      json['list'].forEach((v) {
        list!.add(CASRVMessage.fromJson(v));
      });
    }
  }
}

class CASRVMessage {
  int? messageId;
  String? role;
  String? message;
  int? messageHash;
  int? statisticsType;
  int? pid;

  CASRVMessage({this.messageId, this.role, this.message, this.messageHash, this.statisticsType});

  CASRVMessage.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    role = json['role'];
    message = json['message'];
    messageHash = json['messageHash'];
    statisticsType = json['statisticsType'] ?? 2;
    pid = json['pid'];
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
    };
  }

  Role get roleText => role == 'assistant' ? Role.receiver : Role.sender;

  DateTime? get ts =>
      messageHash != null ? DateTime.fromMillisecondsSinceEpoch(messageHash!) : DateTime.now();
}
