/*
 * 文件名称: tag_resp.dart
 * 创建时间: 2025/07/08 19:48:10
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

class CATagResp {
  String? name;
  int? tagId;
  String? url;
  bool selected = false;

  CATagResp({this.name, this.tagId, this.url, this.selected = false});

  CATagResp.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    tagId = json['tagId'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['tagId'] = tagId;
    data['url'] = url;
    return data;
  }
}
