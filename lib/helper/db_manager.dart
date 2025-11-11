/*
 * 文件名称: DataBaseManager.dart
 * 创建时间: 2025/04/12 17:39:40
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xkit/helper/x_logger.dart';

class CADBManager {
  // 单例模式
  static final CADBManager _instance = CADBManager._internal();
  factory CADBManager() => _instance;
  CADBManager._internal();

  static Database? _database;
  final String _dbName = 'xmca.db';
  final int _dbVersion = 1;

  // 获取数据库实例
  Future<Database> get database async {
    xdp('Database path: ${await getApplicationDocumentsDirectory()}');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /* 创建表
  chat_room  表结构说明：
  id 房间id、 user_id 用户id 、 last_update_time 最后更新时间

  message 表结构说明：
  id 本地消息id、 user_id 用户id 、 room_id 房间id 、 type 消息类型 、 
  role 角色 、 role_name 角色名称、 text 消息内容 、extra 扩展字段、 
  ref_id 引用消息id 、 srv_msgid 消息id 、 status(0等待回复 1成功 2失败 3待重发) 消息状态、  images 图片、 
  file 文件、 ts 时间戳 、agent_id 智能体消息ID 、suggestions 推荐问题 statistics_type 统计类型(0=未解决，1=已解决, 2=未操作)
  pid 父消息id
   */
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE chat_room (
          id INTEGER PRIMARY KEY,
          user_id INTEGER NULL,
          last_update_time INTEGER DEFAULT 0 
        )
      ''');

    await db.execute('''
        CREATE TABLE chat_message (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          role TEXT NOT NULL,
          role_name TEXT,
          text TEXT,
          extra TEXT,
          ref_id INTEGER NULL,
          srv_msgid INTEGER NULL,
          status INTEGER DEFAULT 1,
          images TEXT NULL,
          file TEXT NULL,
          ts INTEGER NOT NULL,
          agent_id TEXT NULL,
          suggestions TEXT NULL,
          statistics_type INTEGER DEFAULT 2,
          pid INTEGER
        )
      ''');
  }

  // 数据库升级（可被子类重写）
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加升级逻辑
    }
  }

  // 数据库配置（可被子类重写）
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
