/*
 * 文件名称: api_service.dart
 * 创建时间: 2025/11/04 15:48:51
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xkit/x_kit.dart';
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
  final String apiVersion = 'v3';
  late List<XEnvironment> envs = [];

  final String baseUrlKey = 'XMCABaseUrl';

  @override
  init() {
    super.init();

    envs = [
      XEnvironment('生产', 'https://aiservice.sharexm.com/'),
      XEnvironment('测试', 'https://aiservicetest.sharexm.com/'),
      XEnvironment('开发', 'http://172.16.19.117:9991/'),
    ];

    var baseUrl = XSpUtil.prefs.getString(baseUrlKey);
    if (baseUrl == null) {
      baseUrl = envs.first.url;
      XSpUtil.prefs.setString(baseUrlKey, baseUrl);
    }
    baseUrl = baseUrl.replaceAll('v2', '');
    // 初始化配置
    xdio.options.baseUrl = baseUrl;
    // 添加拦截器（如果需要）
    xdio.interceptors.add(RequestInterceptor());
    setProxy();
  }
}
