/*
 * 文件名称: common_service.dart
 * 创建时间: 2025/04/24 08:36:12
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xmca/repo/api/service/ca_api_service.dart';
import 'package:xmca/repo/resp/ca_aliyun_resp.dart';

class CACommonService {
  // 私有静态实例
  static final CACommonService _instance = CACommonService._internal();

  // 工厂构造函数
  factory CACommonService() {
    return _instance;
  }

  // getter方法获取实例（可选，如果喜欢 instance 访问方式）
  static CACommonService get instance => _instance;

  // 私有构造函数
  CACommonService._internal() {
    // 初始化代码（如果有的话）
  }

  // 获取 ApiService 单例
  final Service _api = Service.instance;

  /// 获取阿里token
  Future<CAALiyunResp?> getAliToken() async {
    const path = '/public/getAliToken';
    const mockUrl = '';
    try {
      return _api.doGet(
        path,
        mock: false,
        mockUrl: mockUrl,
        showLoading: false,
        (resp) => CAALiyunResp.fromJson(resp.data),
      );
    } catch (e) {
      throw Exception('请求失败: $e');
    }
  }
}
