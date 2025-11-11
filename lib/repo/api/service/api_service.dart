/*
 * 文件名称: api_service.dart
 * 创建时间: 2025/11/04 15:48:51
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xkit/api/x_api_service.dart';
import 'package:xmca/repo/api/interceptor/request_interceptor.dart';

class Service extends XApiService {
  // 私有静态实例
  static final Service _instance = Service._internal();

  // 工厂构造函数
  factory Service() {
    return _instance;
  }

  // getter方法获取实例（可选，如果喜欢 instance 访问方式）
  static Service get instance => _instance;

  // 私有构造函数
  Service._internal() {
    init();
  }

  @override
  init() {
    super.init();
    // 初始化配置
    // xdio.options.baseUrl = 'http://172.16.19.220:9991/v2';
    xdio.options.baseUrl = 'https://aiservicetest.sharexm.com/v2';
    // 添加拦截器（如果需要）
    xdio.interceptors.add(CARequestInterceptor());
    setProxy();
  }
}
