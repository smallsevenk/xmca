/*
* 文件名称: user_service.dart
* 创建时间: 2025/04/10 10:37:45
* 作者名称: Andy.Zhao
* 联系方式: smallsevenk@vip.qq.com
* 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
* 功能描述:  
*/

import 'package:xmca/repo/api/service/api_service.dart';
import 'package:xkit/api/x_base_resp.dart';
import 'package:xmca/repo/resp/user_resp.dart';
import 'package:xmca/helper/user_manager.dart';

class UserService {
  // 私有静态实例
  static final UserService _instance = UserService._internal();

  // 工厂构造函数
  factory UserService() {
    return _instance;
  }

  // getter方法获取实例（可选，如果喜欢 instance 访问方式）
  static UserService get instance => _instance;

  // 私有构造函数
  UserService._internal() {
    // 初始化代码（如果有的话）
  }

  // 获取 ApiService 单例
  final Service _api = Service.instance;

  /// 同步用户信息
  Future<bool> syncUserInfo() async {
    const path = '/auth/login';
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/auth/signByPhone?apipost_id=1faea0107b9002';

    await UserManager().clearUserInfo();
    // 调用接口
    XBaseResp? resp = await _api.doPost(
      path,
      mock: false,
      mockUrl: mockUrl,
      showLoading: false,
      (resp) => resp,
    );
    // 如果请求成功，保存用户信息
    if (resp != null && resp.success) {
      var user = UserResp.fromJson(resp.data);
      await UserManager().saveUserInfo(user);
      return true;
    } else {
      return false;
    }
  }
}
