import 'package:xkit/api/interceptor/x_error_interceptor.dart';
import 'package:xkit/api/interceptor/x_response_interceptor.dart';
import 'package:xkit/api/x_api_service.dart';
import 'package:xmca/repo/api/interceptor/ca_request_interceptor.dart';

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
    // 初始化配置
    // xdio.options.baseUrl = 'http://172.16.19.220:9991/v2';
    xdio.options.baseUrl = 'https://aiservicetest.sharexm.com';

    // 添加拦截器（如果需要）
    xdio.interceptors.add(XResponseInterceptor());
    xdio.interceptors.add(XErrorInterceptor());
    xdio.interceptors.add(CARequestInterceptor());
    setProxy();
  }
}
