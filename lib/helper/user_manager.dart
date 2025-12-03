/*
 * 文件名称: user_manager.dart
 * 创建时间: 2025/04/12 08:42:46
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xkit/helper/x_sp.dart';
import 'package:xmca/repo/resp/user_resp.dart';

class UserManager {
  static const String userInfokey = 'xmcaUserInfo';

  static final UserManager _instance = UserManager._internal();
  static UserManager get instance => _instance;
  // 单例模式构造函数
  factory UserManager() => _instance;
  UserManager._internal();

  // 保存用户信息
  Future<void> saveUserInfo(UserResp user) async {
    if (user.userId == null || user.token == null) {
      debugPrint('用户信息不正确');
      return;
    }
    final jsonStr = jsonEncode(user.toJson());
    await XSpUtil.prefs.setString(userInfokey, jsonStr);
  }

  void saveNewToken(UserResp userResp) {
    UserResp user = userInfo;
    user.token = userResp.token;
    user.needRefresh = false;
    user.refreshToken = userResp.refreshToken;
    saveUserInfo(user);
  }

  // 清除用户信息
  Future<void> clearUserInfo() async {
    await XSpUtil.prefs.remove(userInfokey);
  }

  // 获取用户信息
  UserResp get userInfo {
    final userInfoJson = XSpUtil.prefs.getString(userInfokey) ?? '{}';
    return UserResp.fromJson(jsonDecode(userInfoJson));
  }

  // 判断登录状态
  bool get isLogin {
    return UserManager.instance.userInfo.token != null &&
        UserManager.instance.userInfo.token!.isNotEmpty;
  }

  static int get userId {
    return UserManager.instance.userInfo.userId ?? -1;
  }

  static String get userName {
    return UserManager.instance.userInfo.nickname;
  }
}
