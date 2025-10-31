import 'package:xkit/helper/x_loading.dart';
import 'package:xkit/helper/x_sp.dart';
import 'package:xmca/pages/chat/util/ca_nui_util.dart';

XLoading? csLoading;
Function(String? content, {int? animationTime, Object? stackTrace})? showCsToast;
Function()? csBackToNative;
Function(dynamic args)? csHumanCustomerService;

/// 全局自动播放开关
bool get autoPlaySwitchIsOpen => XSpUtil.prefs.getBool(autoPlayKey) ?? false;
setAutoPlay() {
  XSpUtil.prefs.setBool(autoPlayKey, !autoPlaySwitchIsOpen);
}
