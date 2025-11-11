/*
 * 文件名称: user_resp.dart
 * 创建时间: 2025/04/12 08:41:30
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xkit/extension/x_map_ext.dart';

class UserResp {
  int? userId;
  String? token;
  String? refreshToken;
  String? avatar;
  late String nickname;
  bool needRefresh = false;
  UserResp({this.userId, this.token, this.refreshToken, this.avatar, this.nickname = ''});

  UserResp.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    token = json['token'];
    refreshToken = json['refreshToken'];
    avatar = json.getString('avatar');
    nickname = json.getString('nickname');
    needRefresh = json.getInt('refresh') == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['token'] = token;
    data['refreshToken'] = refreshToken;
    data['avatar'] = avatar;
    data['nickname'] = nickname;
    data['refresh'] = needRefresh ? 1 : 0;
    return data;
  }

  UserResp fromJson(Map<String, dynamic> json) {
    return UserResp.fromJson(json);
  }
}
