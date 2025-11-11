/*
 * 文件名称: chat_message_data.dart
 * 创建时间: 2025/04/18 11:06:52
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述: 聊天室消息数据提供者
 */

import 'package:sqflite/sqlite_api.dart';
import 'package:xkit/helper/x_logger.dart';
import 'package:xmca/helper/db_manager.dart';
import 'package:xmca/pages/chat/data/chat_room_data.dart';
import 'package:xmca/repo/resp/message_resp.dart';
import 'package:xmca/repo/resp/room_resp.dart';

class CAMessagePart {
  final String key;
  final dynamic value;

  CAMessagePart(this.key, this.value);
}

class MessageDataProvider {
  static Future<List<DBMessage>> getMessages(
    int roomId, {
    int? userId, // 用户 ID（可选）
    // 房间 ID（可选）
    int? page, // 页码（可选）
  }) async {
    Database conn = await CADBManager().database;
    var userCondition = userId == null ? ' AND user_id IS NULL' : ' AND user_id = $userId';

    // 如果未传入页码，查询全部数据
    if (page == null || page <= 0) {
      List<Map<String, Object?>> messages = await conn.query(
        'chat_message',
        where: 'room_id = ? $userCondition',
        whereArgs: [roomId],
        orderBy: 'ts asc',
      );
      return messages.map((e) => DBMessage.fromMap(e)).toList();
    }

    // 如果传入页码，按分页查询
    const int pageSize = 10; // 每页 20 条
    final int offset = (page - 1) * pageSize;

    List<Map<String, Object?>> messages = await conn.query(
      'chat_message',
      where: 'room_id = ? $userCondition',
      whereArgs: [roomId],
      orderBy: 'ts asc',
      limit: pageSize,
      offset: offset,
    );

    return messages.map((e) => DBMessage.fromMap(e)).toList();
  }

  /// 获取最后一条用户发送的消息（不含机器人/系统消息）
  static Future<DBMessage?> getLastUserMessage(int roomId, {int? userId}) async {
    Database conn = await CADBManager().database;
    // 假设 user_id 不为 null 且不为 0 的为用户消息，可根据实际业务调整
    final userCondition = userId != null
        ? 'user_id = $userId'
        : 'user_id IS NOT NULL AND user_id != 0';
    List<Map<String, Object?>> messages = await conn.query(
      'chat_message',
      where: 'room_id = ? AND $userCondition',
      whereArgs: [roomId],
      orderBy: 'ts DESC',
      limit: 1,
    );
    if (messages.isNotEmpty) {
      return DBMessage.fromMap(messages.first);
    }
    return null;
  }

  /// 根据 refId 查消息
  static Future<DBMessage?> getMessageByRefMsgId(int refId) async {
    Database conn = await CADBManager().database;
    List<Map<String, Object?>> messages = await conn.query('chat_message', where: 'id =  $refId');
    if (messages.isNotEmpty) {
      return DBMessage.fromMap(messages.first);
    }
    return null;
  }

  // 发送消息
  static Future<int> sendMessage(DBMessage message) async {
    Database conn = await CADBManager().database;
    return conn.insert('chat_message', message.toMap());
  }

  // 聊天历史记录中，所有发送状态为 pending 状态的消息，全部设置为失败
  static Future<void> fixMessageStatus(int roomId) async {
    Database conn = await CADBManager().database;
    return conn.transaction((txn) async {
      await txn.update(
        'chat_message',
        {'status': 2},
        where: 'room_id = ? AND status = 0',
        whereArgs: [roomId],
      );
    });
  }

  // 更新消息
  static Future<void> updateMessages(List<DBMessage> messages) async {
    if (messages.isEmpty) return; // 如果列表为空，直接返回

    Database conn = await CADBManager().database;
    return conn.transaction((txn) async {
      for (var message in messages) {
        await txn.update('chat_message', message.toMap(), where: 'id = ?', whereArgs: [message.id]);
      }
    });
  }

