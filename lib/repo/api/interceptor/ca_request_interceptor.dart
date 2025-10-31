/*
 * 文件名称: x_request_interceptor.dart
 * 创建时间: 2025/10/22 16:31:21
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xkit/api/interceptor/x_request_interceptor.dart';
import 'package:xmca/helper/ca_user_manager.dart';
import 'package:flutter/services.dart' show rootBundle;

class CARequestInterceptor extends XRequestInterceptor {
  // 获取授权信息
  @override
  String get authorization => UserManager.instance.userInfo.token ?? '';

  @override
  Map get appParam => UserManager.instance.threeLoginData ?? {};

  @override
  Future<String> get pem async =>
      await rootBundle.loadString('packages/xmca/assets/secret/public.pem');
}
