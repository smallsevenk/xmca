import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xmca/xmca.dart';

class NativeBridge {
  late final MethodChannel _channel;

  // 私有静态实例
  static final NativeBridge _instance = NativeBridge._internal();

  // 工厂构造函数
  factory NativeBridge() {
    return _instance;
  }

  // getter方法获取实例（可选，如果喜欢 instance 访问方式）
  static NativeBridge get instance => _instance;

  // 私有构造函数
  NativeBridge._internal() {
    // 初始化配置
    _channel = MethodChannel('com.sharexm.flutter/native');
  }

  // 调用原生方法
  Future<void> invokeNativeMethod(String method, [dynamic arguments]) async {
    try {
      await _channel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to invoke method '$method': ${e.message}");
      }
    }
  }

  // 设置原生调用的回调
  void setMethodCall() {
    _channel.setMethodCallHandler((call) async {
      var method = call.method;
      var params = call.arguments;
      xlog('Main ==> nativeCall:$method\n$params}');
      try {
        Map<String, dynamic>? threeInfo;
        if (params is Map) {
          threeInfo = Map<String, dynamic>.from(params);
        }
        if (threeInfo != null) {
          xlog('Main ==> Received params is Map<String, dynamic>: $threeInfo');
          if (method == 'openXmcs') {
            Xmca.config(
              params: threeInfo,
              backToNative: returnToNative,
              humanCustomerService: (args) {
                humanCustomerService.call(args);
              },
            );
          } else if (method == 'openXmca') {
            Xmca.config(
              params: threeInfo,
              backToNative: returnToNative,
              humanCustomerService: (args) {
                humanCustomerService.call(args);
              },
            );
          }
        } else {
          xlog('Main ==> Received params is ${params.runtimeType}, not a <String, dynamic>');
        }
      } catch (e) {
        xlog('Main ==> nativeBridge Error: ${e.toString()}');
      }
    });
  }

  // 点击回退
  Future<void> returnToNative() async {
    await Future.delayed(Duration(milliseconds: 200), () {
      invokeNativeMethod('backToNative');
    });
  }

  // 点击人工客服
  Future<void> humanCustomerService(dynamic args) async {
    await Future.delayed(Duration(milliseconds: 200), () async {
      await invokeNativeMethod('HumanCustomerService', args);
    });
  }
}
