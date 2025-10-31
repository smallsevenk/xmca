/*
 * 文件名称: voice_resp.dart
 * 创建时间: 2025/07/08 19:48:18
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */
class AiVoiceResp {
  int? voiceId;
  int style = 10;
  int speed = 10;
  String? voiceParamName;
  String? auditionUrl;
  String? avatar;
  String? cnName;
  int? sex; //1=男，2=女
  List<String> tag = [];

  AiVoiceResp({
    this.voiceId,
    this.style = 10,
    this.speed = 10,
    this.voiceParamName,
    this.auditionUrl,
    this.cnName,
    this.sex,
    this.tag = const [],
    this.avatar,
  });

  AiVoiceResp.fromJson(Map<String, dynamic> json) {
    voiceId = json['voiceId'];
    style = json['style'] ?? 10;
    speed = json['speed'] ?? 10;
    String voiceName = json['voiceParamName'] ?? '';

    voiceParamName = voiceName.isEmpty ? 'xiaoyun' : voiceName;
    auditionUrl = json['url'];
    cnName = json['cnName'];
    sex = json['sex'];
    if (json['tag'] != null) {
      json['tag'].forEach((v) {
        tag.add(v);
      });
    }
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voiceId'] = voiceId;
    data['style'] = style;
    data['speed'] = speed;
    data['voiceParamName'] = voiceParamName;
    data['url'] = auditionUrl;
    data['cnName'] = cnName;
    data['sex'] = sex;
    data['tag'] = tag;
    return data;
  }
}
