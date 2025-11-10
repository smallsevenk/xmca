/*
 * 文件名称: chat_room_service.dart
 * 创建时间: 2025/07/08 19:47:41
 * 作者名称: Andy.Zhao
 * 联系方式: smallsevenk@vip.qq.com
 * 创作版权: Copyright (c) 2025 XianHua Zhao (andy)
 * 功能描述:  
 */

import 'dart:async';
import 'dart:convert';
import 'package:xkit/api/x_base_resp.dart';
// import 'package:aliyun_av_plugin/bean/rtc_config.dart';
import 'package:xmca/repo/api/service/ca_api_service.dart';
import 'package:xmca/repo/resp/ca_message_resp.dart';
import 'package:xmca/repo/resp/ca_room_resp.dart';
import 'package:xkit/x_kit.dart';

class ChatRoomService {
  // 私有静态实例
  static final ChatRoomService _instance = ChatRoomService._internal();

  // 工厂构造函数
  factory ChatRoomService() {
    return _instance;
  }

  // getter方法获取实例（可选，如果喜欢 instance 访问方式）
  static ChatRoomService get instance => _instance;

  // 私有构造函数
  ChatRoomService._internal() {
    // 初始化代码（如果有的话）
  }

  // 获取 ApiService 单例
  final Service _api = Service.instance;

  /// 流式请求的订阅
  StreamSubscription? streamSubscription;

  /// Dio 取消令牌，用于主动取消 HTTP 请求
  CancelToken? _cancelToken;

  /// 房间详情接口
  Future<ChatRoomResp?> getRoomInfo(int? id) async {
    const path = '/room/info';
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/room/info?apipost_id=1b282ec3b12002';
    var params = {"id": id ?? 0};
    final resp = await _api.doGet(
      path,
      mock: false, // 是否使用 Mock 数据
      mockUrl: mockUrl, // Mock 数据 URL
      showLoading: true, // 是否显示加载动画
      params: params,
      (resp) => ChatRoomResp.fromJson(resp.data),
    );
    return resp;
  }

  /// 消息对齐接口
  Future<List<CASRVMessage>> getHistoryMessage({required ChatRoomResp room}) async {
    const path = '/room/getHistoryMessage';
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/user/messageList?apipost_id=1fbd36067b905f';

    var params = {"roomId": room.roomId, "lastTime": room.lastUpdateTime};

    final resp = await _api.doGet(
      path,
      mock: false,
      mockUrl: mockUrl,
      showLoading: false,
      params: params,
      (resp) => CASRVMessageList.fromJson(resp.data),
    );
    return resp?.list ?? [];
  }

  /// 消息删除接口
  Future<bool> messageDelete({int? roomId, int? srvMsgId}) async {
    // 如果房间 ID 或消息 ID 为空，说明是一条本地未发送成功的消息,无需调用接口 直接返回 true
    if (roomId == null || srvMsgId == null) return true;
    const path = '/room/messageDelete';
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/user/messageDelete?apipost_id=1fbd7bd6fb9062';
    var params = {"roomId": roomId, 'messageId': srvMsgId};
    final resp = await _api.doPost(
      path,
      mock: false,
      mockUrl: mockUrl,
      showLoading: false,
      params: params,
      (resp) => resp,
    );
    return resp?.success ?? false;
  }

  /// 清空历史记录
  Future<bool> clear({int? roomId}) async {
    if (roomId == null) return false;
    const path = '/room/messageClear';
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/user/messageDelete?apipost_id=1fbd7bd6fb9062';
    var params = {"roomId": roomId};
    final resp = await _api.doPost(
      path,
      mock: false,
      mockUrl: mockUrl,
      showLoading: false,
      params: params,
      (resp) => resp,
    );
    return resp?.success ?? false;
  }

  /// 获取ARTCTOKEN信息
  // Future<RtcConfig?> getArtcTokenInfo(String? id) async {
  //   const path = '/public/getAliArtcToken';
  //   var params = {"roomId": id};
  //   final resp = await _api.doGet(
  //     path,
  //     mock: false, // 是否使用 Mock 数据
  //     showLoading: false, // 是否显示加载动画
  //     params: params,
  //     (resp) => RtcConfig.fromMap(resp.data),
  //   );
  //   return resp;
  // }

