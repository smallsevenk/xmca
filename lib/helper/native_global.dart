import 'package:xkit/extension/x_map_ext.dart';

class NativeGlobal {
  /// 三方传递参数
  static Map<String, dynamic>? appParams;

  static Function()? backToNative;
  static Function(dynamic args)? humanCustomerService;

  static NativeAppStyle get style {
    var data = appParams ?? {};
    return NativeAppStyle.fromJson(data.getMap('appStyle'));
  }

  static Map<dynamic, dynamic> get dioParams {
    var data = appParams ?? {};
    return data.getMap('appParams');
  }
}

class NativeAppStyle {
  double textScaler = 1; // 文字缩放倍数
  double iconScaler = 1; // 图标缩放倍数
  double titleScaler = 1; // 标题缩放倍数

  NativeAppStyle.fromJson(Map<String, dynamic> json) {
    textScaler = json.getDouble('textScaler', defaultValue: 1);
    iconScaler = json.getDouble('iconScaler', defaultValue: 1);
    titleScaler = json.getDouble('titleScaler', defaultValue: 1);
  }

  NativeAppStyle fromJson(Map<String, dynamic> json) {
    return NativeAppStyle.fromJson(json);
  }
}
