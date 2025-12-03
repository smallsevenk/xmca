import 'package:xkit/extension/x_map_ext.dart';

/// 三方传递参数
Map<String, dynamic>? threeAppParams;

class ThreeAppParams {
  double textScaler = 1; // 文字缩放倍数
  double iconScaler = 1; // 图标缩放倍数
  double titleScaler = 1; // 标题缩放倍数

  ThreeAppParams.fromJson(Map<String, dynamic> json) {
    textScaler = json.getDouble('textScaler', defaultValue: 1);
    iconScaler = json.getDouble('iconScaler', defaultValue: 1);
    titleScaler = json.getDouble('titleScaler', defaultValue: 1);
  }

  ThreeAppParams fromJson(Map<String, dynamic> json) {
    return ThreeAppParams.fromJson(json);
  }

  static ThreeAppParams get style {
    var data = threeAppParams ?? {};
    return ThreeAppParams.fromJson(data.getMap('style'));
  }

  static Map get appParams {
    final original = threeAppParams ?? {};
    final copy = Map<String, dynamic>.from(original);
    copy.remove('style');
    return copy;
  }
}