  // 删除消息
  static Future<bool> deleteMessages(int roomId, List<int> ids) async {
    try {
      Database conn = await CADBManager().database;
      String where = 'room_id = ? AND id in (${ids.join(',')})';
      await conn.delete('chat_message', where: where, whereArgs: [roomId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 清除房间消息，仅保留第一条（id最小）
  static Future<bool> clearMessages(int roomId) async {
    try {
      Database conn = await CADBManager().database;
      // // 查询该房间id最小的消息
      // List<Map<String, Object?>> firstMsgList = await conn.query(
      //   'chat_message',
      //   where: 'room_id = ?',
      //   whereArgs: [roomId],
      //   orderBy: 'id ASC',
      //   limit: 1,
      // );
      // int? firstId = firstMsgList.isNotEmpty ? firstMsgList.first['id'] as int? : null;
      await conn.transaction((txn) async {
        // if (firstId != null) {
        //   // 删除除第一条外的所有消息
        //   await txn.delete(
        //     'chat_message',
        //     where: 'room_id = ? AND id != ?',
        //     whereArgs: [roomId, firstId],
        //   );
        // } else {
        // 没有消息则直接删除
        await txn.delete('chat_message', where: 'room_id = ?', whereArgs: [roomId]);
        // }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // 清除发送中/发送失败且消息为空的消息
  static Future<void> deleteInvalidMessage(int roomId) async {
    Database conn = await CADBManager().database;
    return conn.transaction((txn) async {
      await txn.delete(
        'chat_message',
        where:
            'room_id = ? AND (status == 0 OR srv_msgid == -1 OR (status == 2 AND (text IS NULL OR text = "")))',
        whereArgs: [roomId],
      );
    });
  }

  /// 同步服务端消息和本地消息
  static Future<bool> syncServerAndLocalMessages(
    List<CASRVMessage> srvMsgs,
    ChatRoomResp room,
  ) async {
    try {
      Database conn = await CADBManager().database;

      // 1. 获取本地最后一次同步时间之后的所有消息
      List<Map<String, Object?>> localMsgMaps = await conn.query(
        'chat_message',
        where: 'room_id = ? AND ts > ${room.lastUpdateTime}',
        whereArgs: [room.roomId],
      );
      List<DBMessage> localMsgs = localMsgMaps.map((e) => DBMessage.fromMap(e)).toList();

      // 2. 构建本地消息和服务端消息的映射
      final Map<String, DBMessage> localMap = {
        for (var msg in localMsgs) (msg.srvMsgId ?? 0).toString(): msg,
      };
      // final Map<String, SRVMessageItem> serverMap = {
      //   for (var msg in srvMsgs.messages) msg.serverId.toString(): msg,
      // };

      // // 3. 找出本地有但服务端没有的消息（需要删除）
      // final toDelete =
      //     localMsgs.where((msg) {
      //       final sid = msg.serverId?.toString() ?? msg.id.toString();
      //       return !serverMap.containsKey(sid);
      //     }).toList();

      // 4. 找出服务端有但本地没有的消息（需要插入）
      List<CASRVMessage> toInsert = srvMsgs
          .where((msg) => !localMap.containsKey(msg.messageId.toString()))
          .toList();

      // 5. 删除本地多余消息
      // if (toDelete.isNotEmpty) {
      //   await conn.transaction((txn) async {
      //     for (var msg in toDelete) {
      //       await txn.delete('chat_message', where: 'id = ?', whereArgs: [msg.id]);
      //     }
      //   });
      // }

      // 6. 插入服务端新增消息
      if (toInsert.isNotEmpty) {
        await conn.transaction((txn) async {
          for (var msg in toInsert) {
            var insertData = msg.toJson(room.roomId);
            await txn.insert('chat_message', insertData);
          }
        });
      }

      // 7. 可选：更新本地和服务端都存在的消息内容（如有需要）
      // for (var msg in srvMsgs.messages) {
      //   if (localMap.containsKey(msg.serverId.toString())) {
      //     // 比较内容是否一致，不一致则更新
      //   }
      // }

      CARoomDataProvider.updateLastUpdateTime(room.roomId);
      return true;
    } catch (e) {
      xdp('同步消息失败: $e');
      return false;
    }
  }
}