  /// 获取推荐问题
  Future<List<String>> getSuggestionAnswer(int id, int? messageId) async {
    const mockUrl =
        'https://mock.apipost.net/mock/41fae66ff8e0000/room/getSuggestionAnswer?apipost_id=1142f562712002';
    const path = '/room/getSuggestionAnswer';
    var params = {"roomId": id, "messageId": messageId ?? 0};
    try {
      List resp = await _api.doGet(
        path,
        // mock: true, // 是否使用 Mock 数据
        mockUrl: mockUrl, // Mock 数据 URL
        showLoading: false, // 是否显示加载动画
        params: params,
        (resp) => resp.data['list'] ?? [],
      );
      return resp.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  /// 客服反馈 0=未解决，1=已解决
  Future<bool> replyStatistics({required int messageId, required int type}) async {
    const path = '/room/messageReplyStatistics';
    var params = {"messageId": messageId, 'statisticsType': type};
    final resp = await _api.doPost(path, showLoading: false, params: params, (resp) => resp);
    return resp?.success ?? false;
  }

  /// 客服反馈 0=未解决，1=已解决
  Future<dynamic> getParentMessage({required int messageId}) async {
    const path = '/room/getParentMessage';
    var params = {"messageId": messageId};
    final resp = await _api.doGet(path, showLoading: false, params: params, (resp) => resp);
    return (resp?.data ?? {})['message'];
  }

  /// 发起流式请求
  Future<void> fetchStreamData<T>(
    String path, {
    required Function(XBaseResp?) onRespone,
    required Function(dynamic error) onError,
    Map<String, dynamic>? params,
    Function()? onDone,
    Function()? onRefreshState,
    bool? showData,
  }) async {
    // 取消上一次的流式请求
    cancelFlow();

    void handleError(error) {
      onRefreshState?.call();
      onError(error);
    }

    try {
      // 配置流式请求参数
      // 新建或替换取消令牌
      _cancelToken = CancelToken();

      var response = await _api.xdio.post(
        path,
        data: params,
        options: Options(responseType: ResponseType.stream),
        cancelToken: _cancelToken,
      );

      bool noError = true;
      // 调用封装的方法处理流式响应
      streamSubscription = response.data.stream.listen(
        (chunk) async {
          // 处理数据块（示例为JSON解析）
          try {
            final String data = utf8.decode(chunk);
            if (showData == true) {
              xdp(data);
            }
            final List<String> dataLines = data
                .split("\n")
                .where((element) => element.isNotEmpty)
                .toList();

            for (String line in dataLines) {
              if (line.startsWith("data: ")) {
                final String data = line.substring(6);
                if (data.startsWith("[DONE]")) {
                  if (noError) {
                    onRespone.call(null);
                  }
                  return;
                }

                final decoded = jsonDecode(data) as Map<String, dynamic>;
                final base = XBaseResp.fromJson(decoded);
                if (base.success) {
                  onRespone.call(base);
                } else {
                  noError = false;
                  showToast(base.message);
                  handleError(base);
                }
              }
            }
          } catch (e) {
            handleError(e);
          }
        },
        onError: (error) {
          handleError(error);
        },
        onDone: () {
          cancelFlow();
          onRefreshState?.call();
          onDone?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      cancelFlow();
      // 其他错误处理
      handleError(e);
    }
    onRefreshState?.call();
  }

  // 取消流式请求
  void cancelFlow() {
    // 先取消底层网络请求（这会使正在读取的 response stream 抛出异常或终止）
    try {
      _cancelToken?.cancel("cancelled_by_user");
    } catch (e) {
      // ignore
    }
    _cancelToken = null;

    // 再取消 Dart 层的订阅，释放资源
    streamSubscription?.cancel();
    streamSubscription = null;
  }
}
