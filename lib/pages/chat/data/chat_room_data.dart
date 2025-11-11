/*
 * 文件名称: chat_room_data.dart
 * 创建时间: 2025/10/20 10:58:00
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:sqflite/sqlite_api.dart';
import 'package:xkit/helper/x_logger.dart';
import 'package:xmca/helper/db_manager.dart';
import 'package:xmca/repo/resp/room_resp.dart';

class CARoomPart {
  final String key;
  final dynamic value;

  CARoomPart(this.key, this.value);
}

class CARoomDataProvider {
  static Future<ChatRoomResp> getRoom(
    ChatRoomResp room, {
    int? userId, // 用户 ID（可选）
  }) async {
    Database conn = await CADBManager().database;
    var userCondition = userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';

    // 根据房间idc查询房间数据
    List<Map<String, Object?>> rooms = await conn.query(
      'chat_room',
      where: 'id = ? $userCondition',
      whereArgs: [room.roomId],
      limit: 1,
    );
    // 是否查询到房间数据,不存在则插入一条新的房间数据
    if (rooms.isEmpty) {
      await conn.insert('chat_room', {
        'id': room.roomId,
        'user_id': userId,
        'last_update_time': room.lastUpdateTime,
      });
      return room;
    } else {
      // 返回查询到的房间数据
      var roomMap = rooms.first;
      room.lastUpdateTime = roomMap['last_update_time'] as int;
      return room;
    }
  }

  // 更新房间的最后更新时间
  static Future<void> updateLastUpdateTime(int roomId, {int? userId}) async {
    Database conn = await CADBManager().database;
    var userCondition = userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';
    var lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
    xdp('lastUpdateTime:$lastUpdateTime');
    await conn.update(
      'chat_room',
      {'last_update_time': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ? $userCondition',
      whereArgs: [roomId],
    );
  }
}
