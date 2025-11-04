/*
 * 文件名称: x_request_interceptor.dart
 * 创建时间: 2025/10/22 16:31:21
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'dart:convert';
import 'package:xkit/api/x_api_sign.dart';
import 'package:xmca/helper/ca_user_manager.dart';
import 'package:xmca/xmca.dart';
import 'package:flutter/services.dart';

class CARequestInterceptor extends InterceptorsWrapper {
  String? pemCache;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 在请求发起前修改头部
    options.headers["Authorization"] = authorization;

    // 三方透传参数
    options.headers["App-Param"] = jsonEncode(appParam);

    //  签名
    var publicKeyPem = await pem;
    var sign = await XApiSign.sign(
      url: options.uri.toString(),
      method: options.method,
      bodyParams: options.data,
      publicKeyPem: publicKeyPem,
    );
    options.headers["X-Content-Security"] = sign;

    // 一定要加上这句话，否则进入不了下一步
    return handler.next(options);
  }

  // 获取授权信息

  String get authorization => UserManager.instance.userInfo.token ?? '';

  Map get appParam => UserManager.instance.threeLoginData ?? {};

  Future<String> get pem async {
    pemCache ??= await rootBundle.loadString('packages/xmca/assets/secret/public.pem');
    return pemCache!;
  }
}
