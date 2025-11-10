// import 'dart:convert';
// import 'dart:math';

// import 'package:aliyun_av_plugin/aliyun_av_plugin.dart';
// import 'package:aliyun_av_plugin/bean/rtc_config.dart';
// import 'package:flutter/material.dart';
// import 'package:xkit/x_kit.dart';
// import 'package:xmca/helper/ca_user_manager.dart';
// import 'package:xmca/repo/api/service/ca_chat_room_service.dart';
// import 'package:xmca/repo/resp/ca_room_resp.dart';

// class CAAvUtil {
//   /// 在通话结束后同步聊天消息
//   static syncChatMessagesOnCallFinished(Function() syncMessages) {
//     AliyunAvPlugin.asynSubtitleUpdate(() {
//       syncMessages();
//     });
//   }

//   static Future<bool> getMediaPermissions({required BuildContext Function() context}) async {
//     if (!await XPermissionUtil.checkMicrophone(context: context)) {
//       return false;
//     }

//     if (!await XPermissionUtil.checkCamera(context: context)) {
//       return false;
//     }

//     if (!await XPermissionUtil.checkStorage(context: context)) {
//       return false;
//     }
//     return true;
//   }

//   static RtcConfig _getRtcConfig(bool isVoice, ChatRoomResp room, RtcConfig rtcDto) {
//     final userId = UserManager.userId.toString();
//     final sessionIdStr = '$userId${room.roomId}${_generateCustom16BitId()}';
//     final callType = isVoice ? 'VoiceAgent' : 'VisionAgent';

//     // 构建 userData 字段
//     final userData = {
//       'userId': userId,
//       'roomId': room.roomId.toString(),
//       'sessionId': sessionIdStr,
//       'appParam': jsonEncode(UserManager.instance.threeLoginData ?? {}),
//       'callType': callType,
//     };

//     return RtcConfig(
//       agentType: callType,
//       agentId: isVoice ? rtcDto.voiceInstanceId ?? "" : rtcDto.videoInstanceId ?? "",
//       token: isVoice ? rtcDto.voiceToken ?? "" : rtcDto.videoToken ?? "",
//       userId: userId,
//       loginAuthorization: UserManager().userInfo.token ?? '',
//       sessionId: sessionIdStr,
//       prologue: room.prologue ?? '',
//       userData: jsonEncode(userData),
//     );
//   }

//   /// 拨打音视频
//   static void startAvCall(ChatRoomResp room, bool isVoice) async {
//     try {
//       String subTxt = _generateCustom16BitId();
//       String subRoomId = '${room.roomId}$subTxt';
//       RtcConfig? rtcConfig = await ChatRoomService.instance.getArtcTokenInfo(subRoomId);
//       rtcConfig?.channelId = subRoomId;
//       AliyunAvPlugin.callAgentType(rtcConfig: _getRtcConfig(isVoice, room, rtcConfig!));
//     } catch (e) {
//       showToast('获取ArtcToken失败: ${e.toString()}');
//     }
//   }

//   // 基于随机数和时间戳
//   static String _generateCustom16BitId() {
//     final random = Random();
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     return '${random.nextInt(9999)}${timestamp % 100000}'
//         .padRight(16, '$timestamp')
//         .substring(0, 16);
//   }

//   static String detectionFormat(String url) {
//     if (url.endsWith('.pdf')) {
//       return 'pdf';
//     } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
//       return 'doc';
//     } else if (url.endsWith('.xls') || url.endsWith('.xlsx')) {
//       return 'xls';
//     } else if (url.endsWith('.ppt') || url.endsWith('.pptx')) {
//       return 'ppt';
//     } else if (url.endsWith('.txt')) {
//       return 'txt';
//     }
//     return '';
//   }
// }
