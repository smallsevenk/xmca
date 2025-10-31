/*
 * 文件名称: room_resp.dart
 * 创建时间: 2025/06/25 09:34:42
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xkit/extension/x_map_ext.dart';
import 'package:xmca/repo/resp/ca_role_resp.dart';

class ChatRoomResp {
  int roomId = 0; //房间id
  String? name;
  String? prologue;
  String? icon;
  CARoleResp? userRole;
  CARoleResp? aiRole;
  int lastUpdateTime = 0;

  ChatRoomResp({
    required roomId,
    suggestions,
    title,
    desc,
    backgroundImgUrl,
    initMessage,
    userRole,
    aiRoles,
    color = '181818',
    lastupdateTime = 0,
  });

  ChatRoomResp.fromJson(Map<String, dynamic> json) {
    roomId = json.getInt('roomId');
    name = json.getString('name');
    prologue = json.getString('prologue');
    icon = json.getString('icon');
    userRole = CARoleResp.fromJson(json['userRole']);
    aiRole = CARoleResp.fromJson(json['aiRole']);
    lastUpdateTime = json.getInt('lastUpdateTime');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomId'] = roomId;
    data['name'] = name;
    data['prologue'] = prologue;
    data['icon'] = icon;
    data['aiRole'] = aiRole;
    data['userRole'] = userRole?.toJson();
    data['lastUpdateTime'] = lastUpdateTime;
    return data;
  }
}
