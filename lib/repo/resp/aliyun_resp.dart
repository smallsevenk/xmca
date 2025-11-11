/*
 * 文件名称: aliyun_resp.dart
 * 创建时间: 2025/05/13 12:09:16
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

class ALiyunResp {
  int? expire;
  String? token;

  ALiyunResp.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expire = (json['expire'] ?? 0) * 1000;
  }
}
