/*
 * 文件名称: role_resp.dart
 * 创建时间: 2025/06/25 09:34:54
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'package:xmca/repo/resp/ca_voice_resp.dart';

class CARoleListResp {
  List<CARoleResp>? list;
  CARoleListResp({list});

  CARoleListResp.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <CARoleResp>[];
      json['list'].forEach((v) {
        list!.add(CARoleResp.fromJson(v));
      });
    }
  }
}

class CARoleResp {
  int? id;
  String? role;
  String? name;
  // int? sex; // 0=未知，1=男，2=女
  // String? systemPrompt;
  String? prologue;
  // String? backgroundImgUrl;
  // String? backgroundImgSmallUrl;
  // String? backgroundImgAvatar;
  // String? backgroundImgStyle;
  // String? backgroundImgPrompt;
  AiVoiceResp? voice;
  // int? isOpen; //1=公开，0=私密
  // List<CSTagResp>? tags;
  // int liked = 0; // 1=喜欢 0=未喜欢
  // String? owner;
  String? avatar;
  // int? chatNum;
  // int? likesNum;
  // int? roomId;

  CARoleResp({
    id,
    role,
    name,
    sex,
    systemPrompt,
    initMessage,
    backgroundImgUrl,
    backgroundImgSmallUrl,
    backgroundImgAvatar,
    backgroundImgStyle,
    backgroundImgPrompt,
    voice,
    isOpen,
    tags,
    liked = 0,
    owner,
    avatar,
    chatNum,
    likesNum,
    roomId,
  });

  CARoleResp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    // sex = json['sex'];
    // roomId = json['roomId'];
    // systemPrompt = json['systemPrompt'];
    prologue = json['prologue'];
    // backgroundImgUrl = json['backgroundImgUrl'];
    // backgroundImgSmallUrl = json['backgroundImgSmallUrl'];
    // backgroundImgAvatar = json['backgroundImgAvatar'];
    // backgroundImgPrompt = json['backgroundImgPrompt'];
    // backgroundImgStyle = json['backgroundImgStyle'];
    // isOpen = json['isOpen'];
    voice = json['voice'] != null ? AiVoiceResp.fromJson(json['voice']) : null;
    // if (json['tagList'] != null) {
    //   tags = <CSTagResp>[];
    //   json['tagList'].forEach((v) {
    //     tags?.add(CSTagResp(name: v['name'], tagId: v['tagId']));
    //   });
    // }
    // owner = json['owner'];
    // chatNum = json['chatNum'];
    // likesNum = json['likesNum'] ?? 0;
    avatar = json['avatar'];
    // liked = json['liked'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['role'] = role;
    data['name'] = name;
    // data['sex'] = sex;
    // data['systemPrompt'] = systemPrompt;
    data['initMessage'] = prologue;
    // data['backgroundImgUrl'] = backgroundImgUrl;
    // data['backgroundImgSmallUrl'] = backgroundImgSmallUrl;
    // data['backgroundImgAvatar'] = backgroundImgAvatar;
    // data['backgroundImgPrompt'] = backgroundImgPrompt;
    // data['backgroundImgStyle'] = backgroundImgStyle;
    // data['isOpen'] = isOpen;
    // data['roomId'] = roomId;
    // data['tagIds'] = tags?.map((e) => e.tagId).toList() ?? [];
    if (voice != null) {
      data['voice'] = voice!.toJson();
    }

    return data;
  }
}
